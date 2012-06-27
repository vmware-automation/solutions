#!/bin/bash

# SETTING ENVIRONMENT VARIABLES
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export http_proxy=http://proxy.vmware.com:3128
export JAVA_HOME=/usr/java/jre-vmware

# TO SET IPTABLES OFF
/etc/init.d/iptables save
/etc/init.d/iptables stop

# Function To Display Error and Exit
function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

# MAKING CHAMGES TO THE SSHD_CONFIG FILE
echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
/etc/init.d/sshd restart
service sshd start 
chkconfig sshd on 

# ADDING THE DEDICATED GROUP AND HADOOP USER
groupadd $GROUP_NAME
useradd -g $GROUP_NAME -s /bin/bash -d /home/$USER_NAME $USER_NAME

# CREATING INSTALLATION DIRECTORY
mkdir -p $INSTALL_PATH
cd $INSTALL_PATH

# INSTALLING EXPECT PACKAGE
if [ -f /etc/redhat-release ] ; then
	DistroBasedOn='RedHat'
	DIST=`cat /etc/redhat-release |sed s/\ release.*//`
	REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
elif [ -f /etc/SuSE-release ] ; then
	DistroBasedOn='SuSe'
	REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
elif [ -f /etc/debian_version ] ; then
	DistroBasedOn='Debian'
	DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
	REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
fi

# INSTALLING EXPECT PACKAGE
if [ $DistroBasedOn == "Debian" ] ; then
	echo $DistroBasedOn
    echo $http_proxy
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y linux-firmware < /dev/console > /dev/console 
    # Install MySQL package 
    apt-get update -y
    apt-get -f -y install
    apt-get -f -y install expect --fix-missing
elif [ $DistroBasedOn == "RedHat" ] ; then 
	yum --nogpgcheck --noplugins -y install expect
elif [ "$DistroBasedOn" = "SuSe" ] ; then
	echo $DistroBasedOn
	zypper rr repo-oss
	zypper ar -f http://download.opensuse.org/distribution/11.2/repo/oss/ repo-oss
	zypper --non-interactive --no-gpg-checks ref
	zypper --non-interactive --no-gpg-checks install expect            
fi

check_error "UNABLE TO INSTALL EXPECT PACKAGE.";

# CREATING THE CHANGE USER PASSWORD EXP FILE
mkdir $INSTALL_PATH/tmp

cat <<ENDpassword > $INSTALL_PATH/tmp/password.exp
#!/usr/bin/expect
spawn passwd hadoop
expect "New password:"
send "$PASSWORD\r"
expect "Retype new password:"
send "$PASSWORD\r"
expect eof
ENDpassword

check_error "UNABLE TO CREATE password.exp FILE.";

# CHANGING THE PERMISSION OF THE EXP FILE
chmod 777 $INSTALL_PATH/tmp/password.exp

# SETTING UP THE PASSWORD FOR HADOOP USER
$INSTALL_PATH/tmp/password.exp

# DOWNLOADING AND EXTRACTING THE INSTALLER TAR BALL 
wget $DOWNLOAD_URL
DOWNLOAD=${DOWNLOAD_URL##*/}
tar -xzf ./$DOWNLOAD
check_error "UNABLE TO EXTRACTION OF HADOOP TAR BALL.";

echo "EXTRACTION OF HADOOP TAR BALL COMPLETED"