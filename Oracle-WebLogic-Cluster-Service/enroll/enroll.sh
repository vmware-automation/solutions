#!/bin/bash

# SCRIPT INTERNAL PARAMETERS -- START
BEA_HOME="$webLogic_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"
DOMAIN="$domain_name"
# SCRIPT INTERNAL PARAMETERS -- END

# FUNTION TO CHECK ERROR
PROGNAME=`basename $0`
function Check_error()
{
   if [ ! "$?" = "0" ]; then
      Error_exit "$1";
   fi
}
# FUNCTION TO DISPLAY ERROR AND EXIT
function Error_exit()
{
   echo "${PROGNAME}: ${1:-"UNKNOWN ERROR"}" 1>&2
   exit 1
}

# UNPACKING -- START
echo `hostname` 
echo "UNPACKING THE $DOMAIN.jar(ADMIN SERVER DOMAIN) ON THE MANAGED SERVER..."
$WLS_INSTALL_DIR/common/bin/unpack.sh -domain=$WLS_INSTALL_DIR/samples/domains/$DOMAIN -template=$WLS_INSTALL_DIR/common/templates/domains/$DOMAIN.jar
Check_error "ERROR:WHILE UNPACKING THE DOMAIN"
echo "DOMAIN UNPACKED SUCCESSFULLY"
# UNPACKING -- END

# ENROLLMENT OF MANAGED SERVER -- START	
echo "ENROLLING MANAGED SERVER WITH THE ADMIN SERVER..."
$WLS_INSTALL_DIR/common/bin/wlst.sh $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/enrollnodemanager.py
Check_error "ERROR:WHILE ENROLLING THE AMAGED SERVER WITH THE ADMIN SERVER"
echo "MANAEGD SERVER ENROLLED SUCCESSFULLY"
# ENROLLMENT OF MANAGED SERVER -- END

# START OF THE NODEMANAGER ON THE MANAGED SERVER -- START
cat << EOF > $WLS_INSTALL_DIR/common/nodemanager/nodemanager.properties
DomainsFile=/disk2/BEA/WebLogic/common/nodemanager/nodemanager.domains
LogLimit=0
PropertiesVersion=10.3
DomainsDirRemoteSharingEnabled=false
javaHome=/disk2/BEA/jdk160_29
AuthenticationEnabled=true
NodeManagerHome=/disk2/BEA/WebLogic/common/nodemanager
JavaHome=/disk2/BEA/jdk160_29/jre
LogLevel=INFO
DomainsFileEnabled=true
StartScriptName=startWebLogic.sh
ListenAddress=
NativeVersionEnabled=true
ListenPort=5556
LogToStderr=true
SecureListener=false
LogCount=1
DomainRegistrationEnabled=false
StopScriptEnabled=false
QuitEnabled=false
LogAppend=true
StateCheckInterval=500
CrashRecoveryEnabled=false
StartScriptEnabled=true
LogFile=/disk2/BEA/WebLogic/common/nodemanager/nodemanager.log
LogFormatter=weblogic.nodemanager.server.LogFormatter
ListenBacklog=50
EOF

echo "STARTING THE NODEMANAGER ON THE MANAGED SERVER..."
cd $WLS_INSTALL_DIR/server/bin
./startNodeManager.sh & sleep 500
Check_error "ERROR:WHILE STARTING THE NODEMANAGER ON THE MANAGED SERVER"
echo "NODEMANAGER STARTED SUCCESSFULLY"
# START OF THE NODEMANAGER ON THE MANAGED SERVER -- END
