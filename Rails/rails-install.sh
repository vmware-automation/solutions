#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include

# Try handler, executes command and examines response, exits script if command fails with error -1
cat > $COMMON_INCLUDE <<EOF
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export RVM_HOME=/usr/local/rvm
export RAILSUSER=railsuser
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export FTP_PROXY="$ftp_proxy"
export CC=/usr/bin/gcc44
export CXX=/usr/bin/g++44
EOF
cat >> $COMMON_INCLUDE <<"EOF"
function try {
   local command="$@"
   #echo "Executing: $command"
   eval $command
   if [ $? -ne 0 ]; then
     echo "Command $command failed"
     exit $ERR_EXIT_CODE
   fi
}
EOF
. $COMMON_INCLUDE


# Tell curl to allow unvalidated certs. We are using 
# the rc file instead of -k because of environment issues. 
# (depends on the HOME export above) 
echo 'insecure' >> ~/.curlrc
echo "proxy=$http_proxy" >> ~/.curlrc

try yum -y --nogpgcheck install curl
curl -O http://dl.fedoraproject.org/pub/epel/5/$(uname -i)/epel-release-5-4.noarch.rpm
curl -O http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
try rpm -Uvh *.rpm
try sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/remi.repo

try yum -y --nogpgcheck install gcc44 gcc44-c++ glib2 glib2-devel glibc glibc-devel patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel libjpeg-devel giflib-devel freetype-devel curl curl curl-devel httpd httpd-devel apr-devel apr-util-devel libxml2 libxml2-devel libxslt libxslt-devel sqlite-devel autoconf automake make openssl-devel bzip2-devel compat-libcurl3

# Install Python
echo "Installing Python"
(
try mkdir -p python
cd python
try curl http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz | tar xz --strip-components=1
try ./configure
try make
try make install
)

echo "Installing RVM"
try curl -L https://get.rvm.io | bash -s stable --autolibs=enabled
. $RVM_HOME/scripts/rvm
try rvm get stable --auto-dotfiles

# Create the railsuser and add it to the rvm group 
echo "Creating the $RAILSUSER account"
try /usr/sbin/adduser -G root,rvm $RAILSUSER

# Latest version of rvm creates /etc/profile.d/rvm.sh used by rvm group
#echo '[[ -s "/usr/local/rvm/scripts/rvm" ]] && . "/usr/local/rvm/scripts/rvm"' >> ~${RAILSUSER}/.bashrc

try cat >> /home/$RAILSUSER/.bashrc <<EOF
export APXS2=/usr/sbin/apxs
export HTTPD=/usr/sbin/httpd
export http_proxy="$http_proxy"
export https_proxy="$https_proxy"
export ftp_proxy="$ftp_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export FTP_PROXY="$ftp_proxy"
export CC=$CC
export CXX=$CXX
EOF
try chown -R $RAILSUSER:$RAILSUSER $RVM_HOME

echo "Moving /usr/bin/g++ to g++.orig"
if [[ -e /usr/bin/g++ ]]; then
    mv -f /usr/bin/g++ /usr/bin/g++.orig
fi
ln -nfs $CXX /usr/bin/g++

# Output the set of commands to a file to be run as the railsuser
su - $RAILSUSER -p -c /bin/bash <<EOF
set -e
. $COMMON_INCLUDE
# need to source rvm in non-interactive shell
. $RVM_HOME/scripts/rvm
export HOME=/home/$RAILSUSER
if [[ -z "$http_proxy" || -z "$https_proxy" || -z "$ruby_version" || -z "$rails_version" ]]; then
    echo "Missing required environment variable"
    exit 1
fi

echo 'insecure' >> ~/.curlrc
echo "proxy=$http_proxy" >> ~/.curlrc

# Tell RVM to install Ruby
echo "Installing ruby $ruby_version."
# Force compilation of binary, adds more time but makes sure we have everything in place via --disable-binary
try rvm install $ruby_version --default --debug --disable-binary --verify-downloads 1
echo "Creating appdirector-gemset and setting ruby $ruby_version in it"
try rvm use $ruby_version@appdirector-gemset --create --default

# Install Rails (and all dependencies)
echo "Installing Rails $rails_version"
try gem install rails --version $rails_version --prerelease --env-shebang --force --verbose --no-ri --no-rdoc

# Install passenger
echo "Installing passenger"
try gem install passenger --prerelease --verbose --force --no-ri --no-rdoc
echo "Installing passenger apache2-module"
try passenger-install-apache2-module --auto

# Install exjs
echo "Installing execjs, therubyracer"
try gem install execjs therubyracer --prerelease --verbose --force --no-ri --no-rdoc
EOF
