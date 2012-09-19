#!/bin/sh
# vFabric ApplicationDirector Sample START script for vFabric 5.1 RabbitMQ Server

# This example uses the values posted below as defaults.   To change any of these
# values, add the Property Name as shown below as individual properties in your 
# service definition in the ApplicationDirector Catalog.   The value specified after
# the Property name is the Type to use for the property (i.e. String, Content, Array etc)
# There are two types of properties for this script: Required and Optional.  Both are 
# listed below.
#
# REQUIRED PROPERTIES:
# These are the properties you must add in order for this sample script to work. The property
# is added when you create your service definition in the ApplicationDirector Catalog.  
# Property Description:                                Property Value settable in blueprint [type]:
# --------------------------------------------------------------------------------------------
# Location of global configuration data                global_conf [Content]
# value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf   
#                                                            
# OPTIONAL PROPERTIES:
# Property Description:                                 Property Name settable in blueprint:
# --------------------------------------------------------------------------------------------

# From ApplicationDirector - Import and source global configuration
. $global_conf


export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export HOME=/root
export RMQ_HOME="/opt/vmware"
export RMQ_PACKAGE=${RMQ_PACKAGE:="vfabric-rabbitmq-server"}
export EULA_LOCATION=${EULA_LOCATION:="http://www.vmware.com/download/eula/vfabric_app-platform_eula.html"}

# pre-set the license agreement for rpm
if [ ! -d "/etc/vmware/vfabric" ]; then
    mkdir -p /etc/vmware/vfabric
fi
echo "setting up vfabric repo"
echo "I_ACCEPT_EULA_LOCATED_AT=${EULA_LOCATION}" >> /etc/vmware/vfabric/accept-vfabric-eula.txt
echo "I_ACCEPT_EULA_LOCATED_AT=${EULA_LOCATION}" >> /etc/vmware/vfabric/accept-vfabric5.1-eula.txt

if [ -f /etc/redhat-release ] ; then
    DistroBasedOn='RedHat'
    DIST=`cat /etc/redhat-release |sed s/\ release.*//`
    REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*// | awk -F. '{ print $1 }'`
else
    echo "Installation only supported on RedHat and CentOS; exiting installation script"
    exit
fi

# Install erlang and vFabric RPM repo
if [ -f /bin/rpm ]; then
   if [ "$REV" == "5" ]; then
      wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
      rpm -Uvh epel-release-5-4.noarch.rpm
      wget -O /etc/yum.repos.d/epel-erlang.repo http://repos.fedorapeople.org/repos/peter/erlang/epel-erlang.repo
      rpm -Uvh --force http://repo.vmware.com/pub/rhel5/vfabric/5.1/vfabric-5.1-repo-5.1-1.noarch.rpm
   elif [ "$REV" == "6" ]; then
      wget http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm
      rpm -Uvh epel-release-6-7.noarch.rpm
      rpm -Uvh --force http://repo.vmware.com/pub/rhel6/vfabric/5.1/vfabric-5.1-repo-5.1-1.noarch.rpm
   else
      echo "Unsupported version: ${REV}; exiting installation"
      exit
   fi
else
   echo "RPM utility not available; exiting installation script"
   exit
fi

if [ "$DistroBasedOn" == "RedHat" ]; then
   if [ "$DIST" == "CentOS" ]; then
      if [ -x /usr/sbin/selinuxenabled ] && /usr/sbin/selinuxenabled; then
         echo 'SELinux is enabled. This may cause installation to fail.'
      fi
   fi
   if [ -f /usr/bin/yum ]; then
      yum -y install erlang --skip-broken
      yum -y -v install ${RMQ_PACKAGE}
   else
      echo "ERROR! Unable to locate yum in ${PATH}; exiting installer"
      exit
   fi
fi

