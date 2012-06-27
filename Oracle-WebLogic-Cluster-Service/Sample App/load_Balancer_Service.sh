#!/bin/sh

env > /tmp/env.txt

BEA_HOME="$wl_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"

cp $war_file $webapps_dir

url="t3://"$admin_ip":"$admin_http_port

cat << EOF > $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/startcluster.py
print 'STARTING THE SCRIPT ....'
username = '$weblogic_user'
password = '$admin_password'
admin_url = '$url'
print 'CONNECTING TO THE ADMIN SERVER...'
connect(username,password,admin_url)

start('cluster00', 'Cluster')
start('cluster01', 'Cluster')
start('cluster02', 'Cluster')
EOF

# SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES
echo "SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES..."
cd $WLS_INSTALL_DIR/server/bin
. ./setWLSEnv.sh
echo "ENVIRONMENTAL VARIABLES SET SUCCESSFULLY"
java weblogic.WLST $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/startcluster.py
echo "CLUSTERS STARTED SUCCESSFULLY"

# DEPLOYING A DEMO APPLICATION ON THE WEBLOGIC SERVER
. $WLS_INSTALL_DIR/samples/domains/$domain_name/bin/setDomainEnv.sh
java weblogic.Deployer -adminurl $url -user weblogic -password $admin_password -deploy -name proxyapp -appversion VersionA -source $webapps_dir/proxyapp.war -id ProxyApp01 -targets AdminServer 
echo "SAMPLE APPLICATION DEPLOYED SUCCESSFULLY"

# STARING A DEMO APPLICATION ON THE WEBLOGIC SERVER
java weblogic.Deployer -adminurl $url -user weblogic -password $admin_password -start -name proxyapp -appversion VersionA -targets AdminServer
echo "SAMPLE APPLICATION STARTED SUCCESSFULLY"