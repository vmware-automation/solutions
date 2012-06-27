#!/bin/bash

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
NODE_NAME=`hostname`_node
CELL_NAME="$NODE_NAME"_Cell
PROFILE_NAME="$NODE_NAME"_profile
PROFILE_PATH="$INSTALL_LOCATION/profiles/$PROFILE_NAME"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"

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

echo "$dmgr_ip   $dmgr_hostname.eng.vmware.com   $dmgr_hostname " >> /etc/hosts

# CREATING MANAGED NODE PROFILE
cd $INSTALL_LOCATION/bin
echo "CREATING WEBSPHERE PROFILE $PROFILE_NAME"
./manageprofiles.sh -create \
-profileName $PROFILE_NAME \
-profilePath $PROFILE_PATH \
-templatePath $INSTALL_LOCATION/profileTemplates/managed \
-nodeName $NODE_NAME \
-cellName $CELL_NAME \
-enableAdminSecurity false \
-adminUserName $ADMIN_USERNAME \
-adminPassword $ADMIN_PASSWORD
check_error "ERRORS DURING CREATING PROFILE $PROFILE_NAME";

# FEDERATING $PROFILE_NAME WITH DMGR 
echo "FEDERATING $PROFILE_NAME WITH DMGR"
cd $PROFILE_PATH/bin
./addNode.sh $dmgr_hostname 50003 -conntype soap -profileName $PROFILE_NAME -username $ADMIN_USERNAME -password $ADMIN_PASSWORD
status=$?
while [ "$status" != "0" ] 
do 
	echo "WAITING FOR 20 SECONDS..."
	sleep 20
	echo "AGAIN FEDERATING THE NODE..."
	./addNode.sh $dmgr_hostname 50003 -conntype soap -profileName $PROFILE_NAME -username $ADMIN_USERNAME -password $ADMIN_PASSWORD
	status=$? 
done