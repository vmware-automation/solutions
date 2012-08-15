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

set -e

export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export HOME=/root

if [ -f /usr/sbin/rabbitmqctl ]; then
    service rabbitmq-server start
    IS_RUNNING=`service rabbitmq-server status | grep Status | awk -F: '{ print $2 }'`
    if [[ "${IS_RUNNING}" == *"NOT RUNNING"* ]]; then
        echo "ERROR: RabbitMQ Server is NOT RUNNING."
    else
        echo "COMPLETED: The status of your RabbitMQ Server instance is: ${IS_RUNNING}"
    fi
fi
