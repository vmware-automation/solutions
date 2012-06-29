#!/bin/sh
# vFabric ApplicationDirector Sample CONFIG script for vFabric 5.1 tc Server

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
# name of the new tc server instance to be created      INSTANCE_NAME [String]
# which java to use                                     JAVA_HOME [String]
# minimum version of java required                      REQUIRED_VERSION [String]
# application war to be downloaded and deployed         WAR [Content]
# tc Server template used to create new instance        TCSERVER_TEMPLATE [String]
# application name if different from war                APPLICATION_NAME [String]

# From ApplicationDirector - Import and source global configuration
. $global_conf

get_JAVAHOME() {
   # Transform the required version string into a number that can be used in comparisons
   REQUIRED_VERSION=`echo $REQUIRED_VERSION | sed -e 's;\.;0;g'`

   # Check JAVA_HOME directory to see if Java version is adequate
   if [ $JAVA_HOME ]
   then
      JAVA_EXE=$JAVA_HOME/bin/java
      $JAVA_EXE -version 2> tmp.ver
      VERSION=`cat tmp.ver | grep "java version" | awk '{ print substr($3, 2, length($3)-2); }'`
      rm tmp.ver
      VERSION=`echo $VERSION | awk '{ print substr($1, 1, 3); }' | sed -e 's;\.;0;g'`
      if [ $VERSION ]
      then
         if [ $VERSION -ge $REQUIRED_VERSION ]
         then
            JAVA_HOME=`echo $JAVA_EXE | awk '{ print substr($1, 1, length($1)-9); }'`
         else
            JAVA_HOME=
         fi
      else
        JAVA_HOME=
      fi
   fi

   # If the existing JAVA_HOME directory is adequate, then leave it alone
   # otherwise, use 'locate' to search for other possible java candidates and
   # check their versions.
   if [ $JAVA_HOME ]
   then
    :
   else
     for JAVA_EXE in `locate bin/java | grep java$ | xargs echo`
     do
        if [ $JAVA_HOME ] 
        then
            :
        else
            $JAVA_EXE -version 2> tmp.ver 1> /dev/null
            VERSION=`cat tmp.ver | grep "java version" | awk '{ print substr($3, 2, length($3)-2); }'`
            rm tmp.ver
            VERSION=`echo $VERSION | awk '{ print substr($1, 1, 3); }' | sed -e 's;\.;0;g'`
            if [ $VERSION ]
            then
                if [ $VERSION -ge $REQUIRED_VERSION ]
                then
                    JAVA_HOME=`echo $JAVA_EXE | awk '{ print substr($1, 1, length($1)-9); }'`
                fi
            fi
        fi
     done
   fi

   # If the correct Java version is detected, then export the JAVA_HOME environment variable
   if [ $JAVA_HOME ]
   then
     export JAVA_HOME
     echo "JAVA_HOME is set to: $JAVA_HOME"
   fi
}

# The example deploys the Spring Travel Application which is available via the ApplicationDirector vApp
# in your ApplicationDirector example deployment, create a property called 'WAR' with type 'Content' and set the property
# value to: http://${darwin.server.ip}/artifacts/app-components/spring-travel/swf-booking-mvc-2.0.3.RELEASE.war
# if you wish to change the application, simply modify the value of the location of the WAR file, and optionally the 
# value of APPLICATION_NAME property. 

set -e

export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export HOME=/root
export TCSERVER_PACKAGE=${TCSERVER_PACKAGE:="vfabric-tc-server-standard"}
export TCSERVER_HOME=${TCSERVER_HOME:="/opt/vmware/vfabric-tc-server-standard"}

# Any of the following may be set as Properties in your service definition, and if enabled, may be overwritten 
# in your application blueprint.
export JAVA_HOME=${JAVA_HOME:="/usr"}
export INSTANCE_NAME=${INSTANCE_NAME:="vfabric-tc-server-sample"}
export TCSERVER_TEMPLATE=${TCSERVER_TEMPLATE:="nio"}
export REQUIRED_VERSION=${REQUIRED_VERSION:="1.5"}
export APPLICATION_NAME=${APPLICATION_NAME:="travel"}
export WAR=${WAR:="http://${darwin.server.ip}/artifacts/app-components/spring-travel/swf-booking-mvc-2.0.3.RELEASE.war"}

#ensure we have the right java version
get_JAVAHOME

if [ -f ${TCSERVER_HOME}/${INSTANCE_NAME} ]; then
    echo "ERROR: The directory ${TCSERVER_HOME}/${INSTANCE_NAME} already exists and we will not overwrite it. Exiting script"
    exit
fi

# create a simple tc Server instance.
if [ -f ${TCSERVER_HOME}/tcruntime-instance.sh ]; then
    # create the new instance in the tc Server install directory
    ${TCSERVER_HOME}/tcruntime-instance.sh create ${INSTANCE_NAME} -t ${TCSERVER_TEMPLATE} --instance-directory ${TCSERVER_HOME}
    if [ -f ${TCSERVER_HOME}/${INSTANCE_NAME}/bin/tcruntime-ctl.sh ]; then
        cd ${TCSERVER_HOME}/${INSTANCE_NAME}/webapps
        cp ${WAR} ${TCSERVER_HOME}/${INSTANCE_NAME}/webapps/${APPLICATION_NAME}.war
        echo "COMPLETED: A new tc Server instance has been created in ${TCSERVER_HOME}/${INSTANCE_NAME}"
        echo "To start this instance: ${TCSERVER_HOME}/${INSTANCE_NAME}/bin/tcruntime-ctl.sh start"
    fi
else  
    echo "ERROR: ${TCSERVER_PACKAGE} has been not been installed in /opt/vmware/${TCSERVER_PACKAGE}"
    echo "ERROR: please run tc-server installation script first. Exiting CONFIGURE"
    exit
fi

