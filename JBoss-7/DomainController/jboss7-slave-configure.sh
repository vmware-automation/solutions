#!/bin/bash
set -e

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

HOME_DIR=/home/jboss
export JBOSS_HOME=$HOME_DIR/$JBOSS_NAME_AND_VERSION/jboss-as

if [ ! -d $JBOSS_HOME ]; then
    "Echo JBOSS_HOME does not exist!"
    exit -1
fi

function addUserAndPassword() {
   local name=$1
   local pw=$2
   # This is the correct way to do it, but see bug https://issues.jboss.org/browse/AS7-4630
   # try $JBOSS_HOME/bin/add-user.sh --silent=true $JBOSS_MGMT_USER $JBOSS_MGMT_PWD # mgmt user
   # try $JBOSS_HOME/bin/add-user.sh --silent=true -a $JBOSS_MGMT_USER $JBOSS_MGMT_PWD # application user

   # Alternative/hacky way see https://community.jboss.org/wiki/AS710Beta1-SecurityEnabledByDefault
   local app_users_file=$JBOSS_HOME/domain/configuration/application-users.properties
   local mgmt_users_file=$JBOSS_HOME/domain/configuration/mgmt-users.properties

   echo -e '\n' >> $app_users_file
   local cmd="/usr/bin/java -cp $JBOSS_HOME/modules/org/jboss/sasl/main/jboss-sasl-1.0.1.Final.jar org.jboss.sasl.util.UsernamePasswordHashUtil \"$name\" \"ManagementRealm\" \"$pw\" >> $app_users_file" 
   echo "Executing $cmd"
   eval $cmd 
   if [ $? -ne 0 ]; then
      echo "Failed to set application user"
      exit -1
   fi

   echo -e '\n' >> $mgmt_users_file
   cmd="/usr/bin/java -cp $JBOSS_HOME/modules/org/jboss/sasl/main/jboss-sasl-1.0.1.Final.jar org.jboss.sasl.util.UsernamePasswordHashUtil \"$name\" \"ManagementRealm\" \"$pw\" >> $mgmt_users_file" 
   echo "Executing $cmd"
   eval $cmd 
   if [ $? -ne 0 ]; then
      echo "Failed to set management user"
      exit -1
   fi
}

PROVIDED_INIT_DIR=$JBOSS_HOME/bin/init.d
BOOTRC=/etc/init.d/jboss
if [ ! -e $BOOTRC ]
then
    cp $domain_init_script $PROVIDED_INIT_DIR/jboss-as-domain-slave.sh
    chmod 755 $PROVIDED_INIT_DIR/jboss-as-domain-slave.sh
    if [ ! -f $PROVIDED_INIT_DIR/jboss-as-domain-slave.sh -o ! -x $PROVIDED_INIT_DIR/jboss-as-domain-slave.sh ]; then
        echo "Domain init.d script is missing or is not executable!"
        exit 1
    fi

   try mkdir -p /etc/jboss-as

   try ln -s $PROVIDED_INIT_DIR/jboss-as.conf /etc/jboss-as # Default location init script gets config from
   try ln -s $PROVIDED_INIT_DIR/jboss-as-domain-slave.sh $BOOTRC # Use custom init script created for domain

   if [ -z $JBOSS_PIDFILE ]; then
       try mkdir -p /var/run/jboss-as
       JBOSS_PIDFILE="/var/run/jboss-as/jboss-as-domain-slave.pid"
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

# Add jboss mgmt user
addUserAndPassword $JBOSS_MGMT_USER $JBOSS_MGMT_PWD

# Setup properties file
cat > $JBOSS_HOME/system.properties << EOF
jboss.domain.master.address=$master_ip
jboss.bind.address.management=$self_ip
jboss.bind.address=$self_ip
jboss.bind.address.unsecure=$self_ip
cluster.server.group=main-group
cluster.server.name=$slave_name
jboss.home.dir=$JBOSS_HOME
EOF

# Add the slave
addUserAndPassword $slave_name $slave_password

try chown -R $JBOSS_USER:$JBOSS_USER $JBOSS_HOME

else
	echo Service already installed 	
fi
