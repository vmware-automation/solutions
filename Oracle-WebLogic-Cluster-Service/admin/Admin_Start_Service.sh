#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vmware/bin:/opt/vmware/bin
export JAVA_HOME=/usr/java/jre-vmware
export PATH=$JAVA_HOME/bin:$PATH

# SCRIPT INTERNAL PARAMETERS -- START
BEA_HOME="$webLogic_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"
ADMIN_SERVER_IP="$admin_ip"
DOMAIN_NAME="$domain_name"
WLS_START_LOCATION="$WLS_INSTALL_DIR/samples/domains/$DOMAIN_NAME"
WLS_LOG_LOCATION="$WLS_START_LOCATION/servers/AdminServer/logs/$DOMAIN_NAME.log"
# SCRIPT INTERNAL PARAMETERS -- END

# RESTARTING THE ADMIN WEBLOGIC SERVER -- START
echo "RESTARTING THE WEBLOGIC ADMIN SERVER..."
cd $WLS_START_LOCATION/bin
./stopWebLogic.sh 
./startWebLogic.sh & sleep 120
# RESTARTING THE ADMIN WEBLOGIC SERVER -- END

# CHECKING WHETHER WEBLOGIC ADMIN SERVER STARTED SUCCESSFULLY OR NOT -- START
# Try 60 times to start post-install scripts, which means the script will wait for about 10mins at most
# until the installation finishes (each loop will wait for 10 seconds for the installation to finish.)
SLEEP_PERIOD=10
LOOP_ITERATION=60
for (( loop_counter = 0 ; loop_counter < $LOOP_ITERATION ; loop_counter++ ))
do
	grep -q "The server started in RUNNING mode" $WLS_LOG_LOCATION
	if [ "$?" == "0" ]; then
		touch weblogicServer_check.html
		sleep 10
		wget http://$ADMIN_SERVER_IP:7001/console/login/LoginForm.jsp -q -O weblogicServer_check.html
		grep -q "Deploying Application" weblogicServer_check.html
		if [ "$?" = "0" ] ; then
			echo "WEBLOGIC SERVER STARTED SUCCESSFULLY"
		else
			echo "WEBLOGIC SERVER IS NOT STARTED"
		fi
		break
	else
		sleep $SLEEP_PERIOD
	fi
done
# CHECKING WHETHER WEBLOGIC ADMIN SERVER STARTED SUCCESSFULLY OR NOT -- END 