#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vmware/bin:/opt/vmware/bin
export JAVA_HOME=/usr/java/jre-vmware
export PATH=$JAVA_HOME/bin:$PATH

# SCRIPT INTERNAL PARAMETERS -- START
BEA_HOME="$webLogic_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"
WLSINSTALLERLOCATION="$WLS_INSTALL_DIR/INSTALLER"
DOMAIN_NAME="$domain_name"
WEBLOGIC_USER="$user_name"
WEBLOGIC_GROUP="$group_name"
WEBLOGIC_PASSWORD="$admin_password"
ADMIN_SERVER_NAME="$server_name"
LISTENING_PORT="$admin_http_port"
ADMIN_SERVER_IP="$admin_ip"
CLUSTER_NUMBER="$cluster_number"
STANDALONE_MANAGEDSERVER_NUMBER="$standalone_managedserver_number"
MANAGED_SERVER_NUMBER="$managed_server_number"
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

#############################################################
############ INTERNAL FUNCTIONS REGION -- START #############
#############################################################

## FUNCTIONS FOR CLUSTER -- START
function AddServersConf()
{    
	if [ $NODE_INDEX -eq 1 -a $CLUSTER_INDEX -eq 1 ] ; then
		tmp_index=1
	fi
	echo "# SERVER "$tmp_index" CONFIGURATION........"  >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	tmp_ip=cluster_`expr $CLUSTER_INDEX`_ip[$NODE_INDEX-1]
	ip=${!tmp_ip}
	echo "Machine"$tmp_index""IP" = '$ip'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py

	echo "Machine"$tmp_index""Name" = 'machine_$tmp_index'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	tmp_http=servers_http_port
	http=${!tmp_http}
	echo "Server"$tmp_index""HttpPort" = $http" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	tmp_https=servers_https_port
	https=${!tmp_https}
	echo "Server"$tmp_index""HttpsPort" = $https" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "Server"$tmp_index""Name" = 'server_$tmp_index'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py 
	tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
	managed_server_num=${!tmp_num}
	if [ $managed_server_num -eq $NODE_INDEX ] ; then
		echo "print 'LOADING THE DOMAIN ...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
		echo "readDomain('$WLS_INSTALL_DIR/samples/domains/' + sys.argv[1])" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	fi
	tmp_index=`expr $tmp_index + 1`
}

