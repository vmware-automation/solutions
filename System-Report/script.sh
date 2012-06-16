#!/bin/sh

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vmware/bin:/usr/java/jre-vmware/bin:/opt/vmware/bin:/root/bin

echo "OS Kernel: "`uname -a`
echo
echo
echo "TCP Open Ports"
echo "--------------"
netstat -tan
echo
echo
echo "Process List"
echo "------------"
ps aux
echo
echo
echo "RPM Packages"
echo "------------"
rpm -qa
echo "RPM command not found"
echo
echo
echo "Local Users"
echo "-----------"
cat /etc/passwd | sed s/:.*//
echo
echo
echo "Disk Mounts"
echo "-----------"
df
echo
echo
echo "Memory Config"
echo "-------------"
free



