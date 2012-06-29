#!/bin/bash

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
WSINSTALLERLOCATION="$INSTALL_BASE/wsinstaller"
PROFILE_NAME="$profile_name"
PROFILE_PATH="$INSTALL_BASE/WebSphere/AppServer/profiles/$PROFILE_NAME"
CLUSTER_NUMBER="$cluster_number"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"

## Function To Display Error and Exit
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

function array_length()
{
	para=("${!1}")
	length=0
	for index in ${para[@]}
	do
		length=`expr $length + 1`
	done
	return $length
}

# CREATING CLUSTER(s) -- START

# CREATING CreateCluster.py FILE
cat << EOF > $WSINSTALLERLOCATION/CreateCluster.py
EOF

CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUMBER ]
do
	echo "print 'CREATING cluster_$CLUSTER_INDEX...'" >> $WSINSTALLERLOCATION/CreateCluster.py
	echo "AdminTask.createCluster('[-clusterConfig [-clusterName cluster_$CLUSTER_INDEX -preferLocal false -clusterType APPLICATION_SERVER] -replicationDomain [-createDomain true]]')" >> $WSINSTALLERLOCATION/CreateCluster.py
	echo "print 'ADDING SERVER(s) ONTO cluster_$CLUSTER_INDEX...'" >> $WSINSTALLERLOCATION/CreateCluster.py
	
	array_length cluster_"$CLUSTER_INDEX"_hostname[@] ;
	len=$?
	NODE_INDEX=1
	while [ $NODE_INDEX -le $len ]
	do
		tmp_hostname=cluster_`expr $CLUSTER_INDEX`_hostname[$NODE_INDEX-1]
		hostname=${!tmp_hostname}
		echo "AdminTask.createClusterMember(['-clusterName', 'cluster_`expr $CLUSTER_INDEX`', '-memberConfig', '[-memberNode "$hostname"_node -memberName "$hostname"_server -genUniquePorts true -replicatorEntry true]'])" >> $WSINSTALLERLOCATION/CreateCluster.py
		NODE_INDEX=`expr $NODE_INDEX + 1`
	done
	echo "AdminConfig.save()" >> $WSINSTALLERLOCATION/CreateCluster.py
	echo " " >> $WSINSTALLERLOCATION/CreateCluster.py
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done

# INVOKING CreateCluster.py PYTHON FILE CODE
cd $PROFILE_PATH/bin
./wsadmin.sh -lang jython -f $WSINSTALLERLOCATION/CreateCluster.py -username $ADMIN_USERNAME -password $ADMIN_PASSWORD
# CREATING CLUSTER(s) -- END

# STARTING ALL CLUSTERS -- START
echo "STARTING ALL CLUSTERS..."
./wsadmin.sh -lang jython -c "AdminClusterManagement.startAllClusters()" -username $ADMIN_USERNAME -password $ADMIN_PASSWORD
check_error "ERROR WHILE STARTING THE CLUSTERS"
echo "ALL CLUSTERS STARTED SUCCESSFULLY"
# STARTING ALL CLUSTERS -- END