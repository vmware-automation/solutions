#!/bin/bash

# vFabric ApplicationDirector Sample START script for vFabric 5.1 Web Server 

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
# IP address of the webserver (to set in conf)         webserver_ip [String]
# value: self:ip    
#                                                            
# OPTIONAL PROPERTIES:
# Property Description:                                Property Name settable in blueprint:
# --------------------------------------------------------------------------------------------
# name of the new web server instance to be created    INSTANCE_NAME [String]
# The WebServer is will be listening on port 80        HTTP_PROXY_PORT [String]
# The application to which we are proxying is
# the Spring travel sample application which 
# is available from the ApplicationDirector server     APPLICATION_NAME [String]

# From ApplicationDirector - Import and source global configuration

# From ApplicationDirector - Import global conf 
. $global_conf

export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export HOME=/root
export WEBSERVER_HOME="/opt/vmware/vfabric-web-server"

# Any of the following may be set as Properties in your service definition, and if enabled, may be overwritten 
# in your application blueprint.
export INSTANCE_NAME=${INSTANCE_NAME:="vfabric-webserver-sample"}
export HTTP_PROXY_PORT=${HTTP_PROXY_PORT:=80} # property value for virtual host listen port
export APPLICATION_NAME=${APPLICATION_NAME:="travel"}

if [ "${webserver_ip}" == "" ]; then
    webserver_ip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
fi

if [[ ! -f ${WEBSERVER_HOME}/${INSTANCE_NAME}/bin/httpdctl ]]; then
    echo "ERROR: Unable to locate ${WEBSERVER_HOME}/${INSTANCE_NAME}/bin/httpdctl"
    echo "Please create the instance ${WEBSERVER_HOME}/${INSTANCE_NAME} first. Exiting script"
    exit
fi

IS_RUNNING=`netstat -apn | grep :::80 | grep httpd.worker`
if [[ $? == 0 ]]; then
    echo "ERROR: The webserver instance ${WEBSERVER_HOME}/${INSTANCE_NAME} is already running. Exiting script"
    exit
fi

# verify the configuration 
${WEBSERVER_HOME}/${INSTANCE_NAME}/bin/httpdctl configtest
if [[ $? == 0 ]]; then
    ${WEBSERVER_HOME}/${INSTANCE_NAME}/bin/httpdctl start
else
    echo "ERROR: There's an issue with the configuration for ${WEBSERVER_HOME}/${INSTANCE_NAME}"
    echo "Please verify the configuration. Exiting WebServer startup"
    exit
fi
# verify we have a running server
wget -O webserver_index.html http://${webserver_ip}:${HTTP_PROXY_PORT}
SUCCESS=`cat webserver_index.html | grep "successfully setup and started vFabric Web Server"`
if [[ "$SUCCESS" == "" ]]; then
    echo "ERROR: There was an error starting webserver instance ${WEBSERVER_HOME}/${INSTANCE_NAME}"
    echo "Please see the log files in ${WEBSERVER_HOME}/${INSTANCE_NAME}/logs for more information"
    exit
else
    echo "COMPLETED: webserver instance ${WEBSERVER_HOME}/${INSTANCE_NAME} is RUNNING"
    echo "View your app at: http://${webserver_ip}:${HTTP_PROXY_PORT}/${APPLICATION_NAME}"
fi

