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
    export http_proxy="http://${httpproxy}:${httpport}"
    export https_proxy="http://${httpproxy}:${httpport}"
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
sqlfdir="server-"`echo $myip| sed -n 's!\.!-!gp'`
echo Debug: $myip $sqlfdir
#
# Remove myip from the list and prepare cmd line options for sqlf locator 
# Create a commma separated list
#
locatorslist=''
for ((i=0; i<${#locators[@]}; i++))
do    
    if [[ -z $locatorslist ]]
        then
            locatorslist="${locators[$i]}[$peer_disc_port]"
        else
            locatorslist+=",${locators[$i]}[$peer_disc_port]"
    fi    
done
echo locatorslist ${locatorslist}
cd /opt/vmware/vfabric-sqlfire/vFabric_SQLFire*
mkdir $sqlfdir

echo ./bin/sqlf server start -J-Xms128m -J-Xmx512m -J-Dsqlfire.prefer-netserver-ipaddress=true \
-locators=$locatorslist -client-bind-address=$myip \
-client-port=$client_port -dir=$sqlfdir \
-J-Dsqlfire.prefer-netserver-ipaddress=true \
-license-serial-number=Y550V-40GEL-M8H8P-0PP9T-Z4FFZ 
#-init-scripts=$init_script

./bin/sqlf server start -J-Xms128m -J-Xmx512m \
-locators=$locatorslist -client-bind-address=$myip \
-client-port=$client_port -dir=$sqlfdir \
-J-Dsqlfire.prefer-netserver-ipaddress=true \
-license-serial-number=Y550V-40GEL-M8H8P-0PP9T-Z4FFZ 


##
## NOTE: Among the SQLFire Peers find the VM with lowest 
## IP address by string comparison. This VM will generate the data
## 
lowestIP=${sqlf_peers[0]}
for ((i=1; i<${#sqlf_peers[@]}; i++))
do
   if [[ "${sqlf_peers[i]}" < "$lowestIP" ]]
   then
       lowestIP=${sqlf_peers[i]}
   fi
done

## Download the DataGenerator, create SQLF Schema 
## on Webserver, we will create the tables via REST API
##
if [[ "$lowestIP" == "$myip" ]]
then
    echo Downloading Datagenerator zip to initialize Nanotrader
    wget --no-check-certificate -q $datagen_zip
    zipname=${datagen_zip##*/}
    stemname=${zipname%%.zip}
    unzip -qq $zipname -d $stemname
    cd $stemname
    sed -i "s/nanodbserver/${locators[0]}/" nanotrader.sqlf.properties
    ./createSqlfSchema
fi

