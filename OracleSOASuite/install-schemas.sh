#!/bin/sh
# $Id: install-schemas.sh,v 1.3 2012/06/21 19:33:51 cvsuser Exp $

DROPBOX_LOC=/tmp/mount

# Exit if any command fails
set -e

# Create orabpel user
$ORACLE_HOME/bin/sqlplus sys/$SYSPASSWORD@$SID as sysdba @$DROPBOX_LOC/SOACLONE/scripts/createuser_oracle.sql $BPEL_ACCOUNT $BPEL_PASSWORD $SYSPASSWORD $SID < /dev/null

# Create orabpel schema
$ORACLE_HOME/bin/sqlplus $BPEL_ACCOUNT/$BPEL_PASSWORD@$SID @$DROPBOX_LOC/SOACLONE/scripts/createschema_oracle.sql < /dev/null

# Upgrade schema to 10.1.3.5
$ORACLE_HOME/bin/sqlplus $BPEL_ACCOUNT/$BPEL_PASSWORD@$SID @$DROPBOX_LOC/SOACLONE/scripts/upgrade_10131_10135_oracle.sql < /dev/null

# Create directory for dump files and FMWJMSD tablespace
$ORACLE_HOME/bin/sqlplus "sys/$SYSPASSWORD@$SID as sysdba" << EndSQL
set serveroutput on
set echo on
create or replace directory dropbox_dir as '$DROPBOX_LOC/SOACLONE';
declare
	unix NUMBER;
	tsexists NUMBER;
	uname varchar2(512);
	datadir varchar2(512);
begin
	--
	-- Check if tablespace already exists
	--
	select count(*)
	into tsexists from v\$tablespace
    where name = 'FMWJMSD';

	IF tsexists >= 1 THEN
    	dbms_output.put_line('FMWJMSD tablespace already exists.');
        RETURN;
	END IF;

	select instr(name, '/', -1), name
    into unix, uname from v\$datafile
    where file# = (select min(file#) from v\$datafile where
			ts# = (select ts# from v\$tablespace where name = 'SYSTEM'));

    datadir := SUBSTR (uname, 1, unix);
	dbms_output.put_line ('datadir = ' || datadir);

	--
	-- Create Tablespaces with datafiles in datadir.
	--
	execute immediate 'create tablespace FMWJMSD datafile ' ||
    	    '''' || datadir || 'fmwjmsd01.dbf' || '''' ||
    	    ' SIZE 300M reuse autoextend on NEXT 30M maxsize unlimited';
end;
/
EndSQL

