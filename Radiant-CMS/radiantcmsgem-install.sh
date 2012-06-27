#!/bin/sh
# Import global conf 
. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root

# Tested on CentOS
if [ -x /usr/sbin/selinuxenabled ] && /usr/sbin/selinuxenabled; then
    # SELinux can be disabled by setting "/usr/sbin/setenforce Permissive"
    echo 'SELinux in enabled on this VM template.  This service requires SELinux to be disabled to install successfully.'
    exit 1
fi

set -e

# Install the MySQL dev headers and Expect 
yum -y --nogpgcheck install mysql-devel 2> >(egrep -v "ftp error|fetch via http" >&2)

export http_proxy=$http_proxy
export https_proxy=$http_proxy

# Change the permissions on the home directory for the Radiant CMS hosting 
echo "Changing permissions on /home/railsuser"
chmod 755 /home/railsuser

# Create a file containing all commands to install Radiant CMS
cat > runfile <<EOF
# ---- Begin Radiant CMS install -----------------------------------------------

set -e
export http_proxy=$http_proxy
export https_proxy=$http_proxy

if [ -z "$http_proxy" ]; then 
	echo "The http_proxy variable is null"
	exit 1 
fi 

# Use the gemset that was created by the Rails install
rvm gemset use appdirector-gemset

# Downgrade RubyGems to prevent mutex related errors. See the following URL for 
# more info: http://stackoverflow.com/questions/5986885/installing-radiant-on-dreamhost
echo "Updating the gem system to 1.5.3"
gem update --system 1.5.3 

# Install the MySQL adapter 
echo "Installing the mysql gem" 
gem install mysql 

# Install Radiant CMS 
echo "Installing the radiant gem" 
gem install radiant 

# Create an instance of Radiant CMS 
echo "Creating the radiant instance"
radiant -d mysql radiant_example
cd radiant_example

# Set the database password for Radiant 
sed -ie "s/password:/password: root/g" config/database.yml

# Create the database
echo "Creating the radiant database using user: '$db_user' and password: '$db_password'"
mysql -u$db_user -p$db_password -e "create database radiant_example_development"

# Populate the database using the empty Radiant template 
echo "Running 'rake db:bootstrap'"
yes | rake db:bootstrap ADMIN_NAME=Administrator ADMIN_USERNAME=admin ADMIN_PASSWORD=radiant DATABASE_TEMPLATE=empty.yml

# ---- End Radiant CMS install ------------------------------------------------
EOF

# Run the file as the railsuser
cp runfile ~railsuser/runfile
chown railsuser ~railsuser/runfile
chmod 755 ~railsuser/runfile

# Run the script as the railsuser to install Radiant CMS 
su -c /home/railsuser/runfile - railsuser

# Add a virtual host for Radiant CMS to Apache via the httpd.conf file 
echo "Adding virtual host to Apache config"
cat >> /etc/httpd/conf/httpd.conf <<APACHE

<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /home/railsuser/radiant_example/public 
    
    RailsEnv development
    <Directory /home/railsuser/radiant_example/public>
        Options FollowSymLinks
        AllowOverride None
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>

APACHE

# Restart Apache 
echo "Restarting httpd"
service httpd restart 

ipaddr=$(ifconfig eth0 | grep 'inet addr' | awk -F: {'print $2'} | awk {'print $1'})
echo "To begin using Radiant CMS, go to http://$ipaddr/ and login with username: admin and password: radiant"

# Cleanup the runfile from the railsuser's home dir
rm ~railsuser/runfile

