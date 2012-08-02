#!/bin/bash

######### Sample parameters ###################
#cluster_ips map it to Blueprint Variable 
#user=root
#password=vmware
#vcenter=172.16.227.133
#script_home=http://172.16.227.1/~esiemes/vFabricApplicationDirectorExtensions-full.tar
#rulename=MyRuleXYZ


######### Download the package ################
DIR=$PWD
cd /tmp
wget $script_home
tar xvf vFabricApplicationDirectorExtensions-full.tar

######### Handle type String and Array ########
for (( i = 0 ; i < ${#cluster_ips[@]} ; i++ )) do
if [ "$i" != '0' ]; then
IPS=$IPS,
fi
IPS=$IPS${cluster_ips[$i]}
done

java -cp vFabricApplicationDirectorExtensions.jar:vijava520110926.jar:dom4j-1.6.1.jar com.springsource.pso.vfabricappd.extensions.Main -r "antiaffinity" -u "$user" -v "$vcenter" -p "$password" -ips "$IPS" -n "$rulename"
RESULT=$?

cd $DIR
exit $RESULT
