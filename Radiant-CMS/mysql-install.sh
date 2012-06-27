#!/bin/bash
# Import global conf 
. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

# Tested on CentOS
if [ -x /usr/sbin/selinuxenabled ] && /usr/sbin/selinuxenabled; then
    # SELinux can be disabled by setting "/usr/sbin/setenforce Permissive"
    echo 'SELinux in enabled on this VM template.  This service requires SELinux to be disabled to install successfully'
    exit 1
fi

if [ "x$OS" != "x" ] && [ $OS = 'Ubuntu' ]; then
    # Fix the linux-firmware package 
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y linux-firmware < /dev/console > /dev/console 
    # Install MySQL package 
    apt-get install -y mysql-server
else 
    yum --nogpgcheck --noplugins -y install mysql-server
fi

