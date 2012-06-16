#!/bin/bash
 
# Import global conf
. $global_conf
 
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vmware/bin:/opt/vmware/bin
export JAVA_HOME=/usr/java/jre-vmware
export PATH=$JAVA_HOME/bin:$PATH
 
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
 
BEA_HOME="$webLogic_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"
WLSINSTALLERLOCATION="$WLS_INSTALL_DIR/INSTALLER"
WLSSTARTSCRIPT="$WLSINSTALLERLOCATION/wls_start.sh"
WLS_START_LOCATION="$WLS_INSTALL_DIR/samples/domains/wl_server"
WLS_LOG_LOCATION="$WLS_START_LOCATION/servers/examplesServer/logs/wl_server.log"
SERVER_IP="$weblogic_server_ip"
GROUP_NAME="$group_name"
USER_NAME="$user_name"
 
# CREATING WEBLOGIC START SCRIPT FILE
cat << EOF > $WLSSTARTSCRIPT
#!/bin/bash
cd $WLS_START_LOCATION/bin
./startWebLogic.sh & sleep 70
EOF
check_error "Error while creating Configuration file"
 
chmod -R 775 $WLSSTARTSCRIPT
echo "Starting WebLogic Server..."
su - $USER_NAME -c $WLSSTARTSCRIPT
 
# Try 60 times to start post-install scripts, which means the script will wait for about 10mins at most
# until the installation finishes (each loop will wait for 10 seconds for the installation to finish.)
SLEEP_PERIOD=10
LOOP_ITERATION=60
for (( i = 0 ; i < $LOOP_ITERATION ; i++ ))
do
   grep -q "The server started in RUNNING mode" $WLS_LOG_LOCATION
 
   if [ "$?" == "0" ]; then
        touch weblogicServer_check.html
        sleep 10
         wget http://$SERVER_IP:7001/console/login/LoginForm.jsp -q -O weblogicServer_check.html
         grep -q "Deploying Application" weblogicServer_check.html
         if [ "$?" = "0" ] ; then
            echo "WebLogic Server started Successfully"
        else
            echo "WebLogic Server is not started"
        fi
          break
   else
        sleep $SLEEP_PERIOD
   fi
done
 
#REMOVING THE UNNECESSARY FILES
rm -rf $WLSINSTALLERLOCATION

