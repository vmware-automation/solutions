#!/bin/bash
# Import global conf 
. $global_conf

set -e

#To support ubuntu java bins
export PATH=$PATH:/usr/java/jre-vmware/bin


if [ -f /usr/java/jre-vmware/bin/java ]; then
    export JAVA_HOME=/usr/java/jre-vmware
else
    export JAVA_HOME=/usr
fi


if [ ! "$instance_name" == "" ]; then
    # Create new instance
    cd $install_path/working/springsource-tc-server-standard

    if [ "$use_ajp" = "YES" ]; then 
        ./tcruntime-instance.sh create $instance_name -v 6.0.29.B.RELEASE --template bio --template ajp 
    else 
        ./tcruntime-instance.sh create $instance_name -v 6.0.29.B.RELEASE 
    fi 

    export instance_dir="$install_path/working/springsource-tc-server-standard/$instance_name"
    export webapps_dir="$instance_dir/webapps"       
    export service_start="$instance_dir/bin/tcruntime-ctl.sh start"
    export service_stop="$instance_dir/bin/tcruntime-ctl.sh stop"
    export service_restart="$instance_dir/bin/tcruntime-ctl.sh restart"

    # Add the jvmRoute attr to the Engine 
    sed -ie "s/\(Engine defaultHost=\"localhost\"\)$/\1 jvmRoute=\"${JVM_ROUTE}\"/" ${instance_dir}/conf/server.xml 

fi