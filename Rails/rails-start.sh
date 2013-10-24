#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE

# Start Apache 
echo "Starting Apache httpd"
try service httpd restart

ipaddr=$(ifconfig eth0 | grep 'inet addr' | awk -F: {'print $2'} | awk {'print $1'})
echo "Visit http://$ipaddr to confirm environment."
