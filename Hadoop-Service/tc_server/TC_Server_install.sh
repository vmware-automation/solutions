#!/bin/sh
# Import global conf 
. $global_conf

set -e

#To support ubuntu java bins
export PATH=$PATH:/usr/java/jre-vmware/bin


if [ -d $install_path/working/springsource-tc-server-standard ]; then
    echo "tc Server already installed.  Skipping installation."
else
    echo "Starting tc Server installation."
    mkdir -p $install_path/packages
    mv $tcserver_package $install_path/packages/springsource-tc-server-standard-2-RELEASE.tar.gz
    mv $installer $install_path/installer

    chmod 755 $install_path/installer

    if [ -f /usr/java/jre-vmware/bin/java ]; then
        export JAVA_HOME=/usr/java/jre-vmware
    else
        export JAVA_HOME=/usr
    fi

    cd $install_path
    ./installer  --setup-tcserver

    #remove default "instance1"
    cd $install_path/working/springsource-tc-server-standard/instance1/bin/
    ./tcruntime-ctl.sh stop
    rm -rf $install_path/working/springsource-tc-server-standard/instance1
fi