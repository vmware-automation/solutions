#!/bin/bash

# JBOSS_USER - User who owns the installation and process defaults jboss
# JBOSS_NAME_AND_VERSION = name of the top-level directory created by the ZIP file, e.g. 'jboss-eap-5.1'
# JBOSS_MGMT_USER = Mgmt administrator's user name
# JBOSS_MGMT_PWD = Mgmt administrator's password
# JVM_ROUTE = The route defaults 0

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

HOME_DIR=/home/jboss
export JBOSS_HOME=$HOME_DIR/$JBOSS_NAME_AND_VERSION/jboss-as

if [ ! -d $JBOSS_HOME ]; then
    "Echo JBOSS_HOME does not exist!"
    exit -1
fi

#Setup JBoss
JVM_ROUTE=${JVM_ROUTE:-0}

PROVIDED_INIT_DIR=$JBOSS_HOME/bin/init.d
BOOTRC=/etc/init.d/jboss
if [ ! -e $BOOTRC ]
then
   try mkdir -p /etc/jboss-as

   try ln -s $PROVIDED_INIT_DIR/jboss-as.conf /etc/jboss-as # Default location init script gets config from
   try ln -s $PROVIDED_INIT_DIR/jboss-as-standalone.sh $BOOTRC # Use provided init

   if [ -z $JBOSS_PIDFILE ]; then
       try mkdir -p /var/run/jboss-as
       JBOSS_PIDFILE="/var/run/jboss-as/jboss-as-standalone.pid"
   fi
   if [ -z $JBOSS_CONSOLE_LOG ]; then
       try mkdir -p /var/log/jboss-as
       JBOSS_CONSOLE_LOG="/var/log/jboss-as/console.log"
   fi
   
cat >> $PROVIDED_INIT_DIR/jboss-as.conf << EOF
JBOSS_HOME=$JBOSS_HOME
JBOSS_PIDFILE=$JBOSS_PIDFILE
JBOSS_CONSOLE_LOG=$JBOSS_CONSOLE_LOG
STARTUP_WAIT=${STARTUP_WAIT:-30}
SHUTDOWN_WAIT=${SHUTDOWN_WAIT:-30}
JBOSS_USER=${JBOSS_USER:-"jboss"}
EOF

   # JVM route is now the instance-id in the web subsystem
   sed -i.bak "s/\(<subsystem xmlns=\"urn:jboss:domain:web:1.1\".*\)>/\1 instance-id=\"$JVM_ROUTE\">/" $JBOSS_HOME/standalone/configuration/standalone.xml 

   # For demo only!! set binding for all interfaces to any available ipv4
   sed -i.bak2 's/^\(\s*\)<inet-address.*$/\1<any-ipv4-address\/>/g' $JBOSS_HOME/standalone/configuration/standalone.xml 


   # This is the correct way to do it, but see bug https://issues.jboss.org/browse/AS7-4630
   # try $JBOSS_HOME/bin/add-user.sh --silent=true $JBOSS_MGMT_USER $JBOSS_MGMT_PWD # mgmt user
   # try $JBOSS_HOME/bin/add-user.sh --silent=true -a $JBOSS_MGMT_USER $JBOSS_MGMT_PWD # application user

   # Alternative temporary workaround see https://community.jboss.org/wiki/AS710Beta1-SecurityEnabledByDefault
   app_users_file=$JBOSS_HOME/standalone/configuration/application-users.properties
   mgmt_users_file=$JBOSS_HOME/standalone/configuration/mgmt-users.properties

   echo -e '\n' >> $app_users_file
   cmd="/usr/bin/java -cp $JBOSS_HOME/modules/org/jboss/sasl/main/jboss-sasl-1.0.1.Final.jar org.jboss.sasl.util.UsernamePasswordHashUtil \"$JBOSS_MGMT_USER\" \"ManagementRealm\" \"$JBOSS_MGMT_PWD\" >> $app_users_file" 
   echo "Executing $cmd"
   eval $cmd 
   if [ $? -ne 0 ]; then
      echo "Failed to set application user"
      exit -1
   fi

   echo -e '\n' >> $mgmt_users_file
   cmd="/usr/bin/java -cp $JBOSS_HOME/modules/org/jboss/sasl/main/jboss-sasl-1.0.1.Final.jar org.jboss.sasl.util.UsernamePasswordHashUtil \"$JBOSS_MGMT_USER\" \"ManagementRealm\" \"$JBOSS_MGMT_PWD\" >> $mgmt_users_file" 
   echo "Executing $cmd"
   eval $cmd 
   if [ $? -ne 0 ]; then
      echo "Failed to set management user"
      exit -1
   fi

   try chown -R $JBOSS_USER:$JBOSS_USER $JBOSS_HOME

else
	echo Service already installed 	
fi
