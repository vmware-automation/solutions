#!/bin/bash

# Import global conf 
. $global_conf

export http_proxy=http://proxy.vmware.com:3128
export PATH=$PATH:/usr/local/sbin/
export PATH=$PATH:/usr/sbin/
export PATH=$PATH:/sbin

#########CUSTOMIZED PARAMETERS############
INSTALL_BASE="$install_base"
IM_DOWNLOAD_URL="$im_download_url"
REPOSITORY_URL="$repository_url"
IBM_USERNAME="$ibm_username"
IBM_PASSWORD="$ibm_password"
PROFILE_NAME="$profile_name"
NODE_NAME="$node_name"
SERVER_NAME="$server_name"
CELL_NAME="$cell_name"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"
PROXY_HOST="$proxy_host"
PROXY_PORT="$proxy_port"
PROXY_USERNAME="$proxy_username"
PROXY_PASSWORD="$proxy_password"
CLUSTER_NUM="$cluster_number"
STANDALONE_SERVERS_NUM="$standalone_servers_number"

#########SCRIPT INTERNAL PARAMETERS#########
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
SHARED_REPOSITORY="$INSTALL_BASE/IMShared"
WSINSTALLERLOCATION="$INSTALL_BASE/wsinstaller"
INSTALLATIONLOG="$INSTALL_BASE/installationlogs"
KEYRINGLOCATION="$INSTALL_BASE/keyring.txt"
RESPONSE_XML="$INSTALL_BASE/install_was_response.xml"
OFFERING_ID="";

###########INTERNAL FUNCTIONS################
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

function valid_int()
{
   local  data=$1
   if [[ $data =~ ^[0-9]{1,9}$ ]]; then
      return 0;
   else
      return 1
   fi
}

# FUNCTION TO VALIDATE IP ADDRESS
function valid_ip()
{
    local  ip=$1
    local  stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}
# FUNCTION TO VALIDATE NAME STRING
function valid_string()
{
    local  data=$1
    if [[ $data =~ ^[A-Za-z]{1,}[A-Za-z0-9_-]{1,}$ ]]; then
       return 0;
    else
       return 1;
    fi
}