function CreateMachine()
{ 
	if [ $NODE_INDEX -eq 1 -a $CLUSTER_INDEX -eq 1 ] ; then
		tmp_index=1
	fi
	echo "print 'CREATING MACHINE"$tmp_index"...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py 
	echo "cd('/')"  >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "create(Machine"$tmp_index"Name, 'Machine')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "cd('Machine/' + Machine"$tmp_index"Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "print 'CREATING NODEMANAGER ON MACHINE"$tmp_index"...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py 
	echo "create(Machine"$tmp_index"Name, 'NodeManager')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "cd('NodeManager/' + Machine"$tmp_index"Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('ListenAddress', Machine"$tmp_index"IP)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('NMType', 'plain')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	tmp_index=`expr $tmp_index + 1`

}

function CreateManagedServer()
{
	if [ $NODE_INDEX -eq 1 -a $CLUSTER_INDEX -eq 1 ] ; then 
	tmp_index=1
	fi
	echo "print 'CREATING MANAGED SERVER"$tmp_index"...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "cd('/')"  >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "create(Server"$tmp_index"Name, 'Server')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "cd('Server/' + Server"$tmp_index"Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('ListenPort', Server"$tmp_index"HttpPort)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('ListenAddress', Machine"$tmp_index"IP)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('Machine', Machine"$tmp_index"Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py

	echo "create(Server"$tmp_index"Name, 'SSL')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "cd('SSL/' + Server"$tmp_index"Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('Enabled', 'True')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('ListenPort', Server"$tmp_index"HttpsPort)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('HostNameVerificationIgnored', 'True')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py

	echo "cd('../..')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "create(Server"$tmp_index"Name,'ServerStart')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "cd('ServerStart/' + Server"$tmp_index"Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	echo "set('Arguments', '-XX:MaxPermSize=512m -Dcom.sun.xml.namespace.QName.useCompatibleSerialVersionUID=1.0')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
	managed_server_num=${!tmp_num}
	if [ $managed_server_num -eq $NODE_INDEX ] ; then
		echo "print 'ASSIGNING THE MANAGED SERVERS TO THE CLUSTER'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
		tmp=Assign_server_$CLUSTER_INDEX
		echo "assign('Server', ${!tmp}, 'Cluster', sys.argv[2])"  >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
		echo "print 'UPDATING THE DOMAIN...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
		echo "updateDomain()" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
		echo "closeDomain()" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
		echo "print 'DOMAIN UPDATED SUCCESSFULLY'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
		echo "exit()" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
	fi
	tmp_index=`expr $tmp_index + 1`

}

function CopyJar()
{    
	echo "#!/usr/bin/expect" > $WLSINSTALLERLOCATION/copy.exp
	tmp_ip=cluster_`expr $CLUSTER_INDEX`_ip[$NODE_INDEX-1]
	ip=${!tmp_ip}
	echo "spawn scp root@$ADMIN_SERVER_IP:$WLS_INSTALL_DIR/common/templates/domains/$DOMAIN_NAME.jar root@$ip:$WLS_INSTALL_DIR/common/templates/domains" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"*password*\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "send \"vmware\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"Are*\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "send \"yes\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"*password*\"" >> $WLSINSTALLERLOCATION/copy.exp	
	echo "send \"vmware\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect eof" >> $WLSINSTALLERLOCATION/copy.exp

}

function CopyEnrollScript()
{
	tmp_ip=cluster_`expr $CLUSTER_INDEX`_ip[$NODE_INDEX-1]
	ip=${!tmp_ip}
	echo "#!/usr/bin/expect" > $WLSINSTALLERLOCATION/copy.exp	
	echo "spawn scp $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/enrollnodemanager.py root@$ip:$WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"*password*\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "send \"vmware\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect eof" >> $WLSINSTALLERLOCATION/copy.exp	 
}

## FUNCTIONS FOR CLUSTER -- END

## FUNCTIONS FOR STANDALONE MANAGED SREVRS -- START

function AddStandAloneServersConf()
{    
      echo "# STANDALONE SERVER `expr $MANAGED_SERVER_NUMBER + $NODE_INDEX` CONFIGURATION........"  >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	
      tmp_ip=standalone_`expr $NODE_INDEX`_ip
      ip=${!tmp_ip}
      echo "Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`"IP" = '$ip'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	 
      echo "Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`"Name" = 'machine_`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
      tmp_http=servers_http_port
      http=${!tmp_http}
      echo "Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`"HttpPort" = $http" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
      tmp_https=servers_https_port
      https=${!tmp_https}
      echo "Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`"HttpsPort" = $https" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
      echo "Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`"Name" = 'server_`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py 
	echo "print 'LOADING THE DOMAIN...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "readDomain('$WLS_INSTALL_DIR/samples/domains/' + sys.argv[1])" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
}

function CreateStanAloneMachine()
{
    echo "print 'CREATING STANDALONE MACHINE`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "cd('/')"  >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "create(Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name, 'Machine')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "cd('Machine/' + Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "print 'CREATING NODEMANAGER ON STANDALONE MACHINE`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "create(Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name, 'NodeManager')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "cd('NodeManager/' + Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "set('ListenAddress', Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`IP)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
    echo "set('NMType', 'plain')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
}

function CreateStandAloneManagedServer()
{
	echo "print 'CREATING STANDALONE MANAGED SERVER`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "cd('/')"  >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "create(Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name, 'Server')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "cd('Server/' + Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "set('ListenPort', Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`HttpPort)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "set('ListenAddress', Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`IP)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "set('Machine', Machine`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py

	echo "create(Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name, 'SSL')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "cd('SSL/' + Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "set('Enabled', 'True')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "set('ListenPort', Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`HttpsPort)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "set('HostNameVerificationIgnored', 'True')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py

	echo "cd('../..')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "create(Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name,'ServerStart')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "cd('ServerStart/' + Server`expr $MANAGED_SERVER_NUMBER + $NODE_INDEX`Name)" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "set('Arguments', '-XX:MaxPermSize=512m -Dcom.sun.xml.namespace.QName.useCompatibleSerialVersionUID=1.0')" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	
	echo "print 'UPDATING THE DOMAIN...'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "updateDomain()" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "closeDomain()" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "print 'DOMAIN UPDATED SUCCESSFULLY'" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
	echo "exit()" >> $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
}

function CopyJarToStandAloneServer()
{    
	tmp_ip=standalone_`expr $NODE_INDEX`_ip
	ip=${!tmp_ip}
	echo "#!/usr/bin/expect" > $WLSINSTALLERLOCATION/copy.exp
	echo "spawn scp root@$ADMIN_SERVER_IP:$WLS_INSTALL_DIR/common/templates/domains/$DOMAIN_NAME.jar root@$ip:$WLS_INSTALL_DIR/common/templates/domains" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"*password*\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "send \"vmware\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"Are*\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "send \"yes\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"*password*\"" >> $WLSINSTALLERLOCATION/copy.exp	
	echo "send \"vmware\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect eof" >> $WLSINSTALLERLOCATION/copy.exp
}

function CopyEnrollScriptToStandAloneServer()
{
	tmp_ip=standalone_`expr $NODE_INDEX`_ip
	ip=${!tmp_ip}
	echo "#!/usr/bin/expect" > $WLSINSTALLERLOCATION/copy.exp	
	echo "spawn scp $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/enrollnodemanager.py root@$ip:$WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect \"*password*\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "send \"vmware\r\"" >> $WLSINSTALLERLOCATION/copy.exp
	echo "expect eof" >> $WLSINSTALLERLOCATION/copy.exp	 
}

## FUNCTIONS FOR STANDALONE MANAGED SREVRS -- END

#############################################################
############ INTERNAL FUNCTIONS REGION -- END ###############
#############################################################

# SCRIPT EXECUTION -- START
# SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES
echo "SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES..."
cd $WLS_INSTALL_DIR/server/bin
. ./setWLSEnv.sh
Check_error "ERROR IN SETTING UP THE ENVIRONMENTAL VARIABLES."
echo "ENVIRONMENTAL VARIABLES SET SUCCESSFULLY"

# CREATING DOMAIN -- START
mkdir -p $WLS_INSTALL_DIR/samples/domains/$DOMAIN_NAME
cd $WLS_INSTALL_DIR/samples/domains/$DOMAIN_NAME
echo "CREATING DOMAIN ..."
java -XX:PermSize=128m -Dweblogic.management.username=$WEBLOGIC_USER -Dweblogic.management.password=$WEBLOGIC_PASSWORD -Dweblogic.Domain=$DOMAIN_NAME -Dweblogic.Name=$ADMIN_SERVER_NAME -Dweblogic.ListenPort=$LISTENING_PORT -Dweblogic.management.GenerateDefaultConfig=true weblogic.Server & sleep 600
Check_error "ERROR:$DOMAIN_NAME NOT CREATED"
echo "DOMAIN $DOMAIN_NAME CREATED SUCCESSFULLY"
# CREATING DOMAIN -- END

# CREATING EMPTY CLUSTER -- START
cat << EOF > $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/cluster.py
from java.util import *
from javax.management import *
import javax.management.Attribute

print 'STARTING THE SCRIPT ....'
username = '$WEBLOGIC_USER'
password = '$WEBLOGIC_PASSWORD'
Cluster_Number = $CLUSTER_NUMBER 
tmp_cluster = 'cluster'
print 'CONNECTING TO THE ADMIN SERVER...'
connect(username,password,'t3://localhost:7001')
print 'SUCCESSFULLY CONNECTED'
edit()
startEdit()

print 'CREATING EMPTY CLUSTERS...'
index = 0
while ( index < Cluster_Number ):
	   ClusterName = "%s%02d" % (tmp_cluster, index)
	   cluster_name = create(ClusterName, 'Cluster')
	   index = index + 1
save()
activate(block="true")
disconnect()
print 'END OF SCRIPT ...'
EOF

# SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES
echo "SETTING UP THE WEBLOGIC ENVIRONMENTAL VARIABLES..."
cd $WLS_INSTALL_DIR/server/bin
. ./setWLSEnv.sh
Check_error "ERROR IN SETTING UP THE ENVIRONMENTAL VARIABLES."
echo "ENVIRONMENTAL VARIABLES SET SUCCESSFULLY"
java weblogic.WLST $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/cluster.py
Check_error "ERROR:CLUSTER NOT CREATED"
echo "AN EMPTY CLUSTER CREATED SUCCESSFULLY"
# CREATING EMPTY CLUSTER -- END

# ADDING MANAGED SERVER TO THE CREATED CLUSTER -- START
CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do
 cat << EOF > $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py
# INSTALLATION DIRECTORIES
BEA_HOME = '$BEA_HOME'
EOF
 CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done

# ADDING THE MANAGED SERVER DETAILS IN CONFIGURATION FILES
CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do 
	tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
	managed_server_num=${!tmp_num}
	NODE_INDEX=1
	while [ $NODE_INDEX -le $managed_server_num ]
	do
		AddServersConf $NODE_INDEX $CLUSTER_INDEX
		NODE_INDEX=`expr $NODE_INDEX + 1`
	done
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done

# ADDING CREATE MACHINE FUNCTION CALLS IN CONFIGURATION FILE
CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do
	tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
      managed_server_num=${!tmp_num}
	NODE_INDEX=1
	while [ $NODE_INDEX -le $managed_server_num ]
	do
		CreateMachine $NODE_INDEX $CLUSTER_INDEX
		NODE_INDEX=`expr $NODE_INDEX + 1`
	done
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done

# ADDING ASSIGN MANAMAGED SERVER FUNCTION CALLS IN CONFIGURATION FILE
CLUSTER_INDEX=1
tmp_serv=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do   
	if [ $CLUSTER_INDEX -eq 1 ] ; then
		eval Assign_server_$CLUSTER_INDEX=Server`expr $tmp_serv`Name              
	else
		eval Assign_server_$CLUSTER_INDEX=Server`expr $tmp_serv + 1`Name 	 
		tmp_serv=`expr $tmp_serv + 1` 
	fi
	NODE_INDEX=1
	tempstring=""
	if [ $managed_server_num -gt 1 ] ; then	
		while [ $NODE_INDEX -lt $managed_server_num ]
		do
			temp=`expr $tmp_serv + 1`
			tempstring="$tempstring + ', ' + Server`expr $temp`Name"
			NODE_INDEX=`expr $NODE_INDEX + 1`
			tmp_serv=`expr $tmp_serv + 1`		               
		done
		tmp_var=Assign_server_`expr $CLUSTER_INDEX`
		tempstring=${!tmp_var}$tempstring
		eval Assign_server_$CLUSTER_INDEX='$tempstring'
		eval echo \$Assign_server_$CLUSTER_INDEX
	fi
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done

# ADDING CREATE MANAMAGED SERVER FUNCTION CALLS IN CONFIGURATION FILE
CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do
	NODE_INDEX=1
	tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
	managed_server_num=${!tmp_num}
	while [ $NODE_INDEX -le $managed_server_num ]
	do
		CreateManagedServer $NODE_INDEX $CLUSTER_INDEX
		NODE_INDEX=`expr $NODE_INDEX + 1`
	done
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done

# INVOKING ADDMANAGED SERVER CODE
CLUSTER_INDEX=1
tmp_clust=0
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do
	$WLS_INSTALL_DIR/common/bin/wlst.sh $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addManagedServer_$CLUSTER_INDEX.py $DOMAIN_NAME cluster0$tmp_clust
      Check_error "ERROR:WHILE ADDING MANAGED SERVERS TO THE CLUSTER"
      echo "MANAGED SERVERS ADDED SUCCESSFULLY TO THE CLUSTER"
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
	tmp_clust=`expr $tmp_clust + 1`
done

# ADDING MANAGED SERVER TO THE CREATED CLUSTER -- END

# ADDING STANDALONE MANAGED SERVERS TO THE CREATED DOMAIN -- START
NODE_INDEX=1
while [ $NODE_INDEX -le $STANDALONE_MANAGEDSERVER_NUMBER ]
do
 cat << EOF > $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py
# Installation directories
BEA_HOME = '$BEA_HOME'
EOF
NODE_INDEX=`expr $NODE_INDEX + 1`
done
NODE_INDEX=1
while [ $NODE_INDEX -le $STANDALONE_MANAGEDSERVER_NUMBER ]
do 
	# ADDING THE STANDALONE MANAGED SERVERS DETAILS IN CONFIGURATION FILES
	AddStandAloneServersConf $NODE_INDEX
	# ADDING CREATE MACHINE FUNCTION CALLS IN CONFIGURATION FILE OF STANDALONE MANAGED SERVERS
	CreateStanAloneMachine $NODE_INDEX
	# ADDING CREATE STANDALONE MANAMAGED SERVER FUNCTION CALLS IN CONFIGURATION FILE
	CreateStandAloneManagedServer $NODE_INDEX
	# INVOKING ADDSTANDALONEMANAGED SERVER CODE
	echo "ADDING THE STANDALONE MANAGED SERVERS TO THE DOMAIN..."
	$WLS_INSTALL_DIR/common/bin/wlst.sh $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/addStandAloneManagedServer_$NODE_INDEX.py $DOMAIN_NAME
	Check_error "ERROR:WHILE ADDING STANDALONE MANAGED SERVERS TO THE DOMAIN"
    echo "STANDALONE MANAGED SERVERS ADDED SUCCESSFULLY TO THE DOMAIN"
	NODE_INDEX=`expr $NODE_INDEX + 1`
done

# ADDING STANDALONE MANAGED SERVERS TO THE CREATED DOMAIN -- END

# PACKING UP THE DOMAIN -- START
echo "PACKING THE CREATED DOMAIN..."
$WLS_INSTALL_DIR/common/bin/pack.sh -managed=true -domain=$WLS_INSTALL_DIR/samples/domains/$DOMAIN_NAME -template=$WLS_INSTALL_DIR/common/templates/domains/$DOMAIN_NAME.jar -template_name="$DOMAIN_NAME"
Check_error "ERROR:${DOMAIN_NAME}'s jar FILE NOT CREATED"
echo "${DOMAIN_NAME}.jar FILE CREATED SUCCESSFULLY"
# PACKING UP THE DOMAIN -- END

# COPYING THE JAR FILE TO EACH MANAGED SERVER OF THE CLUSTER -- START
CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do
    if [ $CLUSTER_INDEX -eq 1 ] ; then
	     cat << EOF > $WLSINSTALLERLOCATION/copy.exp
#!/usr/bin/expect
spawn scp root@$ADMIN_SERVER_IP:$WLS_INSTALL_DIR/common/templates/domains/$DOMAIN_NAME.jar root@${cluster_1_ip[0]}:$WLS_INSTALL_DIR/common/templates/domains  
expect "Are*"  
send "yes\r"  
expect "*password*"  
send "vmware\r"  
expect "Are*"  
send "yes\r"  
expect "*password*"  
send "vmware\r"  
expect eof 
EOF
		chown -R $WEBLOGIC_USER:$WEBLOGIC_GROUP $WLSINSTALLERLOCATION
		echo "COPIYNG THE ${DOMAIN_NAME}.jar FILE TO EACH MANAGED SERVERS"
		chmod 777 $WLSINSTALLERLOCATION/copy.exp
		$WLSINSTALLERLOCATION/copy.exp
		Check_error "ERROR:WHILE COPIYNG THE ${DOMAIN_NAME}.jar FILE TO EACH MANAGED SERVERS"
		NODE_INDEX=2
		tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
		managed_server_num=${!tmp_num}
		while [ $NODE_INDEX -le $managed_server_num ]
		do
			CopyJar $NODE_INDEX $CLUSTER_INDEX
			$WLSINSTALLERLOCATION/copy.exp
			Check_error "ERROR:WHILE COPIYNG THE ${DOMAIN_NAME}.jar FILE TO EACH MANAGED SERVERS"
			NODE_INDEX=`expr $NODE_INDEX + 1`
		done
	else
		NODE_INDEX=1
		tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
		managed_server_num=${!tmp_num}
		while [ $NODE_INDEX -le $managed_server_num ]
		do
               CopyJar $NODE_INDEX $CLUSTER_INDEX
               $WLSINSTALLERLOCATION/copy.exp
               Check_error "ERROR:WHILE COPIYNG THE ${DOMAIN_NAME}.jar FILE TO EACH MANAGED SERVERS"
               NODE_INDEX=`expr $NODE_INDEX + 1`
         done 
	fi
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done
# COPYING THE JAR FILE TO EACH MANAGED SERVER OF THE CLUSTER -- END

# COPYING THE PYTHON FILE TO ENROLL THE MANAGED SERVER TO THE CLUSTER -- START
cat << EOF > $WLS_INSTALL_DIR/samples/server/examples/src/examples/wlst/online/enrollnodemanager.py
BEA_HOME = '$BEA_HOME'
WL_HOME = '$WLS_INSTALL_DIR'
username = '$WEBLOGIC_USER'
password = '$WEBLOGIC_PASSWORD'
NM_HOME = WL_HOME + '/common/nodemanager'
DOMAIN_PATH = '$WLS_INSTALL_DIR/samples/domains/$DOMAIN_NAME'
connect(username,password,'t3://$ADMIN_SERVER_IP:$LISTENING_PORT')
nmEnroll(DOMAIN_PATH)
exit()
EOF

CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do
    NODE_INDEX=1
    tmp_num=cluster_managedservers_number[CLUSTER_INDEX-1]
    managed_server_num=${!tmp_num}
    while [ $NODE_INDEX -le $managed_server_num ]
    do
       CopyEnrollScript $NODE_INDEX $CLUSTER_INDEX
       $WLSINSTALLERLOCATION/copy.exp
       Check_error "ERROR:WHILE COPYING THE PYTHON FILE TO EACH MANAGED SERVERS"
       NODE_INDEX=`expr $NODE_INDEX + 1`
    done
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done
# COPYING THE PYTHON FILE TO ENROLL THE MANAGED SERVER TO THE CLUSTER -- END

#COPYING THE JAR FILE AND PYTHON FILE TO EACH STANDALONE MANAGED SERVER OF THE DOMAIN -- START
NODE_INDEX=1
while [ $NODE_INDEX -le $STANDALONE_MANAGEDSERVER_NUMBER ]
do
	CopyJarToStandAloneServer $NODE_INDEX
	echo "COPYING THE JAR FILE TO EACH STANDALONE MANAGED SERVER OF THE DOMAIN... "
	$WLSINSTALLERLOCATION/copy.exp
	Check_error "ERROR:WHILE COPIYNG THE ${DOMAIN_NAME}.jar FILE TO EACH MANAGED SERVERS"
	echo "${DOMAIN_NAME}.jar COPIED SUCCESSFULLY"
	echo "COPYING THE PYTHON FILE TO EACH STANDALONE MANAGED SERVER OF THE DOMAIN... "
	CopyEnrollScriptToStandAloneServer $NODE_INDEX
      $WLSINSTALLERLOCATION/copy.exp
	Check_error "ERROR:WHILE COPIYNG THE PYTHON FILE TO EACH MANAGED SERVERS"
	echo "PYTHON FILE COPIED SUCCESSFULLY"
	NODE_INDEX=`expr $NODE_INDEX + 1`
done
#COPYING THE JAR FILE AND PYTHON FILE TO EACH STANDALONE MANAGED SERVER OF THE DOMAIN -- END

# STARING NODEMANAGER ON ADMIN SERVER -- START
echo "STARING NODEMANAGER ON ADMIN SERVER..."
cd $WLS_INSTALL_DIR/server/bin
./startNodeManager.sh & sleep 150
Check_error "ERROR:WHILE STARTING NODEMANAGER ON ADMIN SERVER"
echo "NODEMANAGER ON ADMIN SERVER STARTED SUCCESSFULLY"
# STARING NODEMANAGER ON ADMIN SERVER -- END

# SCRIPT EXECUTION -- ENDs