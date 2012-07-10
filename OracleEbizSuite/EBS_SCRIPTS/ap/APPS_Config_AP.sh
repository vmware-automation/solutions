#!/usr/bin/expect --
# runs Apps Configuration for CM Clone with minimal parameters
# 
set timeout -1
#exp_internal 1

set APPS [lindex $argv 0]
set SID [lindex $argv 1]
set DBHOST [lindex $argv 2]
set CMHOST [lindex $argv 3]
set APHOST [lindex $argv 4]
set LSID [lindex $argv 5]
set POOL [lindex $argv 6]

spawn perl adcfgclone.pl appsTier

while 1 {
	expect "Enter the APPS password" {
	send "${APPS}\r"

	} "Do you want to use a virtual hostname for the target node" {
	send "n\r"

	} "Target system database SID " {
	send "${SID}\r" 

	} "Target system database server node " {
	send "${DBHOST}\r"

	} "Target system database domain name" {
	send "\r"

	} "Does the target system have more than one application tier server node" {
	send "y\r"

	} "Does the target system application tier utilize multiple domain names" {
	send "\r"	

	} "Target system concurrent processing node" {
	send "${CMHOST}\r"	

	} "Target system administration node " {
	send "${CMHOST}\r"	

	} "Target system forms server node " {
	send "${APHOST}\r"	

	} "Target system web server node " {
	send "${APHOST}\r"	

	} "Is the target system APPL_TOP divided into multiple mount points " {
	send "\r"	

	} "Target system APPL_TOP mount point" {
	send "/oracle/d1/applmgr/${SID}/${LSID}appl\r"

	} "Target system COMMON_TOP directory" {
	send "/oracle/d1/applmgr/${SID}/${LSID}comn\r"

	} "Target system 8.0.6 ORACLE_HOME directory" {
	send "/oracle/d1/applmgr/${SID}/${LSID}ora/8.0.6\r"

	} "Target system iAS ORACLE_HOME directory" {
	send "/oracle/d1/applmgr/${SID}/${LSID}ora/iAS\r"

	} "Do you want to preserve the Display set to " {
	send "n\r"

	} "Target system Display" {
	send "${CMHOST}:1.0\r"

	} "Do you want to preserve the port values from the source system on the target system (y/n)" {
	send "n\r"

	} "Enter the port pool number" {
	send "${POOL}\r"

	} "Choose a value which will be set as APPLPTMP value on the target node" {
	send "1\r"

	} eof {
	break

	}
}

send_user "\n\nMiddle Tier Clone Completeted :-\n\n"

