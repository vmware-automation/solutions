#!/bin/bash

# SETTING ENVIRONMENT VARIABLES
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export JAVA_HOME=/usr/java/jre-vmware

# VARIABLES ASSIGNMENT
INSTALL_PATH=$install_path
GROUP_NAME=$group_name
USER_NAME=$user_name
NAMENODE=$namenode
JOBTRACKER=$jobtracker
DFS_REPLICATION=$dfs_replication
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

# CHANGING OWNERSHIP
chmod -R 777 $HADOOP_HOME
chown -R $USER_NAME $HADOOP_HOME

# CONFIGURATION START - MODIFYING haddop-env.sh FOR JRE PATH
sed -i "8cJAVA_HOME=/usr/java/jre-vmware" $HADOOP_HOME/conf/hadoop-env.sh
check_error "Unable to edit hadoop-env.sh";

# CONFIGURATION CHANGES IN XML FILES
:> $HADOOP_HOME/conf/core-site.xml
:> $HADOOP_HOME/conf/mapred-site.xml
:> $HADOOP_HOME/conf/hdfs-site.xml

cat <<ENDcore > $HADOOP_HOME/conf/core-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
  <name>fs.default.name</name>
  <value>hdfs://$NAMENODE:54310</value>
  <description>The name of the default file system.  A URI whose
  scheme and authority determine the FileSystem implementation.  The
  uri's scheme determines the config property (fs.SCHEME.impl) naming
  the FileSystem implementation class.  The uri's authority is used to
  determine the host, port, etc. for a filesystem.</description>
</property>
<property>
    <name>hadoop.tmp.dir</name>
    <value>$HADOOP_HOME/temp/</value>
    <final>true</final>
</property>
</configuration>
ENDcore

check_error "UNABLE TO EDIT core-site.xml";

cat <<ENDmapred > $HADOOP_HOME/conf/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
  <name>mapred.job.tracker</name>
  <value>$JOBTRACKER:8021</value>
  <description>The host and port that the MapReduce job tracker runs
  at.  If "local", then jobs are run in-process as a single map
  and reduce task.
  </description>
</property>
<property>
    <name>mapred.temp.dir</name>
    <value>$HADOOP_HOME/mapred/temp/</value>
    <final>true</final>
</property>
<property>
    <name>mapred.system.dir</name>
    <value>$HADOOP_HOME/mapred/system</value>
    <final>true</final>
  </property>
<property>
    <name>mapred.local.dir</name>
    <value>$HADOOP_HOME/mapred/hadoop1/data/,$HADOOP_HOME/mapred/hadoop2/data/</value>
    <final>true</final>
  </property>
</configuration>
ENDmapred

check_error "UNABLE TO EDIT mapred-site.xml";

cat <<ENDhdfs > $HADOOP_HOME/conf/hdfs-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
  <name>dfs.replication</name>
  <value>$DFS_REPLICATION</value>
  <description>Default block replication.
  The actual number of replications can be specified when the file is created.
  The default is used if replication is not specified in create time.
  </description>
</property>
<property>
  <name>hadoop.tmp.dir</name>
  <value>$HADOOP_HOME/temp/</value>
  <description>A base for other temporary directories.</description>
</property>
 <property>
    <name>fs.default.name</name>
    <value>hdfs://$NAMENODE:54310</value>
  </property>
<property>
    <name>mapred.task.tracker.http.address</name>
    <value>http://$SELFIP:50060</value>
  </property>
<property>
    <name>fs.data.dir</name>
    <value>$HADOOP_HOME/dfs/data</value>
 </property>
  <property>
    <name>mapred.job.tracker</name>
    <value>$JOBTRACKER:8021</value>
  </property>
</configuration>
ENDhdfs

check_error "UNABLE TO EDIT hdfs-site.xml";

#CREATING DIRECTORIES
mkdir -p $HADOOP_HOME/{hadoop3/data,hadoop4/data,temp,data,name,mapred/{temp,system,local,hadoop1/data,hadoop2/data}}
check_error "UNABLE TO CREATE CUSTOM DIRECTORIES FOR HADOOP";
   
# MAKING ENTRY TO THE MASTERS FILE  
:> $HADOOP_HOME/conf/masters
echo $JOBTRACKER>> $HADOOP_HOME/conf/masters
check_error "UNABLE TO ADD JOBTRACKER IP TO MASTERS FILE.";  

## CONFIGURATION BLOCK FOR SLAVES(TASKTRACKER)
# DETERMINING THE NUMBER OF NODES IN CLUSTER
IP_ARRAY_LENGTH=`echo ${#SLAVEIPS[*]}`

for (( i=0;i<$IP_ARRAY_LENGTH;i++)); do
    host_name=`hostname`
    echo $host_name 
done

echo "TASKTRACKER CONFIGURATION DONE"