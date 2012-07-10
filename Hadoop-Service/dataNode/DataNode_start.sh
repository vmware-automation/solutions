#!/bin/bash

# SETTING ENVIRONMENT VARIABLES
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export JAVA_HOME=/usr/java/jre-vmware

# VARIABLES ASSIGNMENT
INSTALL_PATH=$install_path
USER_NAME=$user_name
SELFIP=$selfip

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

cd $INSTALL_PATH/hadoop*
HADOOP_HOME=`pwd`
echo HADOOP_HOME
export HADOOP_HOME
export PATH=$PATH:$HADOOP_HOME/bin:$JAVA_HOME/bin

# BLOCK FOR STARTING DATANODE
cd $HADOOP_HOME
chmod -R 777 $HADOOP_HOME
chown -R $USER_NAME $HADOOP_HOME

su $USER_NAME -c "nohup nice -n 0 $HADOOP_HOME/bin/hadoop --config $HADOOP_HOME/conf/ datanode > "datanode.log" 2>&1 < /dev/null &"
check_error "UNABLE TO INVOKE hadoop.sh TO START DATANODE";

echo $NAMENODE >> /etc/hosts
echo $JOBTRACKER >> /etc/hosts

# Try 120 times to start post-install scripts, which means the script will wait for about 20mins at most
# until the installation finishes (each loop will wait for 10 seconds for the installation to finish.)
SLEEP_PERIOD=10
LOOP_ITERATION=120
for (( i = 0 ; i < $LOOP_ITERATION ; i++ ))
do
	`grep -q "datanode.DataNode: Starting Periodic block scanner." $HADOOP_HOME/datanode.log`
	if [ "$?" == "0" ]; then
		sleep 10
		touch datanode_check.html
		wget http://$SELFIP:50075 -q -O datanode_check.html
		check_error "Unable to get html page of DataNode";
		grep -q "WEB-INF/" datanode_check.html
		if [ "$?" == "0" ]; then
			echo "DATANODE SUCCESFULLY RUNNING"
		fi
		break
	else
		sleep $SLEEP_PERIOD
		if [ "$i" == "$(($LOOP_ITERATION - 1))" ]; then
			error_exit "TIMEOUT ERROR IN STARTING DATANODE";
		fi
	fi
done	