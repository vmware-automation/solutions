#!/bin/sh
# vFabric ApplicationDirector Sample INSTALL script for vFabric 5.1 Web Server 

# This example uses the values posted below as defaults.   To change any of these
# values, add the Property Name as shown below as individual properties in your 
# service definition in the ApplicationDirector Catalog.   The value specified after
# the Property name is the Type to use for the property (i.e. String, Content, Array etc)
#
# REQUIRED PROPERTIES:
# These are the properties you must add in order for this sample script to work. The property
# is added when you create your service definition in the ApplicationDirector Catalog.  
# Property Description:                                Property Value settable in blueprint [type]:
# --------------------------------------------------------------------------------------------
# Location of global configuration data                global_conf [Content]
# value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf
#                                                            

# From ApplicationDirector - Import and source global configuration
. $global_conf

set -e

export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export HOME=/root
export WEBSERVER_PACKAGE=${WEBSERVER_PACKAGE:="vfabric-web-server"}
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

# setup repo
if [ -f /bin/rpm ]; then
   if [ "$REV" == "5" ]; then
      rpm --import http://repo.vmware.com/pub/rhel5/vfabric/5.1/RPM-GPG-KEY-VFABRIC-5.1-EL5
      rpm -Uvh http://repo.vmware.com/pub/rhel5/vfabric/5.1/vfabric-5.1-repo-5.1-1.noarch.rpm
   elif [ "$REV" == "6" ]; then
      rpm --import http://repo.vmware.com/pub/rhel6/vfabric/5.1/RPM-GPG-KEY-VFABRIC-5.1-EL6
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
      yum -y -v install ${WEBSERVER_PACKAGE} 
   elif [ -f /usr/bin/yast ]; then
      yast -i ${WEBSERVER_PACKAGE} 
   else
      echo "ERROR! Unable to locate yum or yast in ${PATH}; exiting installer"
      exit
   fi
fi

if [ -f /opt/vmware/${WEBSERVER_PACKAGE}/newserver.pl ]; then
   echo "COMPLETED: ${WEBSERVER_PACKAGE} has been installed in /opt/vmware/${WEBSERVER_PACKAGE}"
   echo "Please see https://www.vmware.com/support/pubs/vfabric-webserver.html for more information"
fi
