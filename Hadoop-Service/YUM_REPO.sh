#!/bin/bash
set -e


basearch=`uname -p`
if [ $basearch == "i686" ] ; then
   basearch=i386				
fi

DIST=`cat /etc/redhat-release |sed s/\ release.*//`
if [ "$DIST" = "CentOS" ] ; then
     releasever=5.8
     
else
	
	releasever=6.2
fi

repository_url=http://fr2.rpmfind.net/linux/centos/$releasever/os/$basearch/
echo $repository_url

if [ x$remove_all_repos = 'xtrue' ]; then 
   rm -rf /etc/yum.repos.d/*
fi 
	

cat > "/etc/yum.repos.d/$repository_name.repo" << YUMREPOCONFIG
[$repository_name]
name=$repository_name
baseurl=$repository_url
enabled=1
gpgcheck=0
YUMREPOCONFIG