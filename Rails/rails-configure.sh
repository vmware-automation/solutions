#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE

export test_app="/home/$RAILSUSER/passenger_app"
export test_app_base="passenger_app"

# Output the set of commands to a file to be run as the railsuser
su - $RAILSUSER -p -c /bin/bash <<EOF
set -e
. $COMMON_INCLUDE
. $RVM_HOME/scripts/rvm
export HOME=/home/$RAILSUSER
if [[ -z "$ruby_version" || -z "$rails_version" ]]; then
    echo "Missing required environment variable"
    exit 1
fi
try rvm use $ruby_version@appdirector-gemset
echo "Creating test app $test_app"
try rails new $test_app -G
try cat >> $test_app/Gemfile <<EXJSCONF
gem 'execjs'
gem 'therubyracer'
EXJSCONF
try chmod 755 /home/$RAILSUSER $test_app
try find $test_app -type d -exec chmod 755 {} +
EOF

if [[ $? != 0 ]]; then
    echo "Failed to setup $test_app"
    exit 1
fi

. $RVM_HOME/scripts/rvm
mkdir -p /var/log/httpd
# Configure Apache module
GEM_DIR=$(rvm gemdir)
PASSENGER_ROOT=$(passenger-config --root)
RVM_RUBY=$(rvm which ruby)
HTTP_DIR=/etc/httpd/conf
HTTP_CONF=$HTTP_DIR/httpd.conf

# cleanup any old install
yum erase -y httpd
try yum -y --nogpgcheck install httpd

cd $HTTP_DIR
# Add a statement to load the Passenger module 
echo "Adding the LoadModule directive to the httpd.conf file"
try cp $HTTP_CONF ${HTTP_CONF}.orig
sed "/LoadModule version_module/ a LoadModule passenger_module $PASSENGER_ROOT/buildout/apache2/mod_passenger.so" ${HTTP_CONF}.orig > $HTTP_CONF

echo "Adding virtual host to Apache config"
cat >> $HTTP_CONF << EOF
<VirtualHost *>
    PassengerHighPerformance on
    PassengerMaxPoolSize 12
    PassengerPoolIdleTime 1500
    PassengerStatThrottleRate 120
    PassengerRoot $PASSENGER_ROOT
    PassengerRuby $RVM_RUBY
    RailsEnv development
    ServerName $(hostname)
    DocumentRoot $test_app/public
    RailsBaseURI /$test_app_base
    <Directory $test_app/public>
        Options -MultiViews
        AllowOverride None
        Order allow,deny
        Allow from all
    </Directory>
 LogLevel warn
 ErrorLog /var/log/service_test_error.log
 CustomLog /var/log/service_log_access.log combined
</VirtualHost>
EOF
