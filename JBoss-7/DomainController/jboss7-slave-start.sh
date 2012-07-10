#!/bin/bash
set -e

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOME_DIR=/home/jboss
export JBOSS_HOME=$HOME_DIR/$JBOSS_NAME_AND_VERSION/jboss-as

echo "Starting slave instance $slave_name. Log is located at /var/log/jboss-as/console.log."
service jboss start
