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

# INSTALLATION OF IHS -- START
mkdir -p $IHSINSTALLERLOCATION
cd $IHSINSTALLERLOCATION

echo "DOWNLOADING IHS INSTALLER..."
wget http://10.20.140.69:8080/ihs/ihs.6100.linux.ia32.tar
check_error "ERRORS DURING DOWNLOADING THE IHS"
echo "UNTARING THE tar file..."
tar -xvf ihs.6100.linux.ia32.tar
check_error "ERRORS DURING EXTRACTING IHS INSTALLER.";

echo "CREATING RESPONSE FILE..."
cat <<EOF> $IHSINSTALLERLOCATION/IHS_6.1.0.0/IHS/ihsResponsefile.txt
-OPT silentInstallLicenseAcceptance="true"
-OPT allowNonRootSilentInstall=true
-OPT disableOSPrereqChecking="true"

-OPT installLocation="$IHS_INSTALL_LOCATION"
-OPT installGSKit="true"

-OPT httpPort="$HTTP_PORT"
-OPT adminPort="$ADMIN_PORT"

-OPT createAdminAuth="true"
-OPT adminAuthUser="$IHS_USERNAME"
-OPT adminAuthPassword="$IHS_PASSWORD"
-OPT adminAuthPasswordConfirm="$IHS_PASSWORD"

-OPT runSetupAdmin="false"
-OPT createAdminUserGroup=false

-OPT installHttpService="true"
-OPT installAdminService="true"
-OPT installAfpa="true"

-OPT installPlugin="false"
-OPT webserverDefinition="$WEBSERVER_DEFINATION_NAME"
-OPT washostname="$WASHOSTNAME"
EOF

echo "INSTALLING IHS 6.1.0.0..."
cd $IHSINSTALLERLOCATION/IHS_6.1.0.0/IHS
java -jar setup.jar -silent -options "ihsResponsefile.txt"
check_error "ERRORS DURING INSTALLATION IHS"
echo "IHS INSTALLED SUCCESSFULLY"
# INSTALLATION OF IHS -- END

# INSTALLATION OF IHS's PLUGIN -- START
mkdir -p $PLUGININSTALLERLOCATION
cd $PLUGININSTALLERLOCATION

echo "DOWNLOADING THE PLUGIN FOR IHS..."
wget http://10.20.140.69:8080/plug-in/trial_plugins_linux.ia32.tar.gz
check_error "ERRORS DURING DOWNLOADING HE PLUGIN FOR IHS"
gunzip trial_plugins_linux.ia32.tar.gz
check_error "ERRORS DURING EXTRACTING PLUGIN FOR IHS.";
tar -xvf trial_plugins_linux.ia32.tar
check_error "ERRORS DURING EXTRACTING THE PLUGINS FOR IHS INSTALLER.";

echo "CREATING RESPONSE FILE FOR PLUGINS..."
cat <<EOF> $PLUGININSTALLERLOCATION/plugin/pluginResponsefile.txt
-OPT allowNonRootSilentInstall="true"
-OPT silentInstallLicenseAcceptance="true"
-OPT disableOSPrereqChecking="true"

-OPT installType="local"
-OPT installLocation="$PLUGIN_INSTALL_LOCATION"
-OPT wasExistingLocation="$WAS_HOME"

-OPT webServerSelected="ihs"
-OPT ihsAdminPort="$ADMIN_PORT"
-OPT ihsAdminUserID="$IHS_USERNAME"
-OPT webServerConfigFile1="$IHS_INSTALL_LOCATION/conf/httpd.conf"

-OPT webServerPortNumber="$HTTP_PORT"

-OPT webServerDefinition="$WEBSERVER_DEFINATION_NAME"
-OPT pluginCfgXmlLocation="$PLUGIN_INSTALL_LOCATION/config/${WEBSERVER_DEFINATION_NAME}/plugin-cfg.xml"

-OPT wasMachineHostName="$WASHOSTNAME"
-OPT mapWebserverToApplications="true"

-OPT webServerHostName="${NODE_NAME}.eng.vmware.com"
-OPT profileName="$PROFILE_NAME"
EOF

echo "INSTALLING PLUGINS FOR IHS..."
cd $PLUGININSTALLERLOCATION/plugin
java -jar setup.jar -silent -options "pluginResponsefile.txt"
check_error "ERRORS DURING INSTALLATION IPLUGINS FOR IHS"
echo "IHS'S PLUGIN INSTALLED SUCCESSFULLY"
# INSTALLATION OF IHS's PLUGIN -- END