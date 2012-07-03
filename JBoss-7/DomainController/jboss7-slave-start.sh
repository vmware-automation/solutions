#!/bin/bash

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e
HOME_DIR=/home/jboss
export JBOSS_HOME=$HOME_DIR/$JBOSS_NAME_AND_VERSION/jboss-as

# We can't start the slave until the property 'jboss.domain.master.address' is set to the address of the domain controller in
# $JBOSS_HOME/system.properties

echo "Before this slave can be started and registered with the domain controller you need to provide the address of the controller"
echo "With an editor, edit $JBOSS_HOME/system.properties"
echo "After the jboss.domain.master.address= replace the text with the address or fully qualified hostname of the controller"
echo "Start jboss service by issuing the command as root: service jboss start"
echo "Check both this slave instance and the controller logs located at /var/log/jboss-as/console.log to verify registration happens"
