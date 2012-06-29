#!/bin/bash

# SETTING ENVIRONMENT VARIABLES
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export http_proxy=http://proxy.vmware.com:3128
export JAVA_HOME=/usr/java/jre-vmware

# Function To Display Error and Exit
function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

cd $INSTALL_PATH/hadoop*
HADOOP_HOME=`pwd`
echo HADOOP_HOME
export HADOOP_HOME
export PATH=$PATH:$HADOOP_HOME/bin:$JAVA_HOME/bin

# BLOCK FOR STARTING NAMENODE
cd $HADOOP_HOME
chmod -R 777 $HADOOP_HOME
chown -R $USER_NAME $HADOOP_HOME

# FORMATING THE NAMENODE 
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop namenode -format"
su $USER_NAME -c "nohup nice -n 0 $HADOOP_HOME/bin/hadoop --config $HADOOP_HOME/conf/ namenode > "namenode.log" 2>&1 < /dev/null &"
check_error "UNABLE TO INVOKE HADOOP.SH TO START NAMENODE";

IP_ARRAY_LENGTH=`echo ${#SlAVEIPS[*]}`

# Try 120 times to start post-install scripts, which means the script will wait for about 20mins at most
# until the installation finishes (each loop will wait for 10 seconds for the installation to finish.)
SLEEP_PERIOD=10
LOOP_ITERATION=120
for (( i = 0 ; i < $LOOP_ITERATION ; i++ ))
do
	`grep -q "INFO ipc.Server: IPC Server handler 9 on 54310: starting" $HADOOP_HOME/namenode.log` || `grep -q "hdfs.StateChange: *BLOCK* NameSystem.processReport" $HADOOP_HOME/namenode.log`
	if [ "$?" == "0" ]; then
		touch namenode_check.html
		sleep 10
		wget http://$SELFIP:50070/dfshealth.jsp -q -O namenode_check.html
		check_error "UNABLE TO GET HTML PAGE OF NAMENODE";
		grep -q "Started" namenode_check.html
		if [ "$?" == "0" ]; then
			echo "NAMENODE SUCCESFULLY RUNNING"
		fi
		break
	else
		sleep $SLEEP_PERIOD
		if [ "$i" == "$(($LOOP_ITERATION - 1))" ]; then
			error_exit "TIMEOUT ERROR IN STARTING NAMENODE";
		fi	
	fi
done