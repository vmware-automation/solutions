#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE

# Output the set of commands to a file to be run as the railsuser
su - $RAILSUSER -p -c /bin/bash <<EOF
set -e
. $COMMON_INCLUDE
. $RVM_HOME/scripts/rvm
export HOME=/home/$RAILSUSER
if [[ -z "$http_proxy" || -z "$https_proxy" || -z "$ruby_version" || -z "$rails_version" || -z "$test_app" ]]; then
    echo "Missing required environment variable"
    exit 1
fi
try rvm use $ruby_version@appdirector-gemset
echo "Creating test app. $test_app"
try rails new /home/$RAILSUSER/$test_app -G
try cat >> /home/$RAILSUSER/$test_app/Gemfile <<EXJSCONF
gem 'execjs'
gem 'therubyracer'
EXJSCONF
try chmod 755 /home/$RAILSUSER /home/$RAILSUSER/$test_app
try find /home/$RAILSUSER/$test_app -type d -exec chmod 755 {} +
EOF

. $RVM_HOME/scripts/rvm
mkdir -p /var/log/httpd
# Configure Apache module
GEM_DIR=$(rvm gemdir)
PASSENGER_ROOT=$(passenger-config --root)
RVM_RUBY=$(rvm which ruby)
# Add a statement to load the Passenger module 
echo "Adding the LoadModule directive to the httpd.conf file"
sed -i.bak "/LoadModule version_module/ a LoadModule passenger_module $PASSENGER_ROOT/buildout/apache2/mod_passenger.so" /etc/httpd/conf/httpd.conf

echo "Adding virtual host to Apache config"
cat >> /etc/httpd/conf/httpd.conf <<APACHE
<VirtualHost *>
    PassengerHighPerformance on
    PassengerMaxPoolSize 12
    PassengerPoolIdleTime 1500
    PassengerStatThrottleRate 120
    PassengerRoot $PASSENGER_ROOT
    PassengerRuby $RVM_RUBY
    RailsEnv development
    ServerName $(hostname)
    DocumentRoot /home/$RAILSUSER/$test_app/public
    RailsBaseURI /$test_app
    <Directory /home/$RAILSUSER/$test_app/public>
        Options -MultiViews
        AllowOverride None
        Order allow,deny
        Allow from all
    </Directory>
 LogLevel warn
 ErrorLog /var/log/service_test_error.log
 CustomLog /var/log/service_log_access.log combined
</VirtualHost>
APACHE
