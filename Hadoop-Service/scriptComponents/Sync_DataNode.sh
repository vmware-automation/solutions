#!/bin/bash

DNS_NAME=`dnsdomainname`

IP_ARRAY_LENGTH=`echo ${#DN[*]}`
	for (( i=0;i<$IP_ARRAY_LENGTH;i++)); do
            echo "${DN[${i}]}    ${DATA_HOSTS[i]}.$DNS_NAME    ${DATA_HOSTS[i]}">> /etc/hosts
            echo "${TT[${i}]}    ${TASK_HOSTS[i]}.$DNS_NAME    ${TASK_HOSTS[i]}">> /etc/hosts
    done
echo "DataNode Sync Done"