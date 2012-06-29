#!/bin/bash

# IMPORT GLOBAL CONF 
. $global_conf

export http_proxy=http://proxy.vmware.com:3128

export PATH=$PATH:/usr/local/sbin/
export PATH=$PATH:/usr/sbin/
export PATH=$PATH:/sbin

#########CUSTOMIZED PARAMETERS#########
INSTALL_BASE="$install_base"
INSTALL_EDITION_ARRAY=(BASE BASETRIAL EXPRESS EXPRESSTRIAL DEVELOPERS NETWORKDEPLOYMENT)

#########PARAMTERS FROM APP DIRECTOR#########
IM_DOWNLOAD_URL="$im_download_url"
REPOSITORY_URL="$repository_url"
INSTALL_EDITION="$install_edition"
IBM_USERNAME="$ibm_username"
IBM_PASSWORD="$ibm_password"
PROFILE_NAME="$profile_name"
NODE_NAME="$node_name"
SERVER_NAME="$server_name"
ADMIN_USERNAME="$admin_username"
ADMIN_PASSWORD="$admin_password"
PROXY_HOST="$proxy_host"
PROXY_PORT="$proxy_port"
PROXY_USERNAME="$proxy_username"
PROXY_PASSWORD="$proxy_password"

#########SCRIPT INTERNAL PARAMETERS#########
INSTALL_LOCATION="$INSTALL_BASE/WebSphere/AppServer"
SHARED_REPOSITORY="$INSTALL_BASE/IMShared"
WSINSTALLERLOCATION="$INSTALL_BASE/wsinstaller"
INSTALLATIONLOG="$INSTALL_BASE/installationlogs"
KEYRINGLOCATION="$INSTALL_BASE/keyring.txt"
RESPONSE_XML="$INSTALL_BASE/install_was_response.xml"
OFFERING_ID="";

###########PARAMTER VALIDATION FUNCTIONS##################
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

