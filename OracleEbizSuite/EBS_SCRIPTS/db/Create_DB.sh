#!/usr/bin/ksh
#

PATH=$PATH:/usr/bin/:/usr/sbin:/usr/ccs/bin/:/usr/bin/X11:/usr/local/bin:/usr/kerberos/bin:/usr/local/bin
export PATH

KSH_VERSION='@(#)PD KSH v5.2.14 99/07/13.2'
export KSH_VERSION

Proc_Log()
{
echo "`date` - ${S_PROC_MESSAGE} \n" | tee -a ${S_LOGFILE}
}

Error_Check()
{
if [ "$?" != "0" ]
then
        echo "********************************" | tee -a ${O_LOGFILE}
        echo "Failure in Cloning Procedure" | tee -a ${O_LOGFILE}
        echo "Error whilst ${S_PROC_MESSAGE} " | tee -a ${O_LOGFILE}
        echo "********************************" | tee -a ${O_LOGFILE}
	echo="******** Procedure Aborted *******" | tee -a ${O_LOGFILE}
	exit 2
fi
}

#
# End of Internal Procedure Calls

# Set Runtime variables

O_SCRIPTDIR="/oracle/clone/scripts"
O_LOGFILE="${O_SCRIPTDIR}/log/Clone_DB.log"
O_APPSINFO="${O_SCRIPTDIR}/APPS_INFO"
O_HOST=`hostname`


# Create New Log Files for DB Config

touch ${O_LOGFILE}_DB_Config

O_SID=`grep sid ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_PORT=`grep port ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_APPS=`grep apps ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_SYS=`grep system ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_SYSADMIN=`grep sysadmin ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_SEC=`grep sec ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_DBHOST=`grep dbhost ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_DBSNMP=`grep dbsnmp ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_XXVM=`grep xxvm ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_APPSRDONLY=`grep appsrdonly ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_VERTEX=`grep vertex ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_XXVMPORTAL=`grep xxvmportal ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_XXVMMYLEARN=`grep xxvmmylearn ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_EBSINTGR=`grep ebsintgr ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_PORTALREADONLY=`grep portalreadonly ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_XXVMHRBPCUSER=`grep xxvmhrbpcuser ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_CSSHT=`grep cssht ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_FINBILOADUSER=`grep finbiloaduser ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
O_HRREADONLY=`grep hrreadonly ${O_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`

#
# Configure Database Tier
#

#
S_PROC_MESSAGE="Perform Configuration of Database Tier "; Proc_Log
#

cd /oracle/app/oracle/product/10.2.0/db/appsutil/clone/bin

/oracle/clone/scripts/DB_Config.sh ${O_SEC} ${O_SID} ${O_DBHOST} ${O_PORT}| tee -a ${O_LOGFILE}_DB_Config
Error_Check

#
# Update Database User Passwords
#

#
S_PROC_MESSAGE="Update Database User Passwords "; Proc_Log
#
echo "Updating Database User Passwords" | tee -a ${O_LOGFILE}

. /oracle/app/oracle/product/10.2.0/db/${O_SID}_${O_HOST}.env

sqlplus -s '/ as sysdba' <<**DBAPAS  | tee -a ${O_LOGFILE}

alter user system identified by ${O_SYS};
alter user sys identified by ${O_SYS};
alter user dbsnmp identified by ${O_DBSNMP};
alter user xxvm identified by ${O_XXVM};
alter user appsrdonly identified by ${O_APPSRDONLY};
alter user vertex identified by ${O_VERTEX};
alter user xxvmportal identified by ${O_XXVMPORTAL};
alter user XXVM_MYLEARN identified by ${O_XXVMMYLEARN};
alter user ebs_intgr identified by ${O_EBSINTGR};
alter user portal_readonly identified by ${O_PORTALREADONLY};
alter user xxvm_hr_bpc_user identified by ${O_XXVMHRBPCUSER};
alter user cssht identified by ${O_CSSHT};
alter user FINBI_LOAD_USER identified by ${O_FINBILOADUSER};
alter user HRREADONLY identified by ${O_HRREADONLY};

exit
**DBAPAS
Error_Check

#
#Cleanup FND_NODES
#

S_PROC_MESSAGE="Cleanup FND_NODES"; Proc_Log

echo "Cleaningup FND_NODES" | tee -a ${O_LOGFILE}

. /oracle/app/oracle/product/10.2.0/db/${O_SID}_${O_HOST}.env

sqlplus -s apps/${O_SEC} <<**FNDNODE | tee -a ${O_LOGFILE}
EXEC FND_CONC_CLONE.SETUP_CLEAN;
commit;
exit
**FNDNODE
Error_Check

