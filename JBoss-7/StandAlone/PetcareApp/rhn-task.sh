#!/bin/bash
set -e

# Import global conf 
. $global_conf

if [ "x$rhn_username" = "x" ] && [ "x$rhn_password" = "x" ]; then 
    echo "At least one of the rhn_username or the rhn_password properties is null. Please fix this before proceeding." 
    exit 1
else 
    # Register with RHN 
    /usr/sbin/rhnreg_ks --proxy=$http_proxy --profilename=VMware_AppDirector_$RANDOM --username="$rhn_username" --password="$rhn_password" 
fi 
