Rem
Rem $Header: 
Rem
Rem DL_VERIFY.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem     DL_VERIFY.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbousamr     06/20/09 - Created
Rem
Rem
Rem ==========================================================
Rem 
Rem Description
Rem -----------
Rem This Package will verify the given DLV_MESSAGE partitions.
Rem 
Rem Each DLV_MESSAGE partition will be verified to check that:
Rem 1. All DLV_MESSAGES are closed 
Rem      and ALL INVOKE_MESSAGES with same partition name are closed.
Rem 2. NAME of each Dependent Table partiton matches the 
Rem      DLV_MESSAGE partition.
Rem 3. LOWER bound of each Dependent Table partiton matches the 
Rem      DLV_MESSAGE partition.
Rem 4. UPPER bound of each Dependent Table partiton matches the 
Rem      DLV_MESSAGE partition.
Rem 
Rem Two collections are passed to this package:
Rem 1. A collection of DLV_MESSAGE partitions to verify.
Rem 2. A collection of Dependent Tables that have been partitioned.
Rem 
Rem The following TABLES are considered Dependents of DLV_MESSAGE:
Rem      'INVOKE_MESSAGE';
Rem      'DOCUMENT_DLV_MSG_REF';
Rem 
Rem The package will create a seperate file (DL_<Dependent Table>) in the 
Rem partition directory (PART_DIR see setup). The file reports the PASS or 
Rem FAILURE of each partition. The messages should be reasonably self 
Rem explanatory.
Rem 
Rem Procedure/functions
Rem -------------------
Rem Dlv_Part_OK: 
Rem  Checks if all rows in the DLV_MESSAGE partition are completed.
Rem
Rem Ivk_Part_OK:
Rem  Checks if all rows in the INVOKE_MESSAGE partition are completed.
Rem
Rem chk_equi_part_ok: Checks dependents for EQUI Partitioning.
Rem   That is; The same NAME, UPPER and LOWER bound.
Rem
Rem exec_verify: Executes the package.
Rem   Each partition in the partition collection will be verified against 
Rem     the collection of dependent tables.
Rem
Rem
Rem SETUP
Rem -----
Rem  The partition directory will contain a file which reports the pass of failure 
Rem      of each enter partition.
Rem  sqlplus> connect <bpel schema owner>/<password>
Rem  sqlplus> create directory PART_DIR as '/.......';
Rem    
Rem
Rem ===========================================================
Rem


SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET SERVEROUT ON


CREATE OR REPLACE PACKAGE VERIFY_DLV
IS

TYPE dlv_drv_table is TABLE of VARCHAR2(100);
TYPE dlv_dep_table is TABLE of VARCHAR2(100);

FUNCTION  Dlv_Part_Ok       
          (dlv_part_name in varchar2) return BOOLEAN;
FUNCTION  Ivk_Part_Ok       
          (dlv_part_name in varchar2) return BOOLEAN;
FUNCTION  Chk_Equi_Part_Ok  
          (dlv_part_name in varchar2, dlv_dep_list in dlv_dep_table) return BOOLEAN;
PROCEDURE Exec_Verify       
          (dlv_drv_list in dlv_drv_table, dlv_dep_list in dlv_dep_table);

END VERIFY_DLV;
/
SHOW ERRORS



CREATE OR REPLACE PACKAGE BODY VERIFY_DLV
IS

TYPE part_record is RECORD 
(
name varchar2(100),
high_value varchar2(2000),
position number
);

PART_DIR_NAME     varchar2(40) := 'PART_DIR';
PART_FILE_NAME    varchar2(40);
PART_HANDLE       UTL_FILE.file_type;

/*
***********************************************************
  Dlv_Part_Ok :  Check Partition for DLV_MESSAGE
***********************************************************
-- Checks that the dlv_message partition has only  
   completed messages.
-- If not; print total rows and total rows completed to
   allow the DBA to decide on whether to purge or 
   migrate rows.
*********************************************************** 
*/

FUNCTION Dlv_Part_Ok 
(dlv_part_name in varchar2) 
return BOOLEAN 
IS

DLV_SUCCESS        BOOLEAN := TRUE;
dlv_closed_count   NUMBER; 
dlv_total_count    NUMBER;
stmt               VARCHAR2(2000);

BEGIN 

UTL_FILE.Putf     (PART_HANDLE, 'CHECKING DLV_MESSAGE PARTITION %s \n', dlv_part_name);

stmt := 'SELECT count(*) '
       || ' FROM DLV_MESSAGE PARTITION(PARTNAME) ';