# FUNCTION TO VALIDATE PASSWORD
function valid_password()
{
    local  data=$1
    length=${#data}
    if [ $length -le 6 ]; then
        check_error "PASSWORD MUST BE OF AT LEAST 6 CHARACTERS"
    else
        if [[ $data =~ ^[A-Za-z]{1,}[0-9_@$%^+=]{0,}[A-Za-z0-9]{0,}$ ]]; then
           return 0;
        else
           return 1;
        fi
    fi
}

# FUNCTION TO COUNT ARRAY LENGTH
function array_length()
{
	para=("${!1}")
	length=0
	for index in ${para[@]}
	do
		length=`expr $length + 1`
	done
	return $length
}

# FUNCTION TO APPEND HOSTNAME INTO /etc/hosts FILE
function append_cluster_hostname()
{
	tmp_ip=cluster_`expr $CLUSTER_INDEX`_ip[$NODE_INDEX-1]
	ip=${!tmp_ip}
	tmp_hostname=cluster_`expr $CLUSTER_INDEX`_hostname[$NODE_INDEX-1]
	hostname=${!tmp_hostname}
	echo "$ip    $hostname.eng.vmware.com     $hostname " >>/etc/hosts	
}

function append_standalone_hostname()
{
	tmp_ip=standalone_`expr $NODE_INDEX`_ip
	ip=${!tmp_ip}
	tmp_hostname=standalone_`expr $NODE_INDEX`_hostname
	hostname=${!tmp_hostname}
	echo "$ip    $hostname.eng.vmware.com     $hostname " >>/etc/hosts	
}

####################SCRIPT EXECUTION ##################
# PARAMETER VALIDATION -- START
echo "PARAMTER VALIDATION..."

if [ "x${INSTALL_BASE}" = "x" ]; then
    error_exit "INSTALL_BASE not set."
fi

if [ "x${IM_DOWNLOAD_URL}" = "x" ]; then
    error_exit "IM_DOWNLOAD_URL not set."
fi

if [ "x${PROFILE_NAME}" = "x" ]; then
    error_exit "PROFILE_NAME not set."
else
   if ! valid_string ${PROFILE_NAME}; then
      error_exit "INVALID PARAMETER PROFILE_NAME"
   fi
fi

if [ "x${NODE_NAME}" = "x" ]; then
    error_exit "NODE_NAME not set."
else
   if ! valid_string ${NODE_NAME} ; then
      error_exit "INVALID PARAMETER NODE_NAME"
   fi
fi

if [ "x${SERVER_NAME}" = "x" ]; then
    error_exit "SERVER_NAME not set."
else
   if ! valid_string ${SERVER_NAME}; then
      error_exit "INVALID PARAMETER SERVER_NAME"
   fi
fi

if [ "x${CELL_NAME}" = "x" ]; then
    error_exit "CELL_NAME not set."
else
   if ! valid_string ${CELL_NAME}; then
      error_exit "INVALID PARAMETER CELL_NAME"
   fi
fi

if [ "x${ADMIN_USERNAME}" = "x" ]; then
    error_exit "ADMIN_USERNAME not set."
else
   if ! valid_string ${ADMIN_USERNAME}; then
      error_exit "INVALID PARAMETER ADMIN_USERNAME"
   fi
fi

if [ "x${ADMIN_PASSWORD}" = "x" ]; then
    error_exit "ADMIN_PASSWORD not set."
else
	if ! valid_password ${ADMIN_PASSWORD}; then
		error_exit "INVALID ADMIN_PASSWORD"
	fi
fi

if [ "x${IBM_USERNAME}" = "x" ]; then
    error_exit "IBM_USERNAME not set."
fi

if [ "x${IBM_PASSWORD}" = "x" ]; then
    error_exit "IBM_PASSWORD not set."
else
	if ! valid_password ${IBM_PASSWORD}; then
		error_exit "INVALID IBM_PASSWORD"
	fi
fi

if [ "x${PROXY_PORT}" = "x" ]; then
    error_exit "PROXY_PORT NOT SET."
else
	if ! valid_int ${PROXY_PORT}; then
		error_exit "INVALID PARAMETER PROXY_PORT.MUST BE AN INTEGER."
	fi
fi

if [ "x${PROXY_USERNAME}" != "x" ] && [ "x${PROXY_PASSWORD}" = "x" ]; then
    error_exit "PROXY_PASSWORD not set."
fi

if [ "x${CLUSTER_NUM}" = "x" ]; then
    error_exit "CLUSTER_NUMMBER not set."
else
	if ! valid_int ${CLUSTER_NUM}; then
		error_exit "INVALID PARAMETER CLUSTER_NUM. CLUSTER NUMBER MUST BE AN INTEGER."
	fi
	
	CLUSTER_INDEX=1
	while [ $CLUSTER_INDEX -le $CLUSTER_NUM ]
	do
		array_length cluster_"$CLUSTER_INDEX"_ip[@] ;
		len=$?
		if ! valid_int ${len}; then
			error_exit "INVALID CLUSTER INDEX.INDEX MUST BE OF INTEGER TYPE"
		fi
		
		NODE_INDEX=1
		while [ $NODE_INDEX -le $len ]
		do
			tmp_ip=cluster_`expr $CLUSTER_INDEX`_ip[$NODE_INDEX-1]
			tmp_hostname=cluster_`expr $CLUSTER_INDEX`_hostname[$NODE_INDEX-1]
			if ! valid_ip ${!tmp_ip}; then
				error_exit "INVALID CLUSTER IP AT INDEX `expr $NODE_INDEX - 1`."
			fi
			if ! valid_string ${!tmp_hostname}; then
				error_exit "INVALID CLUSTER HOSTNAME AT INDEX `expr $NODE_INDEX - 1`."
			fi
			NODE_INDEX=`expr $NODE_INDEX + 1`
		done
		CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
	done 
fi

if [ "x${STANDALONE_SERVERS_NUM}" = "x" ]; then
    error_exit "STANDALONE_SERVERS_NUMBER not set."
else
	if ! valid_int ${STANDALONE_SERVERS_NUM}; then
		error_exit "INVALID PARAMETER STANDALONE_SERVERS_NUM.MUST BE AN INTEGER."
	fi
	
	NODE_INDEX=1
	while [ $NODE_INDEX -le $STANDALONE_SERVERS_NUM ]
	do
		tmp_ip=standalone_`expr $NODE_INDEX`_ip
		tmp_hostname=standalone_`expr $NODE_INDEX`_hostname
		if ! valid_ip ${!tmp_ip}; then
			error_exit "INVALID STANDALONE SERVER IP AT INDEX `expr $NODE_INDEX - 1`."
		fi
		if ! valid_string ${!tmp_hostname}; then
			error_exit "INVALID STANDALONE SERVER HOSTNAME AT INDEX `expr $NODE_INDEX - 1`."
		fi
		NODE_INDEX=`expr $NODE_INDEX + 1`
	done
fi
echo "PARAMTER VALIDATION -- DONE"
# PARAMETER VALIDATION -- END

if [ "x${REPOSITORY_URL}" = "x" ]; then
     REPOSITORY_URL="http://www.ibm.com/software/repositorymanager/com.ibm.websphere.NDTRIAL.v80"
fi
OFFERING_ID="com.ibm.websphere.NDTRIAL.v80"

mkdir -p $WSINSTALLERLOCATION
touch $INSTALLATIONLOG

# GETTING THE DMGR HOSTNAME
dmgr_hostname=`hostname`
# APPENDING THE HOSTNAME OF THE NODE MANAGER MACHINES -- START
echo "APPENDING THE HOSTNAME OF THE NODE MANAGER MACHINES..."
CLUSTER_INDEX=1
while [ $CLUSTER_INDEX -le $CLUSTER_NUM ]
do
	array_length cluster_"$CLUSTER_INDEX"_hostname[@] ;
	len=$?
	NODE_INDEX=1
	while [ $NODE_INDEX -le $len ]
	do
		append_cluster_hostname $NODE_INDEX $CLUSTER_INDEX
		NODE_INDEX=`expr $NODE_INDEX + 1`
	done
	CLUSTER_INDEX=`expr $CLUSTER_INDEX + 1`
done

NODE_INDEX=1
while [ $NODE_INDEX -le $STANDALONE_SERVERS_NUM ]
do
	append_standalone_hostname $NODE_INDEX
	NODE_INDEX=`expr $NODE_INDEX + 1`
done
# APPENDING THE HOSTNAME OF THE NODE MANAGER MACHINES -- END

echo "DOWNLOADING INSTALLATION MANAGER INSTALLER"
wget --output-document=$WSINSTALLERLOCATION/IBMIM_linux_x86.zip $IM_DOWNLOAD_URL
check_error "ERRORS DURING MOUNTING INSTALLATION MANAGER INSTALLER.";

# Start checking OS type
if [ -f /etc/redhat-release ] ; then
    BASEARCH=`uname -p`
    DISTROBASEDON='RedHat'
    DIST=`cat /etc/redhat-release |sed s/\ release.*//`
    if [ "$DIST" = "CentOS" ] ; then
		echo "CentOS..............."
		yum --nogpgcheck --noplugins -y install unzip
		yum --nogpgcheck --noplugins -y install libgcc_s.so.1 libstdc++.so.6
    else      
		if [ "$BASEARCH" = "i686" ] ; then
            echo "32 bit machine"	
            yum -y update
            yum --nogpgcheck --noplugins -y install PackageKit-gtk-module.i686 libcanberra-gtk2.i686			
        else
			echo "64 bit machine"
			wget http://fr2.rpmfind.net/linux/centos/6.1/os/x86_64/RPM-GPG-KEY-CentOS-6
			rpm --import RPM-GPG-KEY-CentOS-6
			yum -y update
			yum --nogpgcheck --noplugins -y install PackageKit-gtk-module.i686 PackageKit-gtk-module.x86_64 libcanberra-gtk2.x86_64 libcanberra-gtk2.i686
         fi	
         yum --nogpgcheck --noplugins -y install unzip
    fi
echo "UPDATING PRE-REQUISTE PACKAGES -- DONE"

elif [ -f /etc/SuSE-release ] ; then
    echo $DISTROBASEDON
    zypper rr repo-oss
    zypper ar -f http://download.opensuse.org/distribution/11.2/repo/oss/ repo-oss
    zypper --non-interactive --no-gpg-checks ref
    zypper --non-interactive --no-gpg-checks install unzip
    zypper --non-interactive --no-gpg-checks install libgcc_s.so.1 libstdc++.so.6 

else 
    apt-get -f -y upgrade
    apt-get -y update 
    apt-get install -y linux-firmware < /dev/console > /dev/console
    apt-get -f -y install ia32-libs
    apt-get -f -y install 
    # Install Unzip package 
    TYPE_MATCH=`uname -m`
    if  [ $TYPE_MATCH == "i686" ] ; then
        echo "32 bit machine"
        wget http://us.archive.ubuntu.com/ubuntu/pool/main/u/unzip/unzip_6.0-4_i386.deb
        sudo dpkg -i unzip_6.0-4_i386.deb
    else
		echo "64 bit machine"
		wget http://us.archive.ubuntu.com/ubuntu/pool/main/u/unzip/unzip_6.0-4ubuntu1_amd64.deb
		sudo dpkg -i unzip_6.0-4ubuntu1_amd64.deb
    fi
fi

# UNZIP
echo "EXTRACTING INSTALLATION MANAGER INSTALLER"
unzip -q $WSINSTALLERLOCATION/IBMIM_linux_x86.zip -d $WSINSTALLERLOCATION
check_error "ERRORS DURING EXTRACTING INSTALLATION MANAGER INSTALLER.";
echo "EXTRACTING INSTALLATION MANAGER INSTALLER -- DONE"

# INSTALLING IBM INSTALL MANAGER
echo "INSTALLING IBM INSTALL MANAGER"
cd $WSINSTALLERLOCATION
./installc -acceptLicense
check_error "ERRORS DURING INSTALLATION MANAGER INSTALLATION.";

echo "MODIFYING THE RESPONSE FILE"
# CREATE THE RESPONSE FILE HERE
touch $RESPONSE_XML
chmod 777 $RESPONSE_XML
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> $RESPONSE_XML
echo "<agent-input acceptLicense='true'>" >> $RESPONSE_XML
echo "<server>" >> $RESPONSE_XML
echo "<repository location='$REPOSITORY_URL'/>" >> $RESPONSE_XML
echo "</server>" >> $RESPONSE_XML
echo "<profile id='IBM WebSphere Application Server - Express Trial V8.0' installLocation='$INSTALL_LOCATION'>" >> $RESPONSE_XML
echo "<data key='eclipseLocation' value='$INSTALL_LOCATION'/>" >> $RESPONSE_XML
echo "<data key='user.import.profile' value='false'/>" >> $RESPONSE_XML
echo "<data key='cic.selector.os' value='linux'/>" >> $RESPONSE_XML
echo "<data key='cic.selector.ws' value='gtk'/>" >> $RESPONSE_XML
echo "<data key='cic.selector.arch' value='x86'/>" >> $RESPONSE_XML
echo "<data key='cic.selector.nl' value='en'/>" >> $RESPONSE_XML
echo "</profile>" >> $RESPONSE_XML
echo "<install modify='false'>" >> $RESPONSE_XML
echo "<offering id='$OFFERING_ID' profile='IBM WebSphere Application Server - Express Trial V8.0' installFixes='none'/>" >> $RESPONSE_XML
echo "</install>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.eclipseCache' value='$SHARED_REPOSITORY'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.connectTimeout' value='30'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.readTimeout' value='45'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.downloadAutoRetryCount' value='0'/>" >> $RESPONSE_XML
echo "<preference name='offering.service.repositories.areUsed' value='true'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.ssl.nonsecureMode' value='false'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.http.disablePreemptiveAuthentication' value='false'/>" >> $RESPONSE_XML
echo "<preference name='http.ntlm.auth.kind' value='NTLM'/>" >> $RESPONSE_XML
echo "<preference name='http.ntlm.auth.enableIntegrated.win32' value='true'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts' value='true'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.keepFetchedFiles' value='false'/>" >> $RESPONSE_XML
echo "<preference name='PassportAdvantageIsEnabled' value='false'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.searchForUpdates' value='false'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.agent.ui.displayInternalVersion' value='false'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.sharedUI.showErrorLog' value='true'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.sharedUI.showWarningLog' value='true'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.sharedUI.showNoteLog' value='true'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.http.proxyEnabled' value='true'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.http.proxyHost' value='$PROXY_HOST'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.http.proxyPort' value='$PROXY_PORT'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.http.proxyUsername' value='$PROXY_USERNAME'/>" >> $RESPONSE_XML
echo "<preference name='com.ibm.cic.common.core.preferences.http.proxyUserPassword' value='$PROXY_PASSWORD'/>" >> $RESPONSE_XML

echo "</agent-input>" >> $RESPONSE_XML
check_error "Errors during generating response xml.";

cd /opt/IBM/InstallationManager/eclipse/tools
KEY_COMMAND_OPTS="-userName $IBM_USERNAME -userPassword $IBM_PASSWORD -passportAdvantage -keyring $KEYRINGLOCATION"

if [ "x${PROXY_HOST}" != "x" ]; then
    KEY_COMMAND_OPTS+=" -proxyHost $PROXY_HOST -proxyPort $PROXY_PORT"
    if [ "x${PROXY_USERNAME}" != "x" ]; then
        KEY_COMMAND_OPTS+=" -proxyUsername $PROXY_USERNAME -proxyUserPassword $PROXY_PASSWORD"
    fi
fi

# GENERATING KEY RING
echo "GENERATING KEY RING..."
./imutilsc saveCredential $KEY_COMMAND_OPTS
check_error "Errors during generating key ring.";

# INSTALLING WEBSPEHERE APPLICATION SERVER
echo "INSTALLING WEBSPHERE APPLICATION SERVER..."
./imcl -acceptLicense -input $RESPONSE_XML -log $INSTALLATIONLOG -keyring $KEYRINGLOCATION
check_error "ERRORS DURING INSTALLING WEBSPHERE APPLICATION SERVER.";
echo "WEBSPHERE APPLICATION SERVER INSTALLED SUCCESSFULLY";