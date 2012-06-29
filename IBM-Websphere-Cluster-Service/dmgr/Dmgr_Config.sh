#!/bin/bash

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
PROFILE_NAME="$profile_name"
PROFILE_PATH="$INSTALL_BASE/WebSphere/AppServer/profiles/$PROFILE_NAME"
NODE_NAME="$node_name"
CELL_NAME="$cell_name"
HOST_NAME="$host_name"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"

## Function To Display Error and Exit
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

JAVA_HOME="/usr/lib/jvm/jre-1.6.0"
WAS_HOME=$INSTALL_LOCATION

## CREATING DEPLOYMENT MANAGER PROFILE
cd $INSTALL_LOCATION/bin
echo "CREATING DEPLOYMENT MANAGER PROFILE $PROFILE_NAME..."
./manageprofiles.sh -create \
-profileName $PROFILE_NAME \
-profilePath $PROFILE_PATH \
-templatePath $INSTALL_LOCATION/profileTemplates/dmgr \
-nodeName $NODE_NAME \
-cellName $CELL_NAME \
-hostname $HOST_NAME \
-adminUserName $ADMIN_USERNAME \
-adminPassword $ADMIN_PASSWORD \
-enableAdminSecurity true \
-isDefault \
-startingPort 50000 \
-validatePorts
	
check_error "ERRORS DURING CREATING PROFILE.";
echo "DEPLOYMENT MANAGER PROFILE $PROFILE_NAME CREATED SUCCESSFULLY"