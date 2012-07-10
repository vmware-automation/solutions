#!/usr/bin/expect --
# runs txkSOHM.pl as Shared Application Tier is used
# 
set timeout -1
#exp_internal 1

set ASID [lindex $argv 0]
set LSID [lindex $argv 1]
set XML [lindex $argv 2]
set ITYPE [lindex $argv 3]
set O806 [lindex $argv 4]
set IAS [lindex $argv 5]
set CONTOP [lindex $argv 6]
set APPS [lindex $argv 7]


spawn perl -I /oracle/d1/applmgr/${ASID}/${LSID}appl/au/11.5.0/perl txkSOHM.pl

while 1 {
	expect "Absolute path of Application's Context XML file " {
	send "${XML}\r"

	} "Type of Instance " {
	send "${ITYPE}\r"

	} "Absolute path of 8.0.6 Shared Oracle Home " {
	send "${O806}\r" 

	} "Absolute path of iAS Shared Oracle Home " {
	send "${IAS}\r"

	} "Absolute path of config top " {
	send "${CONTOP}\r"

	} "Oracle Application apps schema password" {
	send "${APPS}\r"

	} eof {
	break

	}
}

send_user "\n\ntxkshom completed in Apps Tier :-\n\n"
