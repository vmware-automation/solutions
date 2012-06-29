Rem
Rem $Header: 
Rem
Rem CI_VERIFY.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem     CI_VERIFY.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbousamr     06/20/09 - Created
Rem
Rem
Rem ==========================================================
Rem 
Rem Description
Rem -----------
Rem This Package will verify the given CUBE_INSTANCE partitions.
Rem 
Rem Each CUBE_INSTANCE partition will be verified to check that:
Rem 1. All bpel instances have completed OR that the entire parent
Rem    and child tree of BPEL instances are complete.
Rem 2. NAME of each Dependent Table partiton matches the 
Rem    CUBE_INSTANCE partition.
Rem 3. LOWER bound of each Dependent Table partiton matches the 
Rem    CUBE_INSTANCE partition.
Rem 4. UPPER bound of each Dependent Table partiton matches the 
Rem    CUBE_INSTANCE partition.
Rem 
Rem Two collections are passed to this package:
Rem 1. A collection of CUBE_INSTANCE partitions to verify.
Rem 2. A collection of Dependent Tables that have been partitioned.
Rem 
Rem The following TABLES are considered Dependents of CUBE_INSTANCE:
Rem      'ATTACHMENT';
Rem      'ATTACHMENT_REF';
Rem      'AUDIT_DETAILS';
Rem      'AUDIT_TRAIL';
Rem      'CI_INDEXES';
Rem      'CUBE_SCOPE';
Rem      'DLV_SUBSCRIPTION';
Rem      'DOCUMENT_CI_REF';
Rem      'WI_EXCEPTION';
Rem      'WI_FAULT';
Rem      'WORK_ITEM';
Rem 
Rem The package will create a seperate file (CI_<Dependent Table>) in the 
Rem partition directory (PART_DIR see setup). The file reports the PASS or 
Rem FAILURE of each partition. The messages should be reasonably self 
Rem explanatory.
Rem 
Rem Procedure/functions
Rem -------------------
Rem chk_part_ok: Check Driver Partition for CUBE_INSTANCE:
Rem  Checks if all rows in the partition are completed.
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


CREATE OR REPLACE PACKAGE VERIFY_CUBE
IS

TYPE cube_drv_table is TABLE of VARCHAR2(100);
TYPE cube_dep_table is TABLE of VARCHAR2(100);

FUNCTION  Chk_Part_Ok       
          (cube_part_name in varchar2, chk_tree in BOOLEAN) return BOOLEAN;
FUNCTION  Chk_Equi_Part_Ok  
          (cube_part_name in varchar2, cube_dep_list in cube_dep_table) return BOOLEAN;
PROCEDURE Exec_Verify       
          (chk_tree in BOOLEAN, cube_drv_list in cube_drv_table, cube_dep_list in cube_dep_table);

END VERIFY_CUBE;
/
SHOW ERRORS



CREATE OR REPLACE PACKAGE BODY VERIFY_CUBE
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
  Chk_Part_Ok :  Check Driver Partition for CUBE_INSTANCE
***********************************************************
-- Checks that the cube_instance partition has only  
   completed instances.
-- If not; print total rows and total rows completed to
   allow the DBA to decide on whether to purge or 
   migrate rows.
*********************************************************** 
*/

FUNCTION Chk_Part_Ok 
(cube_part_name in varchar2,
 chk_tree in BOOLEAN) 
return BOOLEAN 
IS

CUBE_SUCCESS       BOOLEAN := TRUE;
cube_open_count    NUMBER; 
cube_total_count   NUMBER;
stmt               VARCHAR2(2000);

BEGIN 

UTL_FILE.Putf     (PART_HANDLE, 'CHECKING CUBE_INSTANCE PARTITION %s \n', cube_part_name);
UTL_FILE.Put_Line (PART_HANDLE, '----------------------------------------------------');

