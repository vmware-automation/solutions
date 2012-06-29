#!/bin/bash

# JBOSS_USER - User who owns the installation and process defaults jboss
# JBOSS_NAME_AND_VERSION = name of the top-level directory created by the ZIP file, e.g. 'jboss-eap-5.1'
# JBOSS_MGMT_USER = Mgmt administrator's user name
# JBOSS_MGMT_PWD = Mgmt administrator's password
# JVM_ROUTE = The route defaults 0

. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

service jboss start
