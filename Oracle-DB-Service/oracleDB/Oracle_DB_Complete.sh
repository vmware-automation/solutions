#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vmware/bin:/opt/vmware/bin
export HOME=/root
export PATH=$PATH:/usr/local/sbin/
export PATH=$PATH:/usr/sbin/
export PATH=$PATH:/sbin

# TESTED ON CENTOS
if [ -x /usr/sbin/selinuxenabled ] && /usr/sbin/selinuxenabled; then
    if [ -x /usr/sbin/setenforce ]; then
        /usr/sbin/setenforce Permissive
    else
        echo 'SELINUX IS ENABLED. THIS MAY CAUSE INSTALLATION TO FAIL.'
    fi
fi

#########MAKE SWAPFILE FOR INSTALLER#############
#ORACLE INSTALLER WILL TEST FOR A SWAP SIZE OF 150M, THIS GARUNTEES WE HAVE IT
dd if=/dev/zero of=/tmp/swapfile bs=1024 count=150000
mkswap /tmp/swapfile
swapon /tmp/swapfile

#########PARAMTERS FROM APP DIRECTOR#########
SELECTED_LANGUAGES="$selected_languages"
ORACLE_BASE="$oracle_base"
INSTALL_EDITION="$install_edition"
EMAIL_ADDRESS="$email_address"
LISTENER_PROTOCOL="$listener_protocol"
LISTENER_PORT="$listener_port"
GDBNAME="$gdbname"
SID="$sid"
SYSTEMPASSWORD="$systempassword"
SYSPASSWORD="$syspassword"
ORACLE_HOSTNAME="$oracle_hostname"
INVENTORY_LOCATION="$inventory_location"
ORACLE_HOME="$oracle_home"
NFSPATH="$nfspath"
ORACLE_HOME="$ORACLE_BASE/product/11.2.0/db_1"
INVENTORY_LOCATION="$ORACLE_BASE/oraInventory"
ZYPPER_REPOSITORY="$zypper_repository"
URL_DISK1_32BIT="$url_disk1_32bit"
URL_DISK2_32BIT="$url_disk2_32bit"
URL_DISK1_64BIT="$url_disk1_64bit"
URL_DISK2_64BIT="$url_disk2_64bit"

#########SCRIPT INTERNAL PARAMETERS#########
#MOUNTPOINTLOCATION=/tmp/mount
ORCALEINSTALLERLOCATION="$ORACLE_BASE/orclinstaller"
SYSCTLCONF="/etc/sysctl.conf"
ORACLEINSTALLSCRIPT="$ORCALEINSTALLERLOCATION/orclscript_runinstaller.sh"
ORACLENETCACONFIGURATIONSCRIPT="$ORCALEINSTALLERLOCATION/orclscript_netca_configuration.sh"
ORACLEDBCACONFIGURATIONSCRIPT="$ORCALEINSTALLERLOCATION/orclscript_dbca_configuration.sh"

#RESPONSE FILE LOCATION
DBFILE="$ORCALEINSTALLERLOCATION/database/response/db_install.rsp"
NETCAFILE="$ORCALEINSTALLERLOCATION/database/response/netca.rsp"
DBCAFILE="$ORCALEINSTALLERLOCATION/database/response/dbca.rsp"

#RESPONSE FILE BACKUP LOCATION
DBFILE_BACKUP="$ORCALEINSTALLERLOCATION/database/response/db_install-original.rsp"
NETCAFILE_BACKUP="$ORCALEINSTALLERLOCATION/database/response/netca-original.rsp"
DBCAFILE_BACKUP="$ORCALEINSTALLERLOCATION/database/response/dbca-original.rsp"
PROGNAME=`basename $0`

#ARRAY
INSTALL_EDITION_ARRAY=(EE SE SEONE PE)
LISTENER_PROTOCOL_ARRAY=(TCP TCPS NMP IPC VI)
LANG_ARRAY=(en fr ar bn pt_BR bg fr_CA ca hr cs da nl ar_EG en_GB et fi de el iw hu is in it ja ko es lv lt ms es_MX no pl pt ro ru zh_CN sk sl es_ES sv th zh_TW tr uk vi)