IF (chk_tree)
THEN
  stmt := 'SELECT count(*) '
       || 'FROM CUBE_INSTANCE PARTITION(PARTNAME) C '
       || 'WHERE EXISTS '
       || ' (SELECT 1 FROM CUBE_INSTANCE X '
       || '  WHERE X.root_id = C.root_Id '
       || '    AND X.state < 5) ';
  stmt := REPLACE(stmt,'PARTNAME',cube_part_name);
ELSE
  stmt := 'SELECT count(*) '
       || 'FROM CUBE_INSTANCE PARTITION(PARTNAME) '
       || 'WHERE STATE < 5 ';
  stmt := REPLACE(stmt,'PARTNAME',cube_part_name);
END IF;

dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO cube_open_count;

IF cube_open_count > 0
THEN

CUBE_SUCCESS := FALSE;
stmt := 'SELECT count(*) '
     || 'FROM CUBE_INSTANCE PARTITION(PARTNAME)';
stmt := REPLACE(stmt,'PARTNAME',cube_part_name);

EXECUTE IMMEDIATE stmt INTO cube_total_count;

UTL_FILE.Putf(PART_HANDLE, '** FAIL - TOTAL INSTANCES IN PARTITION  : %s \n', cube_total_count);
UTL_FILE.Putf(PART_HANDLE, '** FAIL - TOTAL INSTANCES STILL OPEN    : %s \n', cube_open_count);

END IF;

RETURN CUBE_SUCCESS;
END Chk_Part_Ok;

/*
***********************************************************
   CHK_EQUI_PART: Checks dependents for EQUI Partitioning.
***********************************************************
-- Loop through the collection of dependent tables partitions
   and verify they are equi-partitioned:
   -- Same NAME as CUBE_INSTANCE partition.
   -- Same LOWER BOUND as CUBE_INSTANCE partition.
   -- Same UPPER BOUND as CUBE_INSTANCE partition.
***********************************************************
*/

FUNCTION Chk_Equi_Part_Ok 
(cube_part_name in varchar2, 
cube_dep_list in cube_dep_table) 
return BOOLEAN 
IS

ALL_EQUI_SUCCESS     BOOLEAN := TRUE;
DEP_PART_FOUND       BOOLEAN := FALSE;
DEP_PART_PASS        BOOLEAN := TRUE;

cube_upp_bound       part_record; 
cube_low_bound       part_record; 
dep_upp_bound        part_record; 
dep_prev_upp_bound   part_record; 
dep_prev_part_pos    PLS_INTEGER := 0; 
cube_prev_part_pos   PLS_INTEGER := 0; 
dep1                 PLS_INTEGER := 0; 

/*
------------------------------------
COMPLETE Hard Coded list of tables 
which are dependent on the 
CUBE_INSTANCE table. 
------------------------------------
*/
CURSOR cube_dependents is 
SELECT TABLE_NAME, HIGH_VALUE, PARTITION_NAME, PARTITION_POSITION
  FROM USER_TAB_PARTITIONS
 WHERE TABLE_NAME IN (
      'ATTACHMENT',
      'ATTACHMENT_REF',
      'AUDIT_DETAILS',
      'AUDIT_TRAIL',
      'CI_INDEXES',
      'CUBE_SCOPE',
      'DLV_SUBSCRIPTION',
      'DOCUMENT_CI_REF',
      'WI_EXCEPTION',
      'WI_FAULT',
      'WORK_ITEM')
   AND PARTITION_NAME = cube_part_name;

BEGIN

SELECT PARTITION_NAME, HIGH_VALUE, PARTITION_POSITION
  INTO cube_upp_bound
  FROM USER_TAB_PARTITIONS
 WHERE TABLE_NAME = 'CUBE_INSTANCE'
   AND PARTITION_NAME = cube_part_name
   AND ROWNUM < 2;
IF SQL%NOTFOUND
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'CUBE_VERIFY.Chk_Equi_Part_Ok Logic Error');
END IF;

cube_prev_part_pos := cube_upp_bound.position - 1;

