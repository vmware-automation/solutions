#!/bin/bash
set -e
env > /tmp/env.sh
#
# Note this installation is for Redhat and derivatives only. Modify appropriately for other Linux distros
#
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/groovy-1.8.6/bin
export JAVA_HOME=/usr/java/jre-vmware

#
# Setup EULA Acceptance, Not this is good for vfabric5.1 only
# Generic accept-vfabric-eula.txt does not work
# This enables automated install of vfabric products
#
mkdir -p /etc/vmware/vfabric
echo "I_ACCEPT_EULA_LOCATED_AT=$eula_location" >> /etc/vmware/vfabric/accept-vfabric5.1-eula.txt

#
# Download vFabric tcServer RPMs and Install
# 
if [[ -n ${httpproxy} && -n ${httpport} ]]; 
then
    rpm -U $vfabric_repo --httpproxy $httpproxy --httpport $httpport $vfabric_repo
    http_proxy="http://${httpproxy}:${httpport}"
    https_proxy="http://${httpproxy}:${httpport}"
    export http_proxy https_proxy
else
    rpm -U $vfabric_repo
fi

#
# Search for the vfabric_tcserver and install without checking the key - Warning not for production
#
yum search  $vfabric_tcserver
yum install -y --nogpgcheck $vfabric_tcserver 

wget -q $nano_tcserver_template
tar xvf nanotrader-template.tar -C /opt/vmware/vfabric-tc-server-standard/templates

## 
## Create a property file for the $app_name  
##
cat <<PROPERTIES > /tmp/${app_name}.properties
nanotrader.nanotrader.driverClassName=com.vmware.sqlfire.jdbc.ClientDriver
nanotrader.nanotrader.url=jdbc:sqlfire://${db_ip[0]}:1527/
nanotrader.nanotrader.username=nanotrader
nanotrader.nanotrader.password=nanotrader
nanotrader.nanotrader.validationQuery=select 1 from nanotrader.hibernate_sequences where sequence_name='ACCOUNT'
nanotrader.nanotrader.spring.profiles.active=production,jndi

PROPERTIES
## 
## Create an instance of nanotrader application 
##
cd /opt/vmware/vfabric-tc-server-standard/
echo ./tcruntime-instance.sh create $app_name -t nanotrader --properties-file /tmp/${app_name}.properties
./tcruntime-instance.sh create $app_name -t nanotrader --properties-file /tmp/${app_name}.properties

## 
## Edit JVM settings and setenv.sh
## 
sed -ie '/^JVM_OPTS/ s!=.*!="-Xmx712M -Xss512K -XX:MaxPermSize=512m"!' $app_name/bin/setenv.sh
echo "export NANO_RABBIT_HOST=$rmq_host" >> $app_name/bin/setenv.sh
echo "export NANO_RABBIT_PORT=$rmq_port" >> $app_name/bin/setenv.sh

##
## set execute bit on the jar files - tcServer fails otherwise
##
chmod +x $app_name/lib/*.jar


cd $app_name/webapps

#
# Pull down Nanotrader Application WAR files
#

wget -q -r -l1 -nd -np -A .war --no-check-certificate $nano_war_files

#
# Copy the WAR files to nanotrader webapps
#
for f in spring-nanotrader*.war
do
  warfile=${f/-[0-9]*SNAPSHOT/}
  mv $f /opt/vmware/vfabric-tc-server-standard/$app_name/webapps/$warfile
done

../bin/tcruntime-ctl.sh start

