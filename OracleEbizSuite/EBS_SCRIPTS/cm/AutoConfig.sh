#!/usr/bin/expect --
# runs autoconfig for clone with minimal parameters
#
set timeout -1
#exp_internal 1

set APPS [lindex $argv 0]

spawn adautocfg.sh

while 1 {
	expect "Enter the APPS user password" {
	send $APPS\r

	} eof {
	break

	}
}

send_user "\n\nAPPS Autoconfig Completed :-\n\n"

