#!/bin/bash
# Import global conf 
. $global_conf

set -e

#To support ubuntu java bins
export PATH=$PATH:/usr/java/jre-vmware/bin

# set the nfs path to get the demo war file.
NFS_PATH=$nfs_path

if [ -f /usr/java/jre-vmware/bin/java ]; then
    export JAVA_HOME=/usr/java/jre-vmware
else
    export JAVA_HOME=/usr
fi

# INSTALLING EXPECT PACKAGE
if [ -f /etc/redhat-release ] ; then
	DistroBasedOn='RedHat'
	DIST=`cat /etc/redhat-release |sed s/\ release.*//`
	REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
elif [ -f /etc/SuSE-release ] ; then
	DistroBasedOn='SuSe'
	REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
elif [ -f /etc/debian_version ] ; then
	DistroBasedOn='Debian'
	DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
	REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
fi

# INSTALLING NFS PACKAGE
if [ $DistroBasedOn == "Debian" ] ; then
	echo $DistroBasedOn
    echo $http_proxy
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y linux-firmware < /dev/console > /dev/console 
    # Install MySQL package 
    apt-get update -y
    apt-get -f -y install
    #apt-get -f -y install nfs-utils --fix-missing
	TYPE_MATCH=`uname -m`
		if  [ $TYPE_MATCH == "i686" ] ; then
			echo "32 bit machine"
			wget http://us.archive.ubuntu.com/ubuntu/pool/main/n/nfs-utils/nfs-kernel-server_1.2.4-1ubuntu2_i386.deb
			sudo dpkg -i nfs-kernel-server_1.2.4-1ubuntu2_i386.deb
		else
			echo "64 bit machine"
			wget http://us.archive.ubuntu.com/ubuntu/pool/main/n/nfs-utils/nfs-kernel-server_1.2.2-1ubuntu1_amd64.deb
			sudo dpkg -i nfs-kernel-server_1.2.2-1ubuntu1_amd64.deb
		fi 
elif [ $DistroBasedOn == "RedHat" ] ; then 
	yum --nogpgcheck --noplugins -y install nfs-utils 
elif [ "$DistroBasedOn" = "SuSe" ] ; then
	echo $DistroBasedOn
	zypper rr repo-oss
	zypper ar -f http://download.opensuse.org/distribution/11.2/repo/oss/ repo-oss
	zypper --non-interactive --no-gpg-checks ref
	zypper --non-interactive --no-gpg-checks install nfs-utils             
fi

#Mounting the NFS Drive
if [ "$DIST" = "CentOS" ] ; then
	/sbin/service portmap start
else
      /sbin/service rpcbind start
fi

echo "rpcbind call done...... "

echo "Mounting NFS..."
MOUNTPOINTLOCATION=/tmp/mount
mkdir $MOUNTPOINTLOCATION
mount ${NFS_PATH} $MOUNTPOINTLOCATION
echo "mounting done... "

if [ "$automatically_start" == "YES" ]; then
    # Start instance if one exists
    if [ -d $install_path/working/springsource-tc-server-standard/$instance_name/bin ]; then
		cd $install_path/working/springsource-tc-server-standard/$instance_name/bin
		echo "http://www.cs.brandeis.edu" >>/tmp/url.txt
		echo "http://www.nytimes.com" >>/tmp/url.txt
		echo "http://www.google.com" >>/tmp/url.txt
        nohup cp $MOUNTPOINTLOCATION/HadoopDemoApp.war $install_path/working/springsource-tc-server-standard/$instance_name/webapps
        nohup cp $MOUNTPOINTLOCATION/job.sh /tmp
        chmod 777 /tmp/job.sh
        ./tcruntime-ctl.sh start
    fi
else
    echo "Skipping startup"
fi

echo " "
echo " "
echo "----------------------------------------------------------"
echo "            Hadoop Sample Application"
echo "            -------------------------"
echo "   To use hadoop sample application access below url:"            
echo "   ->  $selfip:8080/HadoopDemoApp/Login.jsp"
echo "   ->  username/password : admin/admin"
echo "----------------------------------------------------------"