#!/bin/bash
# Import global conf 
. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

# Locate the my.cnf file 
my_cnf_file=
if [ -f /etc/my.cnf ]; then 
    my_cnf_file=/etc/my.cnf
elif [ -f /etc/mysql/my.cnf ]; then 
    my_cnf_file=/etc/mysql/my.cnf
fi

if [ "x$my_cnf_file" = "x" ]; then 
    echo "Neither /etc/my.cnf nor /etc/mysql/my.cnf can be found, stopping configuration"
    exit 1
fi

# update mysql configuration to handle big packets
sed -ie "s/\[mysqld\]/\[mysqld\]\n\
max_allowed_packet=1024M/g" $my_cnf_file
# update listening port
sed -ie "s/\[mysqld\]/\[mysqld\]\n\
port=$db_port/g" $my_cnf_file

if [ "x$OS" != "x" ] && [ $OS = 'Ubuntu' ]; then
    # Make sure that MySQL is started 
    service mysql restart
else 
    # set up auto-start on booting
    chkconfig mysqld on
    # restart mysqld service
    service mysqld start
fi

# this will assign a password for mysql admin user 'root'
mysqladmin -u $db_root_username password $db_root_password

