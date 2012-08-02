#!/bin/bash
env > /tmp/env.sh
set -e
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/groovy-1.8.6/bin
export JAVA_HOME=/usr/java/jre-vmware

#
# Setup EULA Acceptance, Not this is good for vfabric5.1 only
# Generic accept-vfabric-eula.txt does not work
#
mkdir -p /etc/vmware/vfabric
echo "I_ACCEPT_EULA_LOCATED_AT=$eula_location" >> /etc/vmware/vfabric/accept-vfabric5.1-eula.txt
#
# Download SQLFire RPMs and Install
#
if [[ -n ${httpproxy} && -n ${httpport} ]]; 
then
    rpm -U --httpproxy $httpproxy --httpport $httpport $vfabric_repo
    http_proxy="http://${httpproxy}:${httpport}"
    https_proxy="http://${httpproxy}:${httpport}"
    export http_proxy https_proxy
else
    rpm -U $vfabric_repo
fi

#
# Search for the vfabric_tcserver and install without checking the key - Warning not for production
#
yum search  vfabric
yum install -y --nogpgcheck $vfabric_sqlfire 
#
# Get this SQLFire's IP address and makeup locator directory name
#
myip=`ifconfig eth0 | sed -n 's!.*inet *addr:\([0-9\.]*\).*!\1!p'`
sqlfdir="locator-"`echo $myip| sed -n 's!\.!-!gp'`
echo Debug: $myip $locdir

# 
# Create a commma separated list
#
otherlocators=''
for ((i=0; i<${#locators[@]}; i++))
do       
    if [[ -z $otherlocators ]]
    then
        otherlocators="${locators[$i]}[$peer_disc_port]"
    else
        otherlocators+=",${locators[$i]}[$peer_disc_port]"
    fi    
done
echo otherlocators ${otherlocators}

cd /opt/vmware/vfabric-sqlfire/vFabric*SQLFire*
mkdir $sqlfdir

echo ./bin/sqlf locator start -dir=$sqlfdir -peer-discovery-address=$myip -peer-discovery-port=$peer_disc_port \
-locators=$otherlocators -client-bind-address=$myip -client-port=$client_port -J-Dsqlfire.prefer-netserver-ipaddress=true


./bin/sqlf locator start -dir=$sqlfdir -peer-discovery-address=$myip -peer-discovery-port=$peer_disc_port \
-locators=$otherlocators -client-bind-address=$myip -client-port=$client_port -J-Dsqlfire.prefer-netserver-ipaddress=true

