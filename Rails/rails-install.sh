#!/bin/bash
set -e

# Import global conf 
. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root

# Tested on CentOS
if [ -x /usr/sbin/selinuxenabled ] && /usr/sbin/selinuxenabled; then
    # SELinux can be disabled by setting "/usr/sbin/setenforce Permissive"
    echo 'SELinux in enabled on this VM template.  This service requires SELinux to be disabled to install successfully'
    exit 1
fi

try yum -y --nogpgcheck install git gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel libjpeg-devel giflib-devel freetype-devel curl curl curl-devel httpd httpd-devel apr-devel apr-util-devel

# Tell curl to allow unvalidated certs. We are using 
# the rc file instead of -k because of environment issues. 
# (depends on the HOME export above) 
echo 'insecure' >> ~/.curlrc
echo "proxy=$http_proxy" >> ~/.curlrc

try curl -L get.rvm.io | bash -s stable

# Create the railsuser and add it to the rvm group 
echo "Creating the railsuser account"
try /usr/sbin/adduser -G root,rvm railsuser
echo '[[ -s "/usr/local/rvm/scripts/rvm" ]] && . "/usr/local/rvm/scripts/rvm"' >> ~railsuser/.bashrc

tmpglobalconf="install_global.conf"
# Output the set of commands to a file to be run as the railsuser
cat > runfile <<EOF
#!/bin/bash

. $tmpglobalconf

export RUBY_VERSION=$RUBY_VERSION
export RAILS_VERSION=$RAILS_VERSION

echo 'insecure' >> ~/.curlrc
echo "proxy=$http_proxy" >> ~/.curlrc

# Source RVM 
. /usr/local/rvm/scripts/rvm

# Tell RVM to install Ruby
echo "Creating a gemset and installing Ruby $RUBY_VERSION in it"
try rvm --install --default use $RUBY_VERSION@appdirector-gemset --create

# Only set errexit *after* running RVM because it's not prepared for it
set -e

# Install Rails (and all dependencies)
echo "Installing Rails $RAILS_VERSION"
try gem install rails -v $RAILS_VERSION

# Install Passenger/mod_rails gem 
echo "Installing Passenger gem"
try gem install passenger 

EOF

# Prepar the file to be run as the railsuser
cp runfile /home/railsuser/runfile
cp $global_conf /home/railsuser/$tmpglobalconf
chown -R railsuser:railsuser /home/railsuser
chmod 755 /home/railsuser/runfile

# Run the script as the railsuser to install Ruby and Rails
su -c /home/railsuser/runfile - railsuser

# Install Passenger/mod_rails Apache module as the railsuser
echo "Installing Passenger Apache module" 
rubminor=`ls -ad /usr/local/rvm/gems/ruby-$RUBY_VERSION-*appdirector-gemset | cut -d '-' -f3 | cut -d '@' -f1`

# Ruby installer doesn't like the the newline entered like this for generating enter keypress but still looks to complete fine
su - railsuser -c "/usr/local/rvm/gems/ruby-$RUBY_VERSION-$rubminor@appdirector-gemset/bin/passenger-install-apache2-module --auto"

# Configure Apache module
# Add a statement to load the Passenger module 
echo "Adding the LoadModule directive to the httpd.conf file"
passengerver=`ls -ad  /usr/local/rvm/gems/ruby-$RUBY_VERSION-$rubminor@appdirector-gemset/gems/passenger-* | cut -d '-' -f5`
sed -i.bak "/LoadModule version_module/ a LoadModule passenger_module /usr/local/rvm/gems/ruby-$RUBY_VERSION-$rubminor@appdirector-gemset/gems/passenger-$passengerver/ext/apache2/mod_passenger.so" /etc/httpd/conf/httpd.conf

# Add the Passenger/mod_rails config to the httpd.conf file 
echo "Adding the Passenger config to the httpd.conf file"
cat >> /etc/httpd/conf/httpd.conf <<APACHE

#
# Passenger/mod_rails config
PassengerRoot /usr/local/rvm/gems/ruby-$RUBY_VERSION-$rubminor@appdirector-gemset/gems/passenger-$passengerver
PassengerRuby /usr/local/rvm/wrappers/ruby-$RUBY_VERSION-$rubminor@appdirector-gemset/ruby

APACHE

# Restart Apache 
echo "Restarting Apache httpd"
service httpd restart 

# Cleanup the runfile from the railsuser's home dir
echo "Removing the runfile script" 
rm /home/railsuser/runfile
rm /home/railsuser/$tmpglobalconf

