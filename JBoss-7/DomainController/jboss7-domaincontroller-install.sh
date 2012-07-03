#!/bin/bash
set -e

. $global_conf

try yum -y install java-1.6.0-openjdk-devel unzip curl

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd /tmp
try mv $zip_url .
filename=`basename $zip_url`
JBOSS_ZIP_PATH=/tmp/$filename

HOME_DIR=/home/jboss
JBOSS_USER=${JBOSS_USER:-"jboss"}

echo "Creating user $JBOSS_USER"
try groupadd $JBOSS_USER
try useradd -g $JBOSS_USER -d $HOME_DIR $JBOSS_USER

cd $HOME_DIR
echo "Installing $JBOSS_ZIP_PATH"
try su $JBOSS_USER -c \"unzip $JBOSS_ZIP_PATH\"

JBOSS_HOME=$HOME_DIR/$JBOSS_NAME_AND_VERSION/jboss-as

if [ ! -d $JBOSS_HOME ]; then
	echo "Relocating JBoss install files to $JBOSS_HOME"
	try su $JBOSS_USER -c \"mkdir -p $HOME_DIR/tempinstall\"
	try su $JBOSS_USER -c \"mv $HOME_DIR/$JBOSS_NAME_AND_VERSION/* $HOME_DIR/tempinstall\"
	try su $JBOSS_USER -c \"mv $HOME_DIR/tempinstall $JBOSS_HOME\"
fi

# Configure specific for domain controller setup
rm $JBOSS_HOME/domain/configuration/host*.xml
cp $host_master $JBOSS_HOME/domain/configuration/host.xml
