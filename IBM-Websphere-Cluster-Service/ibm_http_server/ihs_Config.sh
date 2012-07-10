#!/bin/bash

export WAS_HOME=/opt/vmware-appdirector/IBM/WebSphere/AppServer
export JAVA_HOME=$WAS_HOME/java	
export PATH=$JAVA_HOME/bin:$WAS_HOME/bin:$PATH

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
IHS_INSTALL_LOCATION="$INSTALL_BASE/HTTPServer"
PLUGIN_INSTALL_LOCATION="$IHS_INSTALL_LOCATION/Plugins"
IHSINSTALLERLOCATION="$INSTALL_BASE/ihsinstaller"
PLUGININSTALLERLOCATION="$IHSINSTALLERLOCATION/plugininstaller"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"
IHS_USERNAME="$ihsadmin_username"
IHS_PASSWORD="$ihsadmin_password"
HTTP_PORT="$ihs_http_port"
ADMIN_PORT="$admin_port"
WASHOSTNAME="$washostname"
WEBSERVER_DEFINATION_NAME="$webserver_definition_name"
PROFILE_NAME="$profile_name"
NODE_NAME="${node_name[0]}"

# FUNCTION TO DISPLAY ERROR AND EXIT
function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

# CONFIGURATION OR CREATION OF WEB SERVER DEFINITION -- START
cd $INSTALL_LOCATION/bin/
$INSTALL_LOCATION/profiles/$PROFILE_NAME/bin/setupCmdLine.sh
echo "CONFIGURING/CREATING WEB SERVER DEFINITION..."
./wsadmin.sh -user $ADMIN_USERNAME -password $ADMIN_PASSWORD -f $INSTALL_LOCATION/bin/configureWebserverDefinition.jacl $WEBSERVER_DEFINATION_NAME IHS $IHS_INSTALL_LOCATION $IHS_INSTALL_LOCATION/conf/httpd.conf $HTTP_PORT MAP_ALL $PLUGIN_INSTALL_LOCATION unmanaged ${NODE_NAME}_node  ${NODE_NAME}.eng.vmware.com linux $ADMIN_PORT $IHS_USERNAME $IHS_PASSWORD
check_error "ERRORS DURING CONFIGURING/CREATING WEB SERVER DEFINITION"

# GENERATING PLUGIN
cat <<EOF>$IHSINSTALLERLOCATION/GeneratePlugin.py
generator = AdminControl.completeObjectName('type=PluginCfgGenerator,*')
print 'GENERATING PLUG-CFG.XML FILE...'
AdminControl.invoke(generator,'generate',"$INSTALL_LOCATION/profiles/$PROFILE_NAME/config Cell01 ${NODE_NAME}_node $WEBSERVER_DEFINATION_NAME true")
print 'PROPAGATING PLUG-CFG.XML FILE...'
AdminControl.invoke(generator,'propagate',"$INSTALL_LOCATION/profiles/$PROFILE_NAME/config Cell01 ${NODE_NAME}_node $WEBSERVER_DEFINATION_NAME")
EOF

./wsadmin.sh -lang jython -user $ADMIN_USERNAME -password $ADMIN_PASSWORD -f $IHSINSTALLERLOCATION/GeneratePlugin.py
check_error "ERRORS DURING GENERATING PLUGIN"

cd $PLUGIN_INSTALL_LOCATION/config/$WEBSERVER_DEFINATION_NAME
rm -rf plugin-cfg.xml
cp /$INSTALL_LOCATION/profiles/$PROFILE_NAME/config/cells/Cell01/nodes/${NODE_NAME}_node/servers/$WEBSERVER_DEFINATION_NAME/plugin-cfg.xml $PLUGIN_INSTALL_LOCATION/config/$WEBSERVER_DEFINATION_NAME
echo "GENERATING PLUG-CFG.XML FILE -- DONE"
# CONGURATION OR CREATION OF WEB SERVER DEFINITION -- END