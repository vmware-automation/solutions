REM
REM Create a tablespace and orabpel user
REM 

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

define bpm_user=&1
define bpm_passwd=&2
define sys_passwd=&3
define connect_string=&4

connect sys/&sys_passwd@&connect_string as sysdba

REM Create ORABPEL tablespace
REM Oracle database requires that the datafile be qualified
REM explicitly. This procedure checks where the SYSTEM datafiles
REM are and then uses that directory for the ORABPEL datafile.
REM If the ORABPEL tablespace already exists, then do nothing.

DECLARE
  unix    NUMBER;
  win     NUMBER;
  tsexists NUMBER;
  uname   varchar2(512);
  wname   varchar2(512);
  datadir varchar2(512);
BEGIN

--
-- Check if tablespace already exists
--
select count(*)
    into tsexists from v$tablespace
    where name = 'ORABPEL';

IF tsexists >= 1 THEN
    dbms_output.put_line('Tablespace already exists.');
    RETURN;
END IF;

--
-- We could either be on Windows or Unix. Search for the last
-- character that's either a / or \ and figure out which platform
-- we're on.
--

select instr(name, '\', -1), name
    into win, wname from v$datafile
    where file# = (select min(file#) from v$datafile where 
          ts# = (select ts# from v$tablespace where name = 'SYSTEM'));

select instr(name, '/', -1), name
    into unix, uname from v$datafile
    where file# = (select min(file#) from v$datafile where 
          ts# = (select ts# from v$tablespace where name = 'SYSTEM'));

IF unix > win THEN
    datadir := SUBSTR (uname, 1, unix);
ELSE
    datadir := SUBSTR (wname, 1, win);
END IF;

dbms_output.put_line ('datadir = ' || datadir);

--
-- Create Tablespaces with datafiles in datadir.
--

execute immediate 'create tablespace ORABPEL datafile ' ||
    '''' || datadir || 'orabpel.dbf' || '''' ||
    ' SIZE 100M reuse autoextend on NEXT 30M maxsize unlimited';

END;
/


REM
REM Create and grant privileges to orabpel user
REM

drop user &bpm_user cascade;

REM Create and assign privileges to orabpel user
create user &bpm_user identified by &bpm_passwd
        default tablespace ORABPEL;

grant connect, resource, create view to &bpm_user;