stmt := REPLACE(stmt,'PARTNAME',dlv_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO dlv_total_count;

stmt := 'SELECT count(*) '
       || 'FROM DLV_MESSAGE PARTITION(PARTNAME) dm '
       || 'WHERE state > 1 '
       || 'AND NOT EXISTS '
       || '(SELECT 1 FROM cube_instance ci, '
       || '  document_ci_ref dcr, '
       || '  document_dlv_msg_ref ddmr '
       || '  WHERE dm.message_guid = ddmr.message_guid '
       || '  AND ddmr.dockey = dcr.dockey '
       || '  AND dcr.cikey = ci.cikey '
       || '  AND ci.state < 5) ';
stmt := REPLACE(stmt,'PARTNAME',dlv_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO dlv_closed_count;

IF dlv_total_count < dlv_closed_count
THEN
  DLV_SUCCESS := FALSE;
  UTL_FILE.Put_Line (PART_HANDLE, '** FAIL - NOT ALL DLV MESSAGES RESOLVED ');
  UTL_FILE.Putf     (PART_HANDLE, '** FAIL -   TOTAL MESSAGES IN PARTITION  : %s \n', dlv_total_count);
  UTL_FILE.Put_Line (PART_HANDLE, '** FAIL -   TOTAL MESSAGES RESOLVED AND NOT STILL');
  UTL_FILE.Putf     (PART_HANDLE, '**            ACTIVE in CUBE_INSTANCE    : %s \n', dlv_closed_count);
ELSE
  UTL_FILE.Put_Line (PART_HANDLE, '** PASS - ALL MESSAGES IN DLV_MESSAGE PARTITION ARE RESOLVED');
END IF;
UTL_FILE.Put_Line   (PART_HANDLE, '----------------------------------------------------');


RETURN DLV_SUCCESS;
END Dlv_Part_Ok;


/*
***********************************************************
  Ivk_Part_Ok :  Check Partition for INVOKE_MESSAGE
***********************************************************
-- Checks that the invoke_message partition has only  
   completed messages.
-- If not; print total rows and total rows completed to
   allow the DBA to decide on whether to purge or 
   migrate rows.
*********************************************************** 
*/

FUNCTION Ivk_Part_Ok 
(dlv_part_name in varchar2) 
return BOOLEAN 
IS

IVK_SUCCESS        BOOLEAN := TRUE;
ivk_closed_count   NUMBER; 
ivk_total_count    NUMBER;
stmt               VARCHAR2(2000);

BEGIN 

UTL_FILE.Putf     (PART_HANDLE, 'CHECKING INVOKE_MESSAGE PARTITION %s \n', dlv_part_name);

stmt := 'SELECT count(*) '
       || ' FROM INVOKE_MESSAGE PARTITION(PARTNAME) ';
stmt := REPLACE(stmt,'PARTNAME',dlv_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO ivk_total_count;

stmt := 'SELECT count(*) '
       || 'FROM INVOKE_MESSAGE PARTITION(PARTNAME) dm '
       || 'WHERE state > 1 '
       || 'AND NOT EXISTS '
       || '(SELECT 1 FROM cube_instance ci, '
       || '  document_ci_ref dcr, '
       || '  document_dlv_msg_ref ddmr '
       || '  WHERE dm.message_guid = ddmr.message_guid '
       || '  AND ddmr.dockey = dcr.dockey '
       || '  AND dcr.cikey = ci.cikey '
       || '  AND ci.state < 5) ';
stmt := REPLACE(stmt,'PARTNAME',dlv_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO ivk_closed_count;

IF ivk_total_count < ivk_closed_count
THEN
  IVK_SUCCESS := FALSE;
  UTL_FILE.Put_Line (PART_HANDLE, '** FAIL - NOT ALL INVOKE MESSAGES RESOLVED ');
  UTL_FILE.Putf     (PART_HANDLE, '** FAIL -   TOTAL MESSAGES IN PARTITION  : %s \n', ivk_total_count);
  UTL_FILE.Put_Line (PART_HANDLE, '** FAIL -   TOTAL MESSAGES RESOLVED AND NOT STILL');
  UTL_FILE.Putf     (PART_HANDLE, '**            ACTIVE in CUBE_INSTANCE    : %s \n', ivk_closed_count);
ELSE
  UTL_FILE.Put_Line (PART_HANDLE, '** PASS - ALL MESSAGES IN INVOKE_MESSAGE PARTITION ARE RESOLVED');
END IF;
UTL_FILE.Put_Line   (PART_HANDLE, '----------------------------------------------------');


RETURN IVK_SUCCESS;
END Ivk_Part_Ok;

/*
***********************************************************
   CHK_EQUI_PART: Checks dependents for EQUI Partitioning.
***********************************************************
-- Loop through the collection of dependent tables partitions
   and verify they are equi-partitioned:
   -- Same NAME as DLV_MESSAGE partition.
   -- Same LOWER BOUND as DLV_MESSAGE partition.
   -- Same UPPER BOUND as DLV_MESSAGE partition.
***********************************************************
*/

FUNCTION Chk_Equi_Part_Ok 
(dlv_part_name in varchar2, 
 dlv_dep_list in dlv_dep_table) 
return BOOLEAN 
IS

ALL_EQUI_SUCCESS     BOOLEAN := TRUE;
DEP_PART_FOUND       BOOLEAN := FALSE;
DEP_PART_PASS        BOOLEAN := TRUE;

dlv_upp_bound        part_record; 
dlv_low_bound        part_record; 
dep_upp_bound        part_record; 
dep_prev_upp_bound   part_record; 
dep_prev_part_pos    PLS_INTEGER := 0; 
dlv_prev_part_pos    PLS_INTEGER := 0; 
dep1                 PLS_INTEGER := 0; 

/*
------------------------------------
COMPLETE Hard Coded list of tables 
which are dependent on the 
DLV_MESSAGE table. 
------------------------------------
*/
CURSOR dlv_dependents is 
SELECT TABLE_NAME, HIGH_VALUE, PARTITION_NAME, PARTITION_POSITION
  FROM USER_TAB_PARTITIONS
 WHERE TABLE_NAME IN (
      'INVOKE_MESSAGE',
      'DOCUMENT_DLV_MSG_REF')
   AND PARTITION_NAME = dlv_part_name;

BEGIN

SELECT PARTITION_NAME, HIGH_VALUE, PARTITION_POSITION
  INTO dlv_upp_bound
  FROM USER_TAB_PARTITIONS
 WHERE TABLE_NAME = 'DLV_MESSAGE'
   AND PARTITION_NAME = dlv_part_name
   AND ROWNUM < 2;
IF SQL%NOTFOUND
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'DLV_VERIFY.Chk_Equi_Part_Ok Logic Error');
END IF;

dlv_prev_part_pos := dlv_upp_bound.position - 1;

IF dlv_prev_part_pos > 0
THEN
SELECT PARTITION_NAME, HIGH_VALUE, PARTITION_POSITION
  INTO dlv_low_bound
  FROM USER_TAB_PARTITIONS
 WHERE TABLE_NAME = 'DLV_MESSAGE'
   AND PARTITION_POSITION = dlv_prev_part_pos
   AND ROWNUM < 2;
 IF SQL%NOTFOUND
  THEN
    RAISE_APPLICATION_ERROR(-20002, 'DLV_VERIFY.Chk_Equi_Part_Ok Logic Error');
 END IF;
ELSE
 dlv_low_bound.position := 0;
END IF;

/* 
------------------------------------
Loop through the Partitions for the
 Dependent Tables.
------------------------------------
*/
FOR i in dlv_dep_list.FIRST..dlv_dep_list.LAST LOOP

UTL_FILE.Putf(PART_HANDLE, 'CHECKING EQUI-PARTITION FOR TABLE %s \n', dlv_dep_list(i));

/* 
------------------------------------
Loop through the Dependent tables to 
determine if ALL Dependent Tables 
are partitioned.
------------------------------------
*/
DEP_PART_FOUND := FALSE;
DEP_PART_PASS  := TRUE;

FOR dep1 in dlv_dependents LOOP 

IF dep1.partition_name = dlv_part_name
AND dep1.table_name = dlv_dep_list(i)
THEN
  dep_upp_bound.high_value := dep1.high_value;
  IF dep_upp_bound.high_value = dlv_upp_bound.high_value
  THEN
  DEP_PART_FOUND := TRUE;
  UTL_FILE.Put_Line(PART_HANDLE, '** PASS - PARTITION NAME MATCH');
  UTL_FILE.Put_Line(PART_HANDLE, '** PASS - UPPER BOUND MATCH'); 

/*
------------------------------------
 IF previous partition position is 0 then
  there in no previous parition and LOWER BOUND
  is IMPLICIT.
------------------------------------
*/
  dep_prev_part_pos := dep1.partition_position - 1;  
  IF dep_prev_part_pos = 0
  OR dlv_low_bound.position = 0
  THEN
    IF dep_prev_part_pos <> 0
    OR dlv_low_bound.position <> 0
    THEN
	DEP_PART_PASS := FALSE;
	UTL_FILE.Put_Line(PART_HANDLE, '** FAIL - IMPLICT LOWER BOUND MISMATCH'); 
    ELSE
	UTL_FILE.Put_Line(PART_HANDLE, '** PASS - IMPLICT LOWER BOUND MATCH'); 
    END IF;
  ELSE
    SELECT PARTITION_NAME, HIGH_VALUE, PARTITION_POSITION
      INTO dep_prev_upp_bound 
      FROM USER_TAB_PARTITIONS
     WHERE PARTITION_NAME = dlv_low_bound.name 
	 AND TABLE_NAME = dep1.table_name
	 AND PARTITION_POSITION = dep_prev_part_pos
       AND ROWNUM < 2;
    IF SQL%FOUND
    THEN
	IF dep_prev_upp_bound.high_value <> dlv_low_bound.high_value
	THEN
	  DEP_PART_PASS := FALSE;
	  UTL_FILE.Put_Line(PART_HANDLE, '** FAIL - LOWER BOUND MISMATCH'); 
      ELSE
	  UTL_FILE.Put_Line(PART_HANDLE, '** PASS - LOWER BOUND MATCH');
      END IF;
     END IF;
    END IF;
   END IF;
  END IF;
END LOOP;

IF DEP_PART_FOUND
THEN 
  IF DEP_PART_PASS 
  THEN
    UTL_FILE.Put_Line(PART_HANDLE, '** PASS - EQUI-PARTITIONED TESTS - PASS');
  ELSE
    UTL_FILE.Put_Line(PART_HANDLE, '** FAIL - EQUI-PARTITIONED TESTS - FAIL');
    ALL_EQUI_SUCCESS := FALSE;
  END IF;
ELSE
    UTL_FILE.Put_Line(PART_HANDLE, '** FAIL - THE PARTITION NAME DOES NOT EXIST OR IS NOT A DEPENDENT');
    ALL_EQUI_SUCCESS := FALSE;
END IF;	 

END LOOP; 
 
RETURN ALL_EQUI_SUCCESS;

END Chk_Equi_Part_Ok;


/* 
***********************************************************
  Exec_Verify : Execute
***********************************************************
-- Loop through the collection of DLV_MESSAGE partitions.
***********************************************************
*/
PROCEDURE Exec_Verify 
(dlv_drv_list in dlv_drv_table, dlv_dep_list in dlv_dep_table) 
IS

BEGIN

FOR i in dlv_drv_list.FIRST..dlv_drv_list.LAST LOOP

PART_FILE_NAME := UPPER('DL_'||dlv_drv_list(i));
PART_HANDLE := UTL_FILE.fopen(PART_DIR_NAME, PART_FILE_NAME, 'W');

IF (Dlv_Part_Ok(UPPER(dlv_drv_list(i))))
THEN
  IF (Ivk_Part_Ok(UPPER(dlv_drv_list(i))))
  THEN
    IF (Chk_Equi_Part_Ok(UPPER(dlv_drv_list(i)),dlv_dep_list))
    THEN	   
      UTL_FILE.Put_Line (PART_HANDLE,'----------------------------------------------------');
      UTL_FILE.Put_Line (PART_HANDLE,'PASS: ALL MESSAGES ARE CLOSED AND ALL PARTITIONS     ');
      UTL_FILE.Put_line (PART_HANDLE,'         ARE EQUI-PARTITIONED THUS THEY CAN BE DROPPED'); 
    ELSE
      UTL_FILE.Put_Line (PART_HANDLE,'----------------------------------------------------');
      UTL_FILE.Put_Line (PART_HANDLE,'FAIL: NOT ALL PARTITIONS ARE EQUI-PARTITIONED AND THUS CANNOT BE DROPPED');
    END IF;
  ELSE
    UTL_FILE.Put_Line (PART_HANDLE,'----------------------------------------------------');
    UTL_FILE.Put_Line (PART_HANDLE,'FAIL: INVOKE PARTITION HAS OPEN MESSAGES AND THUS CANNOT BE DROPPED'); 
  END IF;
ELSE
  UTL_FILE.Put_Line (PART_HANDLE,'----------------------------------------------------');
  UTL_FILE.Put_Line (PART_HANDLE,'FAIL: DLV PARTITION HAS OPEN MESSAGES AND THUS CANNOT BE DROPPED'); 
END IF;


UTL_FILE.Put_Line (PART_HANDLE,'------------END OF REPORT---------------------------');
UTL_FILE.fclose(PART_HANDLE);

END LOOP;

END Exec_Verify;

END VERIFY_DLV;

/
SHOW ERRORS