###########PARAMTER VALIDATION FUNCTIONS##################
## CHECK STRING CONTENTS 
function string_contains() {
   stringToCheck=$1
   valueToLookFor=$2
   if [[ "$stringToCheck" == *"$valueToLookFor"* ]]
   then
       return 1;
   else
       return 0;
   fi
}

## FUNCTION TO DISPLAY ERROR AND EXIT
function check_error()
{
    if [ ! "$?" = "0" ]; then
        error_exit "$1";
    fi
}

function error_exit()
{
    echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    exit 1
}

## FUNCTION TO VALIDATE INTEGER 
function valid_int()
{
local data=$1
    if [[ $data =~ ^[0-9]{1,9}$ ]]; then
        return 0;
    else
        return 1
    fi
}

function check_install_edition()
{
    len=${#INSTALL_EDITION_ARRAY[*]}
    local temp=$1;
    for (( i=0; $i < $len; i++ )) do
    if [ "${INSTALL_EDITION_ARRAY[$i]}" = "$temp" ]; then
        return;
    fi
    done
    error_exit "INVALID INSTALL EDITION"
}

function check_listener_protocol()
{
    len=${#LISTENER_PROTOCOL_ARRAY[*]}
    local temp=$1;
    for (( i=0; $i < $len; i++ )) do
    if [ "${LISTENER_PROTOCOL_ARRAY[$i]}" = "$temp" ]; then
        return;
    fi
    done
    error_exit "INVALID LISTENER PROTOCOL"
}

function check_lang() 
 { 
len=${#LANG_ARRAY[*]} 
local temp=`echo $1 | tr ',' ' '`; 
local result=-1; 
for j in $temp ; 
do 
for (( i=0; $i < $len; i++ )) 
do 
if [ "${LANG_ARRAY[$i]}" = "$j" ]; then 
    result=0; 
    break; 
fi 
done 
if [ $result = 0 ] ; then 
    result=-1; 
    else 
error_exit "INVALID LANGUAGE" 
fi 
done 
return 0; 
} 

 
function check_email() 
{ 
    local email=$1; 
    case $email in 
    *@?*.?*) ;; 
    *) error_exit "Invalid EMAIL ID"; false ;; 
    esac 
} 
 
function echo_d()  
{ 
    CURDATE=`date +%H:%M:%S` 
    echo -e $CURDATE  "$*" 
} 
 
####################SCRIPT EXECUTION ##################
echo "PARAMTER VALIDATION"

if [ "x${ORACLE_HOSTNAME}" = "x" ]; then 
    error_exit "ORACLE_HOSTNAME not set."
fi

if [ "x${INVENTORY_LOCATION}" = "x" ]; then 
    error_exit "INVENTORY_LOCATION not set."
fi

if [ "x${SELECTED_LANGUAGES}" = "x" ]; then 
    error_exit "SELECTED_LANGUAGES not set."
else
    check_lang $SELECTED_LANGUAGES
fi
# IF 'EN' IS NOT IN THE SELECTED LANGUAGE LIST, ADD IT THERE. 
if [ "x`echo $SELECTED_LANGUAGES | grep -w "en"`" = "x" ]; then 
    SELECTED_LANGUAGES+=",en" 
fi 

if [ "x${ORACLE_HOME}" = "x" ]; then 
    error_exit "ORACLE_HOME not set."
fi

if [ "x${ORACLE_BASE}" = "x" ]; then 
    error_exit "ORACLE_BASE not set."
fi

if [ "x${INSTALL_EDITION}" = "x" ]; then 
    error_exit "INSTALL_EDITION not set."
else
    check_install_edition $INSTALL_EDITION;
fi

if [ "x${EMAIL_ADDRESS}" = "x" ]; then 
    error_exit "EMAIL_ADDRESS not set."
else
    check_email $EMAIL_ADDRESS;
fi

if [ "x${LISTENER_PROTOCOL}" = "x" ]; then 
    error_exit "LISTENER_PROTOCOL not set."
else
    check_listener_protocol $LISTENER_PROTOCOL
fi

if [ "x${LISTENER_PORT}" = "x" ]; then 
    error_exit "LISTENER_PORT not set."
else
    if ! valid_int $LISTENER_PORT; then
    error_exit "Invalid parameter LISTENER_PORT"
    fi
fi

if [ "x${GDBNAME}" = "x" ]; then 
    error_exit "GDBNAME not set."
fi

if [ "x${SID}" = "x" ]; then 
    error_exit "SID not set."
fi

if [ "x${SYSTEMPASSWORD}" = "x" ]; then 
    error_exit "SYSTEMPASSWORD not set."
fi

if [ "x${SYSPASSWORD}" = "x" ]; then 
    error_exit "SYSPASSWORD not set."
fi

echo "PARAMTER VALIDATION -- DONE"


#Checking the OS version

KERNEL=`uname -r`
MACH=`uname -m`

SLEEP_PERIOD=30 
LOOP_ITERATION=5 
if [ -f /etc/redhat-release ]; then 
    basearch=`uname -p`
    DistroBasedOn='RedHat'
    DIST=`cat /etc/redhat-release |sed s/\ release.*//`
    if [ "$DIST" = "CentOS" ] ; then
        for (( i = 0 ; i < $LOOP_ITERATION ; i++ )) 
        do 
  	        yum --nogpgcheck --noplugins -y install binutils make compat-db gcc gcc-c++ libstdc++ lbXtst pdksh sysstat compat-libstdc++-33 glibc elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static numactl-devel unixODBC unixODBC-devel libaio libaio-devel nfs-utils unzip
			if [ $? -eq 0 ]
			then
                        echo "PACKAGES INSTALLED SUCCESSFULLY"
			      break
			fi
			if [ $i -eq 5 ]; then
				echo "UNABLE TO INSTALL REQUIRED PACKAGES..."
				exit 1
			fi
			sleep 10
		done
    else
		wget http://fr2.rpmfind.net/linux/centos/6.1/os/x86_64/RPM-GPG-KEY-CentOS-6
		rpm --import RPM-GPG-KEY-CentOS-6
		for (( i = 0 ; i < $LOOP_ITERATION ; i++ )) 
        do
			yum --nogpgcheck --noplugins -y install binutils compat-libstdc++-33 compat-libstdc++ elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc glibc-common glibc-devel glibc-devel libaio libaio-devel libgcc libgcc libstdc++ lbXtst libstdc++ libstdc++-devel make numactl-devel sysstat nfs-utils pdksh unixODBC unixODBC-devel unzip glibc.i686
			if [ $? -eq 0 ]
			then
				echo "PACKAGES INSTALLED SUCCESSFULLY"
				break
			fi
			if [ $i -eq 4 ]; then
				echo "UNABLE TO INSTALL REQUIRED PACKAGES..."
				exit 1
			fi
			sleep 10
		done	
    fi 
elif [ -f /etc/SuSE-release ] ; then
	DistroBasedOn='SuSe'
	echo $DistroBasedOn
   	zypper rr repo-oss
	zypper ar -f $ZYPPER_REPOSITORY repo-oss
	for (( i = 0 ; i < $LOOP_ITERATION ; i++ )) 
	do		
		zypper --non-interactive --no-gpg-checks ref
		zypper --non-interactive --no-gpg-checks install libgcc45 libstdc++45 glibc gcc gcc-c++ libstdc++-devel ksh pdksh sysstat libmudflap elfutils make libelf-devel unixODBC unixODBC-devel nfs-kernel-server unzip
		if [ $? -eq 0 ]
		then
                  echo "PACKAGES INSTALLED SUCCESSFULLY"
			break
		fi
		if [ $i -eq 5 ]; then
			echo "UNABLE TO INSTALL REQUIRED PACKAGES..."
			exit 1
		fi
		sleep 10
   done
elif [ -f /etc/debian_version ] ; then
	DistroBasedOn='Debian'
	echo $DistroBasedOn
	export DEBIAN_FRONTEND=noninteractive
	for (( i = 0 ; i < $LOOP_ITERATION ; i++ )) 
	do
		apt-get -f -y install
		apt-get update
		apt-get -y upgrade --fix-missing
		apt-get -f -y install
		apt-get -y install gcc autofs alien libaio1 unixodbc pdksh sysstat nfs-kernel-server libgcc1-dbg glibc-2* elfutils unzip --fix-missing        
		if [ $? -eq 0 ]
		then
			echo "PACKAGES INSTALLED SUCCESSFULLY"
			break
		fi
		if [ $i -eq 5 ]; then
			echo "UNABLE TO INSTALL REQUIRED PACKAGES..."
			exit 1
		fi
		sleep 10
	done
fi

#BASIC DIRECTORY STRUCTURE
mkdir -p $ORACLE_BASE
mkdir -p $ORACLE_HOME
mkdir -p $INVENTORY_LOCATION
mkdir -p $ORCALEINSTALLERLOCATION
check_error "ERRORS DURING CREATING BASIC DIRECOTRY STRUCTURE.";

if [ $DistroBasedOn = "RedHat" ] || [  $DistroBasedOn = "SuSe" ]; then
    echo "$DistroBasedOn"
    basesearch=`uname -p`
    echo "$basesearch"
    echo "INSIDE RHEL OR SUSE.............."
    if [ $basesearch == "x86_64" ] ; then
        #COPY ORACLE 11G INSTALLER(64-BIT)
        echo "STARTED COPYING...RHEL OR SUSE 64 "
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK1_64BIT 
        echo " PACKAGE-1 COPIED"
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK2_64BIT 
        echo " PACKAGE-2 COPIED"
        check_error "ERRORS DURING COPYING ORACLE INSTALLER.";
        echo "MOUNTING ORACLE INSTALLER -- DONE"
        #UNZIP
        echo "EXTRACTING ORACLE INSTALLER"
        unzip -q $ORCALEINSTALLERLOCATION/linux.x64_11gR2_database_1of2.zip -d $ORCALEINSTALLERLOCATION
        unzip -q $ORCALEINSTALLERLOCATION/linux.x64_11gR2_database_2of2.zip -d $ORCALEINSTALLERLOCATION
        check_error "ERRORS DURING EXTRACTING ORACLE INSTALLER.";
        echo "EXTRACTING ORACLE INSTALLER -- DONE"
    else
        # Copy Oracle 11g Installer(32-bit)
        echo "STARTED COPYING....RHEL OR SUSE 32 "
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK1_32BIT 
        echo " PACKAGE-1 COPIED"
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK2_32BIT 
        echo " PACKAGE-2 COPIED"
        check_error "ERRORS DURING COPYING ORACLE INSTALLER.";
        echo "MOUNTING ORACLE INSTALLER -- DONE"
        #UNZIP
        echo "EXTRACTING ORACLE INSTALLER"
        unzip -q $ORCALEINSTALLERLOCATION/linux_11gR2_database_1of2.zip -d $ORCALEINSTALLERLOCATION
        unzip -q $ORCALEINSTALLERLOCATION/linux_11gR2_database_2of2.zip -d $ORCALEINSTALLERLOCATION
        check_error "ERRORS DURING EXTRACTING ORACLE INSTALLER.";
        echo "EXTRACTING ORACLE INSTALLER -- DONE"
    fi
else
    echo "INSIDE UBUNTU.............."
    BaseSearch=`uname -m`
    echo "$BaseSearch" 
    if [ $BaseSearch == "x86_64" ] ; then
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK1_64BIT 
        echo " PACKAGE-1 COPIED"
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK2_64BIT
        echo " PACKAGE-2 COPIED"
        check_error "ERRORS DURING COPYING ORACLE INSTALLER.";
        echo "MOUNTING ORACLE INSTALLER -- DONE"
        #Unzip
        echo "EXTRACTING ORACLE INSTALLER"
        unzip -q $ORCALEINSTALLERLOCATION/linux.x64_11gR2_database_1of2.zip -d $ORCALEINSTALLERLOCATION
        unzip -q $ORCALEINSTALLERLOCATION/linux.x64_11gR2_database_2of2.zip -d $ORCALEINSTALLERLOCATION
        check_error "ERRORS DURING EXTRACTING ORACLE INSTALLER.";
        echo "EXTRACTING ORACLE INSTALLER -- DONE"
    else
        echo "STARTED COPYING....UBUNTU 32 "
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK1_32BIT
	  echo " PACKAGE-1 COPIED"
        cd $ORCALEINSTALLERLOCATION
        wget $URL_DISK2_32BIT
        echo " PACKAGE-2 COPIED"
       check_error "ERRORS DURING COPYING ORACLE INSTALLER.";
        echo "MOUNTING ORACLE INSTALLER -- DONE"
        #UNZIP
        echo $ORCALEINSTALLERLOCATION
        echo "EXTRACTING ORACLE INSTALLER"
        unzip -q $ORCALEINSTALLERLOCATION/linux_11gR2_database_1of2.zip -d $ORCALEINSTALLERLOCATION
        unzip -q $ORCALEINSTALLERLOCATION/linux_11gR2_database_2of2.zip -d $ORCALEINSTALLERLOCATION
        check_error "ERRORS DURING EXTRACTING ORACLE INSTALLER.";
        echo "EXTRACTING ORACLE INSTALLER -- DONE"
    fi
fi   

echo "MODIFYING THE RESPONSE FILES"
#jacp --backup --force -- $DBFILE $DBFILE_BACKUP
cp --backup --force -- $NETCAFILE $NETCAFILE_BACKUP
cp --backup --force -- $DBCAFILE $DBCAFILE_BACKUP

#CHANING THE PARAMETER IN db.rsp
sed -i "s~ORACLE_HOSTNAME=*~ORACLE_HOSTNAME=$ORACLE_HOSTNAME~g" $DBFILE
sed -i "s~INVENTORY_LOCATION=*~INVENTORY_LOCATION=$INVENTORY_LOCATION~g" $DBFILE
sed -i "s~SELECTED_LANGUAGES=*~SELECTED_LANGUAGES=$SELECTED_LANGUAGES~g" $DBFILE
sed -i "s~ORACLE_HOME=*~ORACLE_HOME=$ORACLE_HOME~g" $DBFILE
sed -i "s~ORACLE_BASE=*~ORACLE_BASE=$ORACLE_BASE~g" $DBFILE
sed -i "s~oracle.install.db.InstallEdition=*~oracle.install.db.InstallEdition=$INSTALL_EDITION~g" $DBFILE
sed -i "s~oracle.install.db.config.starterdb.dbcontrol.emailAddress=*~oracle.install.db.config.starterdb.dbcontrol.emailAddress=$EMAIL_ADDRESS~g" $DBFILE
sed -i "s~oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=.*~oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=true~g" $DBFILE
sed -i "s~oracle.install.option=*~oracle.install.option=INSTALL_DB_SWONLY~g" $DBFILE
sed -i "s~UNIX_GROUP_NAME=*~UNIX_GROUP_NAME=oinstall~g" $DBFILE
sed -i "s~oracle.install.db.DBA_GROUP=*~oracle.install.db.DBA_GROUP=dba~g" $DBFILE
sed -i "s~oracle.install.db.OPER_GROUP=*~oracle.install.db.OPER_GROUP=oinstall~g" $DBFILE
sed -i "s~oracle.install.db.config.starterdb.type=*~oracle.install.db.config.starterdb.type=GENERAL_PURPOSE~g" $DBFILE
sed -i "s~SECURITY_UPDATES_VIA_MYORACLESUPPORT=*~SECURITY_UPDATES_VIA_MYORACLESUPPORT=false~g" $DBFILE
sed -i "s~DECLINE_SECURITY_UPDATES=*~DECLINE_SECURITY_UPDATES=true~g" $DBFILE

#CHANING THE PARAMETER IN netca.rsp
LISTENERPROTOCOL="{\"$LISTENER_PROTOCOL;$LISTENER_PORT\"}"
sed -i "s~LISTENER_PROTOCOLS=*~#LISTENER_PROTOCOLS=~g" $NETCAFILE
echo "LISTENER_PROTOCOLS = $LISTENERPROTOCOL" >> $NETCAFILE

#CHANING THE PARAMETER IN dbca.rsp
sed -i "s~GDBNAME=*~#GDBNAME~g" $DBCAFILE
sed -i "s~SID=*~#SID~g" $DBCAFILE
sed -i "150iGDBNAME = $GDBNAME" $DBCAFILE
sed -i "150iSID = $SID" $DBCAFILE
sed -i "150iSYSTEMPASSWORD = $SYSTEMPASSWORD" $DBCAFILE
sed -i "150iSYSPASSWORD = $SYSPASSWORD" $DBCAFILE
echo "Modifying the response files -- DONE"

#SETUP USERS ANDS GROUPS
echo "Adding Oracle User"
/usr/sbin/groupadd oinstall
/usr/sbin/groupadd dba
/usr/sbin/useradd -m -g oinstall -G dba oracle
check_error "Errors during setting up user accounts.";
echo "ADDING ORACLE USER -- DONE"

echo "SETTING KERNEL PARAMETERS"
#SET KERNEL PARAMETERS
echo "kernel.shmmni=4096" >> $SYSCTLCONF
echo "kernel.sem=250 32000 100 128" >> $SYSCTLCONF
echo "fs.file-max=6815744" >> $SYSCTLCONF
echo "net.ipv4.ip_local_port_range=9000 65500" >> $SYSCTLCONF
echo "net.core.rmem_default=262144" >> $SYSCTLCONF
echo "net.core.wmem_default=262144" >> $SYSCTLCONF
echo "net.core.rmem_max=4194304" >> $SYSCTLCONF
echo "net.core.wmem_max=1048576" >> $SYSCTLCONF
echo "fs.aio-max-nr=1048576" >> $SYSCTLCONF

# UPLOAD CHANGED KERNEL PARAMETERS
/sbin/sysctl -p
echo "SETTING KERNEL PARAMETERS -- DONE"

#SETTING PERMISSION
chown -R oracle:oinstall $ORACLE_BASE
chown -R oracle:oinstall $ORACLE_HOME
chown -R oracle:oinstall $INVENTORY_LOCATION
chmod -R 775 $ORACLE_BASE
chmod -R 775 $ORACLE_HOME
chmod -R 775 $INVENTORY_LOCATION
check_error "ERRORS DURING SETTING PERMISSION ON BASIC DIRECOTRY STRUCTURE.";

#MODIFYING THE SHELL LIMIT
echo "MODIFYING THE SHELL LIMIT"
echo "oracle soft nproc 2047" >> /etc/security/limits.conf  
echo "oracle hard nproc 16384" >> /etc/security/limits.conf 
echo "oracle soft nofile 1024" >> /etc/security/limits.conf 
echo "oracle hard nofile 65536" >> /etc/security/limits.conf
echo "Modifying the shell limit -- DONE"

#MODIFYING PAM.D LOGIN
echo "session required pam_limits.so" >> /etc/pam.d/login

#MODIFY THE BASH PROFILE ORACLE USER
echo "ORACLE_HOSTNAME=$ORACLE_HOSTNAME" >> /home/oracle/.bash_profile
echo "ORACLE_UNQNAME=$SID" >> /home/oracle/.bash_profile
echo "ORACLE_BASE=$ORACLE_BASE" >> /home/oracle/.bash_profile
echo "ORACLE_HOME=$ORACLE_HOME" >> /home/oracle/.bash_profile
echo "ORACLE_SID=$SID" >> /home/oracle/.bash_profile
echo "PATH=/usr/sbin:$ORACLE_HOME/bin:$PATH" >> /home/oracle/.bash_profile
echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/lib64:$ORACLE_HOME/lib32" >> /home/oracle/.bash_profile
echo "export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib" >> /home/oracle/.bash_profile

# RUN INSTALLER
touch $ORACLEINSTALLSCRIPT
chmod 777 $ORACLEINSTALLSCRIPT
echo "#!/bin/bash" >> $ORACLEINSTALLSCRIPT
echo "cd $ORCALEINSTALLERLOCATION/database" >> $ORACLEINSTALLSCRIPT
echo "./runInstaller -silent -force -ignorePrereq -responseFile $DBFILE" >> $ORACLEINSTALLSCRIPT
echo "exit \"$?\"" >> $ORACLEINSTALLSCRIPT

touch $ORACLENETCACONFIGURATIONSCRIPT
chmod 777 $ORACLENETCACONFIGURATIONSCRIPT
echo "#!/bin/bash" >> $ORACLENETCACONFIGURATIONSCRIPT
echo "cd $ORACLE_HOME/bin/" >> $ORACLENETCACONFIGURATIONSCRIPT
echo "./netca -silent -responseFile $NETCAFILE" >> $ORACLENETCACONFIGURATIONSCRIPT
echo "exit \"$?\"" >> $ORACLENETCACONFIGURATIONSCRIPT

touch $ORACLEDBCACONFIGURATIONSCRIPT
chmod 777 $ORACLEDBCACONFIGURATIONSCRIPT
echo "#!/bin/bash" >> $ORACLEDBCACONFIGURATIONSCRIPT
echo "cd $ORACLE_HOME/bin/" >> $ORACLEDBCACONFIGURATIONSCRIPT
echo "./dbca -silent -responseFile $DBCAFILE" >> $ORACLEDBCACONFIGURATIONSCRIPT
echo "exit \"$?\"" >> $ORACLEDBCACONFIGURATIONSCRIPT

#SWITCH ORACLE USER
echo "STARTING ORACLE INSTALLER"
#xhost +
su - oracle -c $ORACLEINSTALLSCRIPT
check_error "UNSUCCESSFULL DATABASE INSTALLATION";
echo "" 
echo_d "WAIT 3 MINUTES ..."  
sleep 180 
# TRY 120 TIMES TO START POST-INSTALL SCRIPTS, WHICH MEANS THE SCRIPT WILL WAIT FOR ABOUT 1HR AT MOST 
#UNTIL THE INSTALLATION FINISHES (EACH LOOP WILL WAIT FOR 30 SECONDS FOR THE INSTALLATION TO FINISH.) 
SLEEP_PERIOD=30 
LOOP_ITERATION=120 
for (( i = 0 ; i < $LOOP_ITERATION ; i++ )) 
do 
    grep -q "Shutdown Oracle Database 11g Release 2 Installer" $INVENTORY_LOCATION/logs/installActions*.log
if [ $? -eq 0 ]
    then
    grep -q "Exit Status is 0" $INVENTORY_LOCATION/logs/installActions*.log
    if [ $? -eq 0 ]
        then
        echo "ORACLE SUCCESSFULLY INSTALLED"
        $ORACLE_HOME/root.sh
        echo "CONFIGURING ORACLE"  
		echo "start netca configuration"
        TERM=OFF
        setterm: $TERM
        /bin/su - oracle -c "export DISPLAY=:0; $ORACLENETCACONFIGURATIONSCRIPT"
        check_error "UNSUCCESSFULL NETCA CONFIGURATION";
		echo "start netca configuration"
        /bin/su - oracle -c $ORACLEDBCACONFIGURATIONSCRIPT
        check_error "UNSUCCESSFULL DBCA CONFIGURATION";
        echo "CONFIGURING ORACLE -- DONE"  
        break
    else
        echo "ORACLE NOT SUCCESSFULLY INSTALLED"
        break       
    fi
else
    sleep 30
fi
done

cd $ORACLE_HOME/bin

#--- Check for the listener and that we have our service registered
SLEEP_PERIOD=30
LOOP_ITERATION=10
CMDOUT=''
STARTED=0

rm $ORACLEINSTALLSCRIPT
rm $ORACLENETCACONFIGURATIONSCRIPT
rm $ORACLEDBCACONFIGURATIONSCRIPT