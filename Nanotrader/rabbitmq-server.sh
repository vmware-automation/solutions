#!/bin/bash
env > /tmp/env.sh
set -e
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/groovy-1.8.6/bin
export JAVA_HOME=/usr/java/jre-vmware
#
# Setup for Erlang
#    
if [[ -n ${httpproxy} && -n ${httpport} ]]; 
then
    export http_proxy="http://${httpproxy}:${httpport}" 
    export https_proxy="http://${httpproxy}:${httpport}" 
fi

#
# Download the EPEL first and then install
# This is required by erlang 
#
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -ivh epel-release-5-4.noarch.rpm
yum install -y erlang
#
# Install RabbitMQ 
#
if [[ -n ${httpproxy} && -n ${httpport} ]]; 
then
    rpm -Uvh --httpport $httpport --httpproxy $httpproxy $rabbit_rpm
else
    rpm -Uvh $rabbit_rpm
fi

service rabbitmq-server start
sleep 10
service rabbitmq-server status

