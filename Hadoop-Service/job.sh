#!/bin/bash
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export http_proxy=http://proxy.vmware.com:3128
export INSTALL_PATH=/home/hadoop/project
export USER_NAME=hadoop
export HADOOP_HOME=$INSTALL_PATH/hadoop-0.20.203.0

###########Paramter Validation Functions##################
# Function To Display Error and Exit
function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

cd $HADOOP_HOME

#Removing file result.txt
rm /tmp/result.txt

#Changing Owener
chown $USER_NAME /tmp/url.txt

#Removing empty line
grep -v '^$' /tmp/url.txt > /tmp/url.txt.$$

#Removing content of url.txt 
:> /tmp/url.txt

#Moving content of temp file to original file
mv /tmp/url.txt.$$ /tmp/url.txt

sleep 5

#Creating multifetch.py
cat <<ENDmultifetch > $HADOOP_HOME/multifetch.py
#!/usr/bin/env python
#
# Adapted from an example by Michael G. Noll at:
#
# http://www.michael-noll.com/wiki/Writing_An_Hadoop_MapReduce_Program_In_Python
#
 
import sys, urllib, re

title_re = re.compile("<title>(.*?)</title>",
                      re.MULTILINE | re.DOTALL | re.IGNORECASE)
 
# Read pairs as lines of input from STDIN
for line in sys.stdin:
    # We assume that we are fed a series of URLs, one per line
    url = line.strip()
    # Fetch the content and output the title (pairs are tab-delimited)
    match = title_re.search(urllib.urlopen(url).read())
    if match:
        print url, "\t", match.group(1).strip()
ENDmultifetch
	check_error "Unable to create multifetch.py.";
	chmod 777 $HADOOP_HOME/multifetch.py

#Creating reducer.py
cat <<ENDreducer > $HADOOP_HOME/reducer.py
#!/usr/bin/env python
#
# Adapted from an example by Michael G. Noll at:
#
# http://www.michael-noll.com/wiki/Writing_An_Hadoop_MapReduce_Program_In_Python
#

from operator import itemgetter
import sys

for line in sys.stdin:
    line = line.strip()
    print line
ENDreducer

check_error "Unable to create reducer.py.";
chmod 777 $HADOOP_HOME/reducer.py

su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -mkdir urls"
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -put /tmp/url.txt urls/"

su $USER_NAME -c "$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/contrib/streaming/hadoop-streaming-0.20.203.0.jar -mapper $HADOOP_HOME/multifetch.py -reducer $HADOOP_HOME/reducer.py -input urls/* -output titles -file $HADOOP_HOME/multifetch.py -file $HADOOP_HOME/reducer.py"
check_error "Unable to execute sample.";
echo "Sample Execution Done"

echo "Output of the sample application: "
#su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -cat titles/part-00000"

su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -get titles/part-00000 /tmp/result.txt"
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -rmr urls"
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -rmr titles"
