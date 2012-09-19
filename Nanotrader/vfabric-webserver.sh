#!/bin/bash
set -e
env > /tmp/env.sh
#
# Note this installation is for Redhat and derivatives only. Modify appropriately for other Linux distros
#
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/groovy-1.8.6/bin
export JAVA_HOME=/usr/java/jre-vmware
export VFABRIC_BASE=/opt/vmware/vfabric-web-server
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
yum install -y --nogpgcheck $vfabric_webserver 

#
# cd to vFabric-Web-Server home
#
cd $VFABRIC_BASE
./fixrootpath.pl
./newserver.pl --server=$ws_instance --quiet
echo "Include conf/extra/httpd-nanotrader.conf" >> $ws_instance/conf/httpd.conf
####
#### create httpd-nanotrader.conf file
####
nano_doc_root=/var/www/nanoclient

SUBSTR=""
for (( i = 0 ; i < ${#tcs_nodes_ip[@]} ; i++ )); do
         SUBSTR="$SUBSTR"$'\n'"BalancerMember http://${tcs_nodes_ip[$i]}:8080"
done
echo "DEBUG: Proxy load balancer config: "$SUBSTR

SUBSTR_REVERSE=""
echo "DEBUG: ${tcs_nodes_ip[@]}"
for (( i = 0 ; i < ${#tcs_nodes_ip[@]} ; i++ )); do
         SUBSTR_REVERSE="$SUBSTR_REVERSE"$'\n'"ProxyPassReverse /spring-nanotrader-services http://${tcs_nodes_ip[$i]}:8080/spring-nanotrader-services"
done

cat <<EOF > $ws_instance/conf/extra/httpd-nanotrader.conf
<VirtualHost *:80>
  DocumentRoot "/var/www/nanoclient/spring-nanotrader-web"
  ServerName $ws_ip:80

  <Location /balancer-manager>
    SetHandler balancer-manager
    Order Deny,Allow
    Deny from all
    Allow from $ws_ip
  </Location>

  <Directory ${nano_doc_root}/*>
     Order deny,allow
     Allow from all
     SetHandler None
  </Directory>
  <Proxy balancer://nanocluster>
      $SUBSTR
     ProxySet lbmethod=byrequests
  </Proxy>
  ProxyPass /spring-nanotrader-services balancer://nanocluster/spring-nanotrader-services 
  $SUBSTR_REVERSE
</VirtualHost>
EOF


# install the static client files
nanotrader_home=${nano_doc_root}/spring-nanotrader-web
mkdir -p $nanotrader_home
cd $nanotrader_home
wget --no-check-certificate $web_war_file -q

unzip -q spring-nanotrader-web*.war
sleep 10
rm -rf spring-nanotrader-web*.war
echo $VFABRIC_BASE/$ws_instance/bin/httpdctl start
$VFABRIC_BASE/$ws_instance/bin/httpdctl start
PREVDIR=$PWD

#
# echo Downloading Datagenerator zip to generate/load Nanotrader database
#
cd /tmp
wget --no-check-certificate -q $datagen_zip
zipname=${datagen_zip##*/}
stemname=${zipname%%.zip}
unzip -qq $zipname -d $stemname
cd $stemname
### Replace localhost with first tcServer IP address

sed -i "/^appServerHost/ s/localhost/${tcs_nodes_ip[0]}/" nanotrader.properties
./generateData

echo Generated Sample Data for Nanotrader

