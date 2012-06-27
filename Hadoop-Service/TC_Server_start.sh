#!/bin/bash
# Import global conf 
. $global_conf

set -e

#To support ubuntu java bins
export PATH=$PATH:/usr/java/jre-vmware/bin
export http_proxy=http://proxy.vmware.com:3128

if [ -f /usr/java/jre-vmware/bin/java ]; then
    export JAVA_HOME=/usr/java/jre-vmware
else
    export JAVA_HOME=/usr
fi

echo "Mounting WebLogic Installer..."
yum --nogpgcheck --noplugins -y install nfs-utils expect
/sbin/service rpcbind start

echo "rpcbind call done... " 

MOUNTPOINTLOCATION=/tmp/mount
mkdir $MOUNTPOINTLOCATION
NFSPATH="10.150.118.52:/share/mount"
mount 10.150.118.52:/share/mount /tmp/mount

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