IF cube_prev_part_pos > 0
THEN
SELECT PARTITION_NAME, HIGH_VALUE, PARTITION_POSITION
  INTO cube_low_bound
  FROM USER_TAB_PARTITIONS
 WHERE TABLE_NAME = 'CUBE_INSTANCE'
   AND PARTITION_POSITION = cube_prev_part_pos
   AND ROWNUM < 2;
 IF SQL%NOTFOUND
  THEN
    RAISE_APPLICATION_ERROR(-20002, 'CUBE_VERIFY.Chk_Equi_Part_Ok Logic Error');
 END IF;
ELSE
 cube_low_bound.position := 0;
END IF;

/* 
------------------------------------
Loop through the Partitions for the
 Dependent Tables.
------------------------------------
*/
FOR i in cube_dep_list.FIRST..cube_dep_list.LAST LOOP

UTL_FILE.Putf(PART_HANDLE, 'CHECKING PARTITION FOR TABLE %s \n', cube_dep_list(i));

/* 
------------------------------------
Loop through the Dependent tables to 
determine if ALL Dependent Tables 
are partitioned.
------------------------------------
*/
DEP_PART_FOUND := FALSE;
DEP_PART_PASS  := TRUE;

FOR dep1 in cube_dependents LOOP 

IF dep1.partition_name = cube_part_name
AND dep1.table_name = cube_dep_list(i)
THEN
  dep_upp_bound.high_value := dep1.high_value;
  IF dep_upp_bound.high_value = cube_upp_bound.high_value
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
  OR cube_low_bound.position = 0
  THEN
    IF dep_prev_part_pos <> 0
    OR cube_low_bound.position <> 0
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
     WHERE PARTITION_NAME = cube_low_bound.name 
	 AND TABLE_NAME = dep1.table_name
	 AND PARTITION_POSITION = dep_prev_part_pos
       AND ROWNUM < 2;
    IF SQL%FOUND
    THEN
	IF dep_prev_upp_bound.high_value <> cube_low_bound.high_value
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
-- Loop through the collection of CUBE_INSTANCE partitions.
***********************************************************
*/
PROCEDURE Exec_Verify 
(chk_tree in BOOLEAN, cube_drv_list in cube_drv_table, cube_dep_list in cube_dep_table) 
IS

BEGIN

FOR i in cube_drv_list.FIRST..cube_drv_list.LAST LOOP

PART_FILE_NAME := UPPER('CI_'||cube_drv_list(i));
PART_HANDLE := UTL_FILE.fopen(PART_DIR_NAME, PART_FILE_NAME, 'W');

IF (Chk_Part_Ok(UPPER(cube_drv_list(i)),chk_tree))
THEN
  IF (Chk_Equi_Part_Ok(UPPER(cube_drv_list(i)),cube_dep_list))
  THEN	   
    UTL_FILE.Put_Line (PART_HANDLE,'----------------------------------------------------');
    UTL_FILE.Put_Line (PART_HANDLE,'PASS: ALL CUBE INSTANCES ARE CLOSED AND ALL PARTITIONS');
    UTL_FILE.Put_line (PART_HANDLE,'         ARE EQUI-PARTITIONED THUS THEY CAN BE DROPPED'); 
  ELSE
    UTL_FILE.Put_Line (PART_HANDLE,'----------------------------------------------------');
    UTL_FILE.Put_Line (PART_HANDLE,'FAIL: NOT ALL PARTITIONS ARE EQUI-PARTITIONED AND THUS CANNOT BE DROPPED');
  END IF;
ELSE
  UTL_FILE.Put_Line (PART_HANDLE,'----------------------------------------------------');
  UTL_FILE.Put_Line (PART_HANDLE,'FAIL: CUBE INSTANCE PARTITION HAS OPEN INSTANCES AND THUS CANNOT BE DROPPED'); 
END IF;

UTL_FILE.Put_Line (PART_HANDLE,'------------END OF REPORT---------------------------');
UTL_FILE.fclose(PART_HANDLE);

END LOOP;

END Exec_Verify;

END VERIFY_CUBE;

/
SHOW ERRORS
