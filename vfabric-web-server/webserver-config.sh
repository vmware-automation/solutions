#!/bin/sh

# vFabric ApplicationDirector Sample CONFIG script for vFabric 5.1 Web Server

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
# List of tc Server instances (IPs) to proxy to        http_node_ips [Array]
# value: all(tcServerInstance:NIC0_ip)   
# IP address of the webserver (to set in conf)         webserver_ip [String]
# value: self:ip    
#                                                            
# OPTIONAL PROPERTIES:
# Property Description:                                Property Name settable in blueprint:
# --------------------------------------------------------------------------------------------
# name of the new web server instance to be created    INSTANCE_NAME [String]
# The WebServer is will be listening on port 80        HTTP_PROXY_PORT [String]
# The tc Server instances to which we are proxying
# are listening on port 8080                           HTTP_NODE_PORT [String]
# The load balancer method to be used is byrequests    LOAD_BALANCER_METHOD [String]
# Virtual host information written to configuration
# file httpd-vfabric-sample.conf                       WEBSERVER_CONF_FILE [String]
# The application to which we are proxying is
# the Spring travel sample application which 
# is available from the ApplicationDirector server     APPLICATION_NAME [String]

# From ApplicationDirector - Import and source global configuration  
. $global_conf

set -e

export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export HOME=/root
export WEBSERVER_HOME="/opt/vmware/vfabric-web-server"

# Any of the following may be set as Properties in your service definition, and if enabled, may be overwritten 
# in your application blueprint.
export INSTANCE_NAME=${INSTANCE_NAME:="vfabric-webserver-sample"}
export WEBSERVER_CONF_FILE=${WEBSERVER_CONF_FILE:="httpd-vfabric-sample.conf"}
export LOAD_BALANCER_METHOD=${LOAD_BALANCER_METHOD:="byrequests"} # options are: byrequests, bytraffic, bybusyness
export HTTP_NODE_PORT=${HTTP_NODE_PORT:=8080} # property value for tc Server(s) listen port
export HTTP_PROXY_PORT=${HTTP_PROXY_PORT:=80} # property value for virtual host listen port
export APPLICATION_NAME=${APPLICATION_NAME:="travel"}

# check to see if the webserver instance already exists.  If so, we'll just exit
if [[ -d ${WEBSERVER_HOME}/${INSTANCE_NAME} ]]; then
    echo "ERROR: The webserver instance ${WEBSERVER_HOME}/${INSTANCE_NAME} already exists, and will not be overwritten"
    echo "Exiting script"
    exit
fi

# determine the webserver VMs IP - this can either be a property specified in the service catalog (i.e."self:ip"), 
# or we can determine it here
if [ "${webserver_ip}" == "" ]; then
    webserver_ip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
fi

# create the new webserver instance
cd ${WEBSERVER_HOME}
${WEBSERVER_HOME}/newserver.pl --server=${INSTANCE_NAME} --rootdir=${WEBSERVER_HOME} --quiet

# create and include configuration file for the example deployment (deploys ${APPLICATION_NAME)
# http_node_ips is a property that will need to be set in the vFabric-web-server service catalog entry as follows:
## name: http_node_ips
## type: Array
## blueprint value: all(tcServerInstances:NIC0_ip) 
### where 'tcServerInstances' is the name given to your tc Server blueprint component

echo "Include conf/extra/${WEBSERVER_CONF_FILE}" >> ${WEBSERVER_HOME}/${INSTANCE_NAME}/conf/httpd.conf

if [ ! "$http_node_ips" == "None" ]; then
    SUBSTR=""
    for (( i = 0 ; i < ${#http_node_ips[@]} ; i++ )); do
         SUBSTR="$SUBSTR"$'\n'"BalancerMember http://${http_node_ips[$i]}:${HTTP_NODE_PORT}"
    done
    SUBSTR_REVERSE=""
    for (( i = 0 ; i < ${#http_node_ips[@]} ; i++ )); do
         SUBSTR_REVERSE="$SUBSTR_REVERSE"$'\n'"ProxyPassReverse /${APPLICATION_NAME} http://${http_node_ips[$i]}:${HTTP_NODE_PORT}/${APPLICATION_NAME}"
    done
    cat >> ${WEBSERVER_HOME}/${INSTANCE_NAME}/conf/extra/${WEBSERVER_CONF_FILE} << EOF
<VirtualHost *:${HTTP_PROXY_PORT}>
  ServerName $webserver_ip:${HTTP_PROXY_PORT}

  <Location /balancer-manager>
    SetHandler balancer-manager
    Order Deny,Allow
    Deny from all
    Allow from $webserver_ip
  </Location>

  <Proxy balancer://samplecluster>
$SUBSTR
     ProxySet lbmethod=${LOAD_BALANCER_METHOD}
  </Proxy>
  ProxyPass /${APPLICATION_NAME} balancer://samplecluster/${APPLICATION_NAME}
$SUBSTR_REVERSE
</VirtualHost>
EOF
fi
echo "COMPLETED:  A new vfabric-web-server instance has been created in ${WEBSERVER_HOME}/${INSTANCE_NAME}"
echo "You can view the configuration in ${WEBSERVER_HOME}/${INSTANCE_NAME}/conf/extra/${WEBSERVER_CONF_FILE}"