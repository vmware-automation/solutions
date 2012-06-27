#!/bin/bash

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
WSINSTALLERLOCATION="$INSTALL_BASE/wsinstaller"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"
APP_NAME="$app_name"

# Function To Display Error and Exit
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

# INSTALLATION OF DEFAULT APPLICATION -- START
cat <<EOF>$WSINSTALLERLOCATION/ApplicationInstallation.py
print 'INSTALLING DEFAULT APPLICATION...'
AdminApp.install('$INSTALL_LOCATION/installableApps/DefaultApplication.ear', '[-appname $APP_NAME -cluster cluster_1 -contextroot /DefaultApp -defaultbinding.virtual.host default_host -usedefaultbindings]')
AdminConfig.save()
EOF

cd $INSTALL_LOCATION/bin/
./wsadmin.sh -lang jython -f $WSINSTALLERLOCATION/ApplicationInstallation.py -username $ADMIN_USERNAME -password $ADMIN_PASSWORD
check_error "ERRORS DURING INSTALLING DEFAULT APPLICATION"

sleep 120
echo "STARTING DEPLOYED APPLICATION..."
./wsadmin.sh -lang jython -username $ADMIN_USERNAME -password $ADMIN_PASSWORD -c "AdminApplication.startApplicationOnCluster('$APP_NAME','cluster_1')"
# INSTALLATION OF DEFAULT APPLICATION -- END