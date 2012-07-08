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
        echo "********************************" | tee -a ${A_LOGFILE}
        echo "Failure in Cloning Procedure" | tee -a ${A_LOGFILE}
        echo "Error whilst ${S_PROC_MESSAGE} " | tee -a ${A_LOGFILE}
        echo "********************************" | tee -a ${A_LOGFILE}
	echo="******** Procedure Aborted *******" | tee -a ${A_LOGFILE}
	exit 2
fi
}

#
# End of Internal Procedure Calls

# Set Runtime variables

A_SCRIPTDIR="/oracle/clone/scripts"
A_LOGFILE="${A_SCRIPTDIR}/log/Clone_CM.log"
A_APPSINFO="${A_SCRIPTDIR}/APPS_INFO"
A_HOST=`hostname`


# Create New Log Files for CM Config

touch ${A_LOGFILE}_CM_Config ${A_LOGFILE}_AutoConfig

A_SID=`grep sid ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_PORT=`grep port ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_APPS=`grep apps ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_SYS=`grep system ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_SYSADMIN=`grep sysadmin ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_SEC=`grep sec ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_DBHOST=`grep dbhost ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_CMHOST=`grep cmhost ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`
A_APHOST=`grep aphost ${A_SCRIPTDIR}/APPS_INFO | awk -F= '{print $2}'`


# Convert SID from upper case to lower case for application directories

L_SID=`expr ${A_SID}| tr '[A-Z]' '[a-z]'`
echo "Lower case of SID is ${L_SID}" | tee -a ${A_LOGFILE}


# Configure Application Tier - Concurrent Manager

S_PROC_MESSAGE="Perform Configuration of Concurrent Manager Tier "; Proc_Log

cd /oracle/d1/applmgr/${A_SID}/${L_SID}comn/clone/bin

/oracle/clone/scripts/APPS_Config_CM.sh ${A_SEC} ${A_SID} ${A_DBHOST} ${A_CMHOST} ${A_APHOST} ${L_SID} ${A_PORT} | tee -a ${A_LOGFILE}_CM_Config

Error_Check

# Shutdown Concurrent Manager Tier Services

S_PROC_MESSAGE="Stopping Concurrent Manager Services"; Proc_Log

. /oracle/d1/applmgr/${A_SID}/${L_SID}appl/APPS${A_SID}_${A_CMHOST}.env
$COMMON_TOP/admin/scripts/${A_SID}_${A_CMHOST}/adstpall.sh apps/${A_SEC}
sleep 100


S_PROC_MESSAGE="Running txkrun.pl in Concurrent Manager tier"; Proc_Log

txkrun.pl -script=SetAdvCfg -appsuser=apps -appspass=${A_SEC} -enable=FormsLsnrServlet

# Run Autoconfig

S_PROC_MESSAGE="Running Autoconfig"; Proc_Log

. /oracle/d1/applmgr/${A_SID}/${L_SID}appl/APPS${A_SID}_${A_CMHOST}.env

cd $COMMON_TOP/admin/scripts/${A_SID}_${A_CMHOST}
/oracle/clone/scripts/AutoConfig.sh ${A_SEC} | tee -a ${A_LOGFILE}_AutoConfig
Error_Check

# Run txkSOHM.pl in Concurrent Manager Tier 

S_PROC_MESSAGE="Running txkSOHM.pl un Concurrent Manager Tier "; Proc_Log

A_XML="/oracle/d1/applmgr/${A_SID}/${L_SID}appl/admin/${A_SID}_${A_CMHOST}.xml"
A_ITYPE="primary"
A_O806="/oracle/d1/applmgr/${A_SID}/${L_SID}ora/8.0.6"
A_IAS="/oracle/d1/applmgr/${A_SID}/${L_SID}ora/iAS"
mkdir /oracle/config_top
A_CONTOP="/oracle/config_top"


. /oracle/d1/applmgr/${A_SID}/${L_SID}appl/APPS${A_SID}_${A_CMHOST}.env
cd /oracle/d1/applmgr/${A_SID}/${L_SID}appl/fnd/11.5.0/patch/115/bin

/oracle/clone/scripts/txksohm.sh ${A_SID} ${L_SID} ${A_XML} ${A_ITYPE} ${A_O806} ${A_IAS} ${A_CONTOP} ${A_APPS} | tee -a ${A_LOGFILE} 

Error_Check
