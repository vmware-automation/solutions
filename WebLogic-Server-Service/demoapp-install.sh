#!/bin/sh

env > /tmp/env.txt

BEA_HOME="$wl_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"

cp $war_file $webapps_dir

url="t3://"$admin_ip":"$admin_http_port

# SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES
echo "SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES..."
cd $WLS_INSTALL_DIR/server/bin
. ./setWLSEnv.sh
echo "ENVIRONMENTAL VARIABLES SET SUCCESSFULLY"

# DEPLOYING A DEMO APPLICATION ON THE WEBLOGIC SERVER
. $WLS_INSTALL_DIR/samples/domains/$domain_name/bin/setDomainEnv.sh
java weblogic.Deployer -adminurl $url -user weblogic -password $admin_password -deploy -name TestWebApp -appversion VersionA -source $webapps_dir/TestWebApp.war -id TestWebApp01 
echo "SAMPLE APPLICATION DEPLOYED SUCCESSFULLY"

# STARING A DEMO APPLICATION ON THE WEBLOGIC SERVER
java weblogic.Deployer -adminurl $url -user weblogic -password $admin_password -start -name TestWebApp -appversion VersionA 
echo "SAMPLE APPLICATION STARTED SUCCESSFULLY"

