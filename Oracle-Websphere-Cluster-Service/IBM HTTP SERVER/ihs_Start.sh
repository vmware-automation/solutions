#!/bin/bash

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
IHS_INSTALL_LOCATION="$INSTALL_BASE/HTTPServer"

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

# START OF IHS HTTP SERVER -- START
echo "STARTING THE IHS HTTP SERVER..."
$IHS_INSTALL_LOCATION/bin/apachectl start
check_error "ERRORS DURING STARTING IHS HTTP SERVER"
echo "IHS HTTP SERVER STARTED SUCCESSFULLY"
# START OF IHS HTTP SERVER -- END