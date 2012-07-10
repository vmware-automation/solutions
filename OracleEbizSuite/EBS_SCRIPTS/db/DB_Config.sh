#!/usr/bin/expect --
# runs DB Configuration for Clone with minimal parameters
# 
set timeout -1
#exp_internal 1

set APPS [lindex $argv 0]
set SID [lindex $argv 1]
set HOST [lindex $argv 2]
set POOL [lindex $argv 3]

spawn perl adcfgclone.pl dbTier

while 1 {
	expect "Enter the APPS password" {
	send "${APPS}\r"

	} "Do you want to use a virtual hostname for the target node (y/n)" {
	send "n\r"

	} "Target instance is a Real Application Cluster (RAC) instance (y/n)" {
	send "n\r"

	} "Target System database name" {
	send "${SID}\r" 

	} "Target system domain name" {
	send "\r"

	} "Target system RDBMS ORACLE_HOME directory" {
	send "/oracle/app/oracle/product/10.2.0/db\r"

	} "Target system utl_file accessible directories list" {
	send "/usr/tmp\r"

	} "Number of DATA_TOP's on the target system" {
	send "1\r"

	} "Target system DATA_TOP 1" {
	send "/oracle/oradata/${SID}\r"

	} "Do you want to preserve the Display set to ora-bak-ebs-d1:1.0 (y/n)" {
	send "n\r"

	} "Target system Display" {
	send "${HOST}:1.0\r"

	} "Do you want to preserve the port values from the source system on the target system (y/n)" {
	send "n\r"

	} "Enter the port pool number" {
	send "${POOL}\r"

	} eof {
	break

	}
}

send_user "\n\nDB Clone Completeted :-\n\n"

