#!/bin/bash

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"

#########PARAMTERS FROM APP DIRECTOR#########
PROFILE_NAME="$profile_name"
PROFILE_PATH="$INSTALL_BASE/WebSphere/AppServer/profiles/$PROFILE_NAME"
NODE_NAME="$node_name"
SERVER_NAME="$server_name"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"

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

echo $SHELL

#CHANGING THE SHELL FROM DASH TO BASH
cd /bin
unlink sh
ln -s /bin/bash sh
echo $SHELL

# CREATING PROFILE
if [ "x${profile_path}" != "x" ]; then
    PROFILE_PATH="$profile_path"
fi
JAVA_HOME="/usr/lib/jvm/jre-1.6.0"
WAS_HOME=$INSTALL_LOCATION

cd $INSTALL_LOCATION/bin
echo "CREATING WEBSPHERE PROFILES"
./manageprofiles.sh  -create -profileName $PROFILE_NAME -serverName $SERVER_NAME -profilePath $PROFILE_PATH -nodeName $NODE_NAME -portsFile $INSTALL_LOCATION/profileTemplates/default/actions/portsUpdate/portdef.props -profileTemplate $INSTALL_LOCATION/profileTemplates/default -adminUserName $ADMIN_USERNAME -adminPassword $ADMIN_PASSWORD
check_error "ERRORS DURING CREATING PROFILE.";