function check_install_edition()
{
   len=${#INSTALL_EDITION_ARRAY[*]}
   local temp=$1;
   for (( i=0; $i < $len; i++ )) do
       if [ "${INSTALL_EDITION_ARRAY[$i]}" = "$temp" ]; then
          return;
       fi
   done
   error_exit "INVALID EDITION"
}

####################SCRIPT EXECUTION ##################
echo "PARAMTER VALIDATION"

if [ "x${PROFILE_NAME}" = "x" ]; then
    error_exit "PROFILE_NAME NOT SET."
fi

if [ "x${INSTALL_BASE}" = "x" ]; then
    error_exit "INSTALL_BASE NOT SET."
fi

if [ "x${NODE_NAME}" = "x" ]; then
    error_exit "NODE_NAME NOT SET."
fi

if [ "x${SERVER_NAME}" = "x" ]; then
    error_exit "SERVER_NAME NOT SET."
fi

if [ "x${ADMIN_USERNAME}" = "x" ]; then
    error_exit "ADMIN_USERNAME NOT SET."
fi

if [ "x${ADMIN_PASSWORD}" = "x" ]; then
    error_exit "ADMIN_PASSWORD NOT SET."
fi

if [ "x${INSTALL_EDITION}" = "x" ]; then
    error_exit "INSTALL_EDITION NOT SET."
else
    check_install_edition $INSTALL_EDITION;
fi

if [ "x${PROXY_USERNAME}" != "x" && "x${PROXY_PASSWORD}" = "x" ]; then
    error_exit "PROXY_PASSWORD NOT SET."
fi

if [ "x${REPOSITORY_URL}" = "x" ]; then
    if [ $INSTALL_EDITION = "BASE" ]; then
        REPOSITORY_URL="http://www.ibm.com/software/repositorymanager/com.ibm.websphere.BASE.v80 "
    elif [ $INSTALL_EDITION = "BASETRIAL" ]; then
        REPOSITORY_URL="http://www.ibm.com/software/repositorymanager/V8WASBASETrial"
    elif [ $INSTALL_EDITION = "EXPRESS" ]; then
        REPOSITORY_URL="http://www.ibm.com/software/repositorymanager/com.ibm.websphere.EXPRESS.v80"
    elif [ $INSTALL_EDITION = "EXPRESSTRIAL" ]; then
        REPOSITORY_URL="http://www.ibm.com/software/repositorymanager/V8WASEXPRESSTrial"
    elif [ $INSTALL_EDITION = "DEVELOPERS" ]; then
        REPOSITORY_URL="http://www.ibm.com/software/repositorymanager/com.ibm.websphere.DEVELOPERS.v80"
    elif [ $INSTALL_EDITION = "NETWORKDEPLOYMENT" ]; then
        REPOSITORY_URL="http://www.ibm.com/software/repositorymanager/com.ibm.websphere.NDTRIAL.v80"
    fi
fi

if [ $INSTALL_EDITION = "BASE" ]; then
     OFFERING_ID="com.ibm.websphere.BASE.v80"
elif [ $INSTALL_EDITION = "BASETRIAL" ]; then
     OFFERING_ID="com.ibm.websphere.BASETRIAL.v80"
elif [ $INSTALL_EDITION = "EXPRESS" ]; then
     OFFERING_ID="com.ibm.websphere.EXPRESS.v80"
elif [ $INSTALL_EDITION = "EXPRESSTRIAL" ]; then
     OFFERING_ID="com.ibm.websphere.EXPRESSTRIAL.v80"
elif [ $INSTALL_EDITION = "DEVELOPERS" ]; then
     OFFERING_ID="com.ibm.websphere.DEVELOPERS.v80"
elif [ $INSTALL_EDITION = "NETWORKDEPLOYMENT" ]; then
     OFFERING_ID="com.ibm.websphere.NDTRIAL.v80"
fi

mkdir -p $WSINSTALLERLOCATION
touch $INSTALLATIONLOG

echo "DOWNLOADING INSTALLATION MANAGER INSTALLER"
wget --output-document=$WSINSTALLERLOCATION/IBMIM_linux_x86.zip $IM_DOWNLOAD_URL
check_error "ERRORS DURING MOUNTING INSTALLATION MANAGER INSTALLER.";

#START CHECKING OS TYPE

KERNEL=`uname -r`
MACH=`uname -m`

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
            echo "32 BIT MACHINE"	
            yum -y update
            yum --nogpgcheck --noplugins -y install PackageKit-gtk-module.i686 libcanberra-gtk2.i686			
       else
            echo "64 BIT MACHINE"
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
    # INSTALL UNZIP PACKAGE 
    TYPE_MATCH=`uname -m`
    if  [ $TYPE_MATCH == "i686" ] ; then
        echo "32 BIT MACHINE"
        wget http://us.archive.ubuntu.com/ubuntu/pool/main/u/unzip/unzip_6.0-4_i386.deb
        sudo dpkg -i unzip_6.0-4_i386.deb
    else
        echo "64 BIT MACHINE"
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
check_error "ERRORS DURING GENERATING RESPONSE XML.";

cd /opt/IBM/InstallationManager/eclipse/tools
KEY_COMMAND_OPTS="-userName $IBM_USERNAME -userPassword $IBM_PASSWORD -passportAdvantage -keyring $KEYRINGLOCATION"

if [ "x${PROXY_HOST}" != "x" ]; then
    KEY_COMMAND_OPTS+=" -proxyHost $PROXY_HOST -proxyPort $PROXY_PORT"
    if [ "x${PROXY_USERNAME}" != "x" ]; then
        KEY_COMMAND_OPTS+=" -proxyUsername $PROXY_USERNAME -proxyUserPassword $PROXY_PASSWORD"
    fi
fi

#GENERATING KEY RING
echo "GENERATING KEY RING"
./imutilsc saveCredential $KEY_COMMAND_OPTS
check_error "ERRORS DURING GENERATING KEY RING.";

# INSTALLING WEBSPEHERE APPLICATION SERVER
echo "INSTALLING WEBSPHERE APPLICATION SERVER"
check_error "ERRORS DURING INSTALLING APPLICATION SERVER.";
./imcl -acceptLicense -input $RESPONSE_XML -log $INSTALLATIONLOG -keyring $KEYRINGLOCATION