#!/bin/bash

## FUNCTION TO DISPLAY ERROR AND EXIT
function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

echo "STARTING E-BUSINESS SERVER"
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
SERVER_NAME="$server_name"

cd $INSTALL_LOCATION/bin
./startServer.sh $SERVER_NAME
check_error "ERRORS DURING STARTING SERVER.";