#!/bin/bash
set -e

# Import global conf 
. $global_conf

if [ x$remove_all_repos = 'xtrue' ]; then 
   rm -rf /etc/yum.repos.d/*
fi 

# Strip all chars that are not part of the whitelist 
fixed_repository_name=$(echo $repository_name | sed 's/[^-._a-zA-Z0-9]//')

if [ "x$fixed_repository_name" = "x" ]; then 
    echo "Illegal characters were stripped from the provided repository_name but now it's empty. Please fix the repository_name property before re-running. Allowed character include: a-z A-Z 0-9 . _ -"  
    exit 1
fi 

cat > "/etc/yum.repos.d/$fixed_repository_name.repo" << YUMREPOCONFIG
[$fixed_repository_name]
name=$fixed_repository_name
baseurl=$repository_url
gpgcheck=0
YUMREPOCONFIG

yum repolist 
