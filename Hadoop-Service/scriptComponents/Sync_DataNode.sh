#!/bin/bash

# Function To Display Error and Exit
function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

# PARAMETER VALIDATION 
if [ "x${datanode}" = "x" ]; then 
    error_exit "datanode not set."
fi

if [ "x${tasktracker}" = "x" ]; then 
    error_exit "tasktracker not set."
fi

if [ "x${data_hosts}" = "x" ]; then 
    error_exit "data_hosts not set."
fi

if [ "x${task_hosts}" = "x" ]; then 
    error_exit "task_hosts not set."
fi 

DNS_NAME=`dnsdomainname`

IP_ARRAY_LENGTH=`echo ${#datanode[*]}`
	for (( i=0;i<$IP_ARRAY_LENGTH;i++)); do
            echo "${datanode[${i}]}    ${data_hosts[i]}.$DNS_NAME    ${data_hosts[i]}">> /etc/hosts
            echo "${tasktracker[${i}]}    ${task_hosts[i]}.$DNS_NAME    ${task_hosts[i]}">> /etc/hosts
    done
echo "DataNode Sync Done"