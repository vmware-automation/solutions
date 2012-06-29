#!/bin/bash

# SETTING ENVIRONMENT VARIABLES
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export http_proxy=http://proxy.vmware.com:3128
export JAVA_HOME=/usr/java/jre-vmware

###########Paramter Validation Functions##################
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
export HADOOP_HOME
export PATH=$PATH:$HADOOP_HOME/bin:$JAVA_HOME/bin

# BLOCK FOR STARTING TASKTRACKER
cd $HADOOP_HOME
chmod -R 777 $HADOOP_HOME
chown -R $USER_NAME $HADOOP_HOME

su $USER_NAME -c "nohup nice -n 0 $HADOOP_HOME/bin/hadoop --config $HADOOP_HOME/conf/ tasktracker > "tasktracker.log" 2>&1 < /dev/null &"
check_error "UNABLE TO INVOKE hadoop.sh TO START TASKTRACKER";

echo $NAMENODE >> /etc/hosts
echo $JOBTRACKER >> /etc/hosts
# Try 120 times to start post-install scripts, which means the script will wait for about 20mins at most
# until the installation finishes (each loop will wait for 10 seconds for the installation to finish.)
SLEEP_PERIOD=10
LOOP_ITERATION=120

for (( i = 0 ; i < $LOOP_ITERATION ; i++ ))
do
	`grep -q "mapred.TaskTracker: Starting tracker" $HADOOP_HOME/tasktracker.log`
	if [ "$?" == "0" ]; then
		sleep 10
		touch tasktracker_check.html
		wget http://$SELFIP:50060/tasktracker.jsp -q -O tasktracker_check.html
		check_error "Unable to get html page of TaskTracker";
		grep -q "Running tasks" tasktracker_check.html
		if [ "$?" == "0" ]; then
			echo "TASKTRACKER SUCCESFULLY RUNNING"
		fi
		break  
	else
		sleep $SLEEP_PERIOD
		if [ "$i" == "$(($LOOP_ITERATION - 1))" ]; then
			error_exit "TIMEOUT ERROR IN STARTING TASKTRACKER";
			fi
	fi
done