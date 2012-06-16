#!/bin/bash
 
# Import global conf
. $global_conf
 
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vmware/bin:/opt/vmware/bin
export JAVA_HOME=/usr/java/jre-vmware
export PATH=$JAVA_HOME/bin:$PATH
 
if [ -x /usr/sbin/selinuxenabled ] && /usr/sbin/selinuxenabled; then
    if [ -x /usr/sbin/setenforce ]; then
        /usr/sbin/setenforce Permissive
    else
        echo 'SELinux is enabled.This may cause installation to fail.'
    fi
fi
 
#########SCRIPT INTERNAL PARAMETERS########################
BEA_HOME="$webLogic_home"
WLS_INSTALL_DIR="$BEA_HOME/WebLogic"
WLSINSTALLERLOCATION="$WLS_INSTALL_DIR/INSTALLER"
WLSINSTALLSCRIPT="$WLSINSTALLERLOCATION/wls_install.sh"
SILENT_XML="$WLSINSTALLERLOCATION/silent.xml"
NFS_PATH="$nfs_path"
# This is the relative path to the current task location
MOUNTPOINTLOCATION="tmp/mount"
GROUP_NAME="$group_name"
USER_NAME="$user_name"
 
 
## Function To Display Error and Exit
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
 
####################SCRIPT EXECUTION ##################
echo "Paramter Validation"
if [ "x${BEA_HOME}" = "x" ]; then
    check_error "WebLogic Home not set."
fi
if [ "x${GROUP_NAME}" = "x" ]; then
    check_error "Group Name not set."
fi
if [ "x${USER_NAME}" = "x" ]; then
    check_error "WebLogic user name not set."
fi
if [ "x${NFS_PATH}" = "x" ]; then
    check_error "NFS_PATH not set."
fi
echo "Paramter Validation -- DONE"
 
#### ADDING THE DEDICATED GROUP AND WEBLOGIC USER
echo "Adding WebLogic User"
groupadd $GROUP_NAME
useradd -g $GROUP_NAME -d $BEA_HOME $USER_NAME
check_error "Errors during setting up WebLogic user accounts.";
echo "Adding WebLogic User -- DONE"
 
#Basic Directory Structure
mkdir -p $WLSINSTALLERLOCATION
mkdir -p $MOUNTPOINTLOCATION
check_error "Errors during creating basic direcotry structure.";
 
echo "Mounting WebLogic Installer..."
if [ -f /etc/redhat-release ] ; then
    DIST=`cat /etc/redhat-release |sed s/\ release.*//`
    if [ "$DIST" = "CentOS" ] ; then
        yum -y install nfs-utils
        /sbin/service portmap start
        check_error "Error: Portmap Not started"
    else
        yum update -y
        yum -y install nfs-utils ld-linux.so.2
        /sbin/service rpcbind start
        check_error "Error: Portmap Not started"
    fi
elif [ -f /etc/debian_version ] ; then
    DistroBasedOn='Debian'
    apt-get update -y
    apt-get -f -y install
    apt-get -y install nfs-common
    service portmap restart
    check_error "Error: Portmap Not started"
else
    /sbin/service rpcbind start
    check_error "Error: Portmap Not started"
fi
echo "rpcbind call done... "
 
mount $NFS_PATH $MOUNTPOINTLOCATION
check_error "Errors during mounting WebLogic installer.";
 
# Copy WebLogic 12c Installer
cp $MOUNTPOINTLOCATION/webLogicInstaller.bin $WLSINSTALLERLOCATION
check_error "Errors during copying WebLogic installer";
echo "Mounting WebLogic 12c Installer -- DONE"
 
chown -R $USER_NAME:$GROUP_NAME $INSTALL_BASE
chown -R $USER_NAME:$GROUP_NAME $BEA_HOME
chown -R $USER_NAME:$GROUP_NAME $WLS_INSTALL_DIR
chown -R $USER_NAME:$GROUP_NAME $WLSINSTALLERLOCATION
chmod -R 775 $INSTALL_BASE
chmod -R 775 $BEA_HOME
chmod -R 775 $WLS_INSTALL_DIR
chmod -R 775 $WLSINSTALLERLOCATION
 
# CREATING SILENT XML FILE
echo "Creating  Silent.xml installation file for WebLogic"
cat <<EOF> $SILENT_XML
<?xml version="1.0" encoding="UTF-8"?>
 
<bea-installer>
  <input-fields>
    <data-value name="BEAHOME"                     value="$BEA_HOME" />
    <data-value name="WLS_INSTALL_DIR"             value="$WLS_INSTALL_DIR"/>
    <data-value name="COMPONENT_PATHS"             value="WebLogic Server|Oracle Enterprise Pack for Eclipse|Oracle Coherence/Coherence Product Files|Oracle Coherence/Coherence Examples"/>
    <data-value name="USE_EXTERNAL_ECLIPSE"        value="false"/>
    <data-value name="EXTERNAL_ECLIPSE_DIR"        value="$WLS_INSTALL_DIR/eclipse/eclipse32" />
  </input-fields>
</bea-installer>
EOF
check_error "Error while creating Silent.xml file"
echo "Silent.xml file created Successfully"
chmod -R 775 $SILENT_XML
 
cat << EOF > $WLSINSTALLSCRIPT
#!/bin/bash
cd $WLSINSTALLERLOCATION
./webLogicInstaller.bin -mode=silent -silent_xml=$SILENT_XML
EOF
check_error "Error while creating installation file"
 
chmod -R 775 $WLSINSTALLSCRIPT
echo "Installing WebLogic Server"
su - $USER_NAME -c $WLSINSTALLSCRIPT
check_error "Errors during installing WebLogic installer.";
 
# clean up
umount $MOUNTPOINTLOCATION
check_error "Errors during umounting $MOUNTPOINTLOCATION.";
 
echo "Installed Successfully"

