#!/bin/sh
# vFabric ApplicationDirector Sample START script for vFabric GemFire 

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
# which java to use                                     JAVA_HOME [String]
# Installed Location of GemFire                         SQLFIRE_HOME [String]
# GemFire version installed (default is 663)            SQLFIRE_VERSION [String]

# From ApplicationDirector - Import and source global configuration
# . $global_conf

# This sample script simply starts a CacheServer from using the cacheserver service call setup from using the RPM install. 

set -e
echo "######################################################################"
echo "#"
echo "# Starting vFabric SQLfire From Application Director"
echo "#"
echo "######################################################################"

export PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export VMWARE_HOME=/opt/vmware
export SQLFIRE_PACKAGE=vfabric-sqlfire
export SQLFIRE_VERSION=${SQLFIRE_VERSION:="103"}
export SQLFIRE_HOME=${SQLFIRE_HOME:="$VMWARE_HOME/$SQLFIRE_PACKAGE/vFabric_SQLFire_$SQLFIRE_VERSION"}

# Any of the following may be set as Properties in your service definition, and if enabled, may be overwritten 
# in your application blueprint.
export JAVA_HOME=${JAVA_HOME:="/usr"}

if [ -f ${SQLFIRE_HOME}/bin/sqlf ]; then
    echo "Creating Directories For New SQLFire Cluster and Locator"
    cd ${SQLFIRE_HOME}
    su sqlfire -c 'rm -rf appd_locator appd_server1 appd_server2'
    su sqlfire -c 'mkdir appd_server1'
    su sqlfire -c 'mkdir appd_server2'
    su sqlfire -c 'mkdir appd_locator'
    echo "Starting SQLFire Locator"
    cd ${SQLFIRE_HOME}/bin
    su sqlfire -c 'sqlf locator start -dir=${SQLFIRE_HOME}/appd_locator -peer-discovery-address=127.0.0.1 -peer-discovery-port=10101 -client-bind-address=127.0.0.1 -client-port=1527'
    status=`su sqlfire -c 'sqlf locator status -dir=${SQLFIRE_HOME}/appd_locator | grep running'`
    if [ -n "$status" ]; then
      echo "SQLFire Locator Started"
    else
      echo "SQLFire Locator Failed to start"
      exit 1
    fi
    echo "Starting SQLFire Server1"
    su sqlfire -c 'sqlf server start -dir=${SQLFIRE_HOME}/appd_server1 -locators=127.0.0.1[10101] -client-bind-address=127.0.0.1 -client-port=1528'
    status=`su sqlfire -c 'sqlf server status -dir=${SQLFIRE_HOME}/appd_server1 | grep running'`
    if [ -n "$status" ]; then
      echo "SQLFire Server1 Started"
    else
      echo "SQLFire Server1 Failed to start"
      exit 1
    fi
    echo "Starting SQLFire Server2"
    su sqlfire -c 'sqlf server start -dir=${SQLFIRE_HOME}/appd_server2 -locators=127.0.0.1[10101] -client-bind-address=127.0.0.1 -client-port=1529'
    status=`su sqlfire -c 'sqlf server status -dir=${SQLFIRE_HOME}/appd_server2 | grep running'`
    if [ -n "$status" ]; then
      echo "SQLFire Server2 Started"
    else
      echo "SQLFire Server2 Failed to start"
      exit 1
    fi
    cd ${SQLFIRE_HOME}/quickstart
    echo "Loading Data Into Tables"
    su sqlfire -c 'sqlf run -file=ToursDB_schema.sql'
    su sqlfire -c 'sqlf run -file=loadTables.sql'
else
    echo "ERROR! SQLFire executable not found in ${SQLFIRE_HOME}; Exiting"
    exit
fi
echo "######################################################################"
echo "#"
echo "# vFabric SQLfire Start Script Finished"
echo "#"
echo "######################################################################"
