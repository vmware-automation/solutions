#!/bin/bash

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
PROFILE_NAME="$profile_name"
PROFILE_PATH="$INSTALL_BASE/WebSphere/AppServer/profiles/$PROFILE_NAME"

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

## STARTING THE DEPLOYMENT MANAGER
echo "STARTING DEPLOYMENT MANAGER $PROFILE_NAME..."
cd $PROFILE_PATH/bin 
./startManager.sh
check_error "ERROR WHILE STARTING THE DEPLOYMENT MANAGER"
echo "DEPLOYMENT MANAGER $PROFILE_NAME STARTED SUCCESSFULLY"