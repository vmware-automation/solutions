#!/bin/sh
# vFabric ApplicationDirector Sample START script for vFabric tc Server

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
# application name if different from war                APPLICATION_NAME [String]

# From ApplicationDirector - Import and source global configuration
. $global_conf

# This sample script simply starts the tc Server instance created in the tcserver-config.sh sample script. 
# this example server instance was created using the default tc Server port, and deploys the travel app from ApplicationDirector

set -e

export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export HOME=/root
export TCSERVER_HOME=${TCSERVER_HOME:="/opt/vmware/vfabric-tc-server-standard"}

# Any of the following may be set as Properties in your service definition, and if enabled, may be overwritten 
# in your application blueprint.
export JAVA_HOME=${JAVA_HOME:="/usr"}
export INSTANCE_NAME=${INSTANCE_NAME:="vfabric-tc-server-sample"}
export APPLICATION_NAME=${APPLICATION_NAME:="travel"}


IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

if [ -f ${TCSERVER_HOME}/${INSTANCE_NAME}/bin/tcruntime-ctl.sh ]; then
    ${TCSERVER_HOME}/${INSTANCE_NAME}/bin/tcruntime-ctl.sh start
    IS_RUNNING=`/opt/vmware/vfabric-tc-server-standard/vfabric-tc-server-sample/bin/tcruntime-ctl.sh status | grep Status | awk -F: '{ print $2 }'`
    if [[ "${IS_RUNNING}" == *"NOT RUNNING"* ]]; then
        echo "ERROR: ${TCSERVER_HOME}/${INSTANCE_NAME} is NOT RUNNING. Please check the logs in ${TCSERVER_HOME}/${INSTANCE_NAME}/logs for more information"
    else
        echo "COMPLETED: The status of your new tc Server instance is: ${IS_RUNNING}"
        echo "Your application can be accessed at http://${IP}:8080/{$APPLICATION_NAME}"
    fi
fi
