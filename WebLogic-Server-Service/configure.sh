#!/bin/bash
 
# Import global conf
. $global_conf
 
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vmware/bin:/opt/vmware/bin
export JAVA_HOME=/usr/java/jre-vmware
export PATH=$JAVA_HOME/bin:$PATH
 
#########CUSTOMIZED PARAMETERS#########
BEA_HOME="$webLogic_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"
WLSINSTALLERLOCATION="$WLS_INSTALL_DIR/INSTALLER"
WLSCONFIGURATIONSCRIPT="$WLSINSTALLERLOCATION/wls_config.sh"
SILENT_SCRIPT="$WLSINSTALLERLOCATION/silent_cw.sh"
DOMAIN_NAME="$domain_name"
SERVER_NAME="$server_name"
ADMIN_USERNAME="$admin_user_name"
ADMIN_PASSWORD="$admin_password"
LISTENING_PORT="$listening_port"
SERVER_SSLLISTEN_PORT="$server_ssl_listen_port"
GROUP_NAME="$group_name"
USER_NAME="$user_name"
 
 
###########Paramter Validation Functions##################
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
 
## Function To Validate Integer
function valid_int()
{
   local data=$1
   if [[ $data =~ ^[0-9]{1,9}$ ]]; then
      return 0;
   else
      return 1
   fi
}
 
####################SCRIPT EXECUTION ##################
echo "Paramter Validation"
 
if [ "x${DOMAIN_NAME}" = "x" ]; then
    error_exit "WEBLOGIC_DOMAIN_NAME not set."
fi
if [ "x${SERVER_NAME}" = "x" ]; then
    error_exit "WEBLOGIC_SERVER_NAME not set."
fi
 
if [ "x${ADMIN_USERNAME}" = "x" ]; then
    error_exit "ADMIN_USERNAME not set."
fi
 
if [ "x${ADMIN_PASSWORD}" = "x" ]; then
    error_exit "ADMIN_PASSWORD not set."
fi
 
if [ "x${LISTENING_PORT}" = "x" ]; then
    error_exit "LISTENING_PORT not set."
else
   if ! valid_int $LISTENING_PORT; then
      error_exit "Invalid parameter LISTENING_PORT"
   fi
fi
 
if [ "x${SERVER_SSLLISTEN_PORT}" = "x" ]; then
    error_exit "SERVER_SSLLISTEN_PORT not set."
else
   if ! valid_int $SERVER_SSLLISTEN_PORT; then
      error_exit "Invalid parameter SERVER_SSLLISTEN_PORT"
   fi
fi
 
echo "Paramter Validation -- DONE"
 
# CREATING SILENT SCRIPT FILE
echo "Creating silent configuration script for WebLogic Server"
cat <<EOF> $SILENT_SCRIPT
read template from "$WLS_INSTALL_DIR/common/templates/domains/wls.jar";
create server "$SERVER_NAME" as serv1;
create User "$ADMIN_USERNAME" as us1;
set us1.Password "$ADMIN_PASSWORD";
assign User "$ADMIN_USERNAME" to Group "Deployers";
 
find Server "$SERVER_NAME" as s1;
set s1.ListenAddress "";
set s1.ListenPort "$LISTENING_PORT";
set s1.SSL.Enabled "true";
set s1.SSL.ListenPort "$SERVER_SSLLISTEN_PORT";
 
find User "weblogic" as u2;
set u2.password "welcome1";
 
set OverwriteDomain "true";
 
write domain to "$WLS_INSTALL_DIR/user_projects/domains/$DOMAIN_NAME";
 
close template;
EOF
check_error "Error while creating silent script file"
echo "Configuration file created successfully"
chmod -R 775 $SILENT_SCRIPT
 
# CREATING WEBLOGIC CONFIGURATION SCRIPT FILE
cat << EOF > $WLSCONFIGURATIONSCRIPT
#!/bin/bash
cd $WLS_INSTALL_DIR/common/bin
./config.sh -mode=silent -silent_script=$SILENT_SCRIPT
EOF
check_error "Error while creating Configuration file"
 
chmod -R 775 $WLSCONFIGURATIONSCRIPT
echo "Configuring Domain for WebLogic Server..."
su - $USER_NAME -c $WLSCONFIGURATIONSCRIPT
check_error "Errors during configuring WebLogic server.";
echo "Configured Successfully."

