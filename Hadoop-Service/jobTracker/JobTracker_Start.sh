#!/bin/bash

# SETTING ENVIRONMENT VARIABLES
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export JAVA_HOME=/usr/java/jre-vmware

# VARIABLES ASSIGNMENT
INSTALL_PATH=$install_path
USER_NAME=$user_name
SELFIP=$selfip
SLAVEIPS=$slaveips

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

# START OF JOB TACKER NODE
cd $HADOOP_HOME
chmod -R 777 $HADOOP_HOME
chown -R $USER_NAME $HADOOP_HOME

su $USER_NAME -c "nohup nice -n 0 $HADOOP_HOME/bin/hadoop --config $HADOOP_HOME/conf/ jobtracker > "jobtracker.log" 2>&1 < /dev/null &"
check_error "UNABLE TO INVOKE HADOOP.SH TO START JOBTRACKER";

IP_ARRAY_LENGTH=`echo ${#SlAVEIPS[*]}`

for (( i=0;i<$IP_ARRAY_LENGTH;i++)); do
	echo ${SlAVEIPS[${i}]}>> /etc/hosts
	check_error "UNABLE TO ADD JOBTRACKER'S SLAVE IP TO /etc/hosts FILE.";
done

# Try 120 times to start post-install scripts, which means the script will wait for about 20mins at most
# until the installation finishes (each loop will wait for 10 seconds for the installation to finish.)
SLEEP_PERIOD=10
LOOP_ITERATION=120
for (( i = 0 ; i < $LOOP_ITERATION ; i++ ))
do
	`grep -q "mapred.JobTracker: Starting RUNNING" $HADOOP_HOME/jobtracker.log`
	if [ "$?" == "0" ]; then
		sleep 10
		touch jobtracker_check.html
		wget http://$SELFIP:50030/jobtracker.jsp -q -O jobtracker_check.html
		check_error "UNABLE TO GET HTML PAGE OF JOBTRACKER";
		grep -q "Cluster Summary" jobtracker_check.html
		if [ "$?" == "0" ]; then
			echo "JOBTRACKER SUCCESFULLY RUNNING"
		fi
		break
	else
		sleep $SLEEP_PERIOD
		if [ "$i" == "$(($LOOP_ITERATION - 1))" ]; then
			error_exit "TIMEOUT ERROR IN STARTING JOBTRACKER";
		fi
	fi
done