#!/bin/sh
# $Id: runner.sh,v 1.4 2012/06/23 03:48:10 cvsuser Exp $

# Usage: runner.sh [-u user] [-m module] ant-targets
# Default user is oracle and default module is OSB

user="oracle"
module="OSB"
while [ -n "$1" ]; do
	case $1 in
		-u|-U) user="$2"; shift 2;;
			
		-m|-M) module="$2"; shift 2;;
		
		*)	args=$*; break;;
	esac;
done;

cdir=`pwd`
wlsjdk="/oracle/jdk1.6.0_20"

# Allow all users to read/write downloaded files
chmod go+rwx $cdir

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH
if [ -d $wlsjdk ]; then
	export PATH=$wlsjdk/bin:$PATH
fi;

su $user -c "$DROPBOX_HOME/apache-ant-1.8.3/bin/ant -noinput -Dbasedir=. -f $DROPBOX_HOME/$module/build.xml $args"
ret=$?

# Reset permissions back to original value
chmod go-rwx $cdir

# Exit with return value
exit $ret
