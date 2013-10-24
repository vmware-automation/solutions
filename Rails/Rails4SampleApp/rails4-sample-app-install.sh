#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE

### install latest postgres
echo Downloading postgres 9.3
try curl -O http://yum.postgresql.org/9.3/redhat/rhel-5-i386/pgdg-centos93-9.3-1.noarch.rpm
echo Installing postgres 9.3
try rpm -i pgdg-centos93-9.3-1.noarch.rpm
try yum -y --nogpgcheck install postgresql93 postgresql93-server postgresql93-libs postgresql93-devel postgresql93-contrib git
echo Initializing db
try service postgresql-9.3 initdb
echo Starting postgres
try service postgresql-9.3 start

