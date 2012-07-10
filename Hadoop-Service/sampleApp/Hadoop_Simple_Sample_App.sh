#!/bin/bash
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
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

sleep 5
echo "http://www.cs.brandeis.edu" >url1
echo "http://www.nytimes.com" >url2

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
	chmod u+x $HADOOP_HOME/multifetch.py

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
chmod u+x $HADOOP_HOME/reducer.py

su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -mkdir urls"
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -put url1 urls/"
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -put url2 urls/"
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/contrib/streaming/hadoop-streaming-0.20.203.0.jar -mapper $HADOOP_HOME/multifetch.py -reducer $HADOOP_HOME/reducer.py -input urls/* -output titles -file $HADOOP_HOME/multifetch.py -file $HADOOP_HOME/reducer.py"
check_error "Unable to execute sample.";
echo "Sample Execution Done"

echo "Output of the sample application: "
su $USER_NAME -c "$HADOOP_HOME/bin/hadoop dfs -cat titles/part-00000"

touch job_check.html
wget http://$IP:50030/jobtracker.jsp -q -O job_check.html
sleep 5
grep -q "Completed Jobs" job_check.html
if [ "$?" == "0" ]; then
	echo "JOB COMPLETED SUCCESFULLY"
else
	exit_error "JOB FAILED";
fi