Rem
Rem $Header: 
Rem
Rem DC_VERIFY.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem     DC_VERIFY.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbousamr     06/20/09 - Created
Rem
Rem
Rem ==========================================================
Rem 
Rem Description
Rem -----------
Rem This Package will verify the given XML_DOCUMENT partitions.
Rem 
Rem Each XML_DOCUMENT partition will be verified to check that:
Rem 1. There are no associated documents in DOCUMENT_DLV_MSG_REF table.
Rem 2. There are no associated documents in DLV_MESSAGE table.
Rem 3. There are no associated documents in INVOKE_MESSAGE table.
Rem 4. There are no associated documents in DOCUMENT_CI_REF table.
Rem 5. There are no associated documents in AUDIT_DETAILS table.
Rem 
Rem A collection of XML_DOCUMENT partitions are passed to the package.
Rem 
Rem The package will create a seperate file (DC_<XML_DOCUMENT Partition>) in the 
Rem partition directory (PART_DIR see setup). The file reports the PASS or 
Rem FAILURE of each partition. The messages should be reasonably self 
Rem explanatory.
Rem 
Rem Procedure/functions
Rem -------------------
Rem Dl_Ref_Part_Ok: 
Rem  Checks there are no associated documents in DOCUMENT_DLV_MSG_REF table.
Rem
Rem Dlv_Part_Ok: 
Rem  Checks there are no associated documents in DLV_MESSAGE table.
Rem
Rem Ivk_Part_Ok: 
Rem  Checks there are no associated documents in INVOKE_MESSAGE table.
Rem
Rem Ci_Ref_Part_Ok:
Rem  Checks there are no associated documents in DOCUMENT_CI_REF table.
Rem
Rem Ad_Part_Ok: Checks dependents for EQUI Partitioning.
Rem  Checks there are no associated documents in AUDIT_DETAILS table
Rem
Rem Exec_Verify: Executes the package.
Rem   Each partition in the partition collection will be verified.
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


CREATE OR REPLACE PACKAGE VERIFY_DOC
IS

TYPE doc_drv_table is TABLE of VARCHAR2(100);

FUNCTION  Dl_Ref_Part_Ok       
          (doc_part_name in varchar2) return BOOLEAN;
FUNCTION  Dlv_Part_Ok       
          (doc_part_name in varchar2) return BOOLEAN;
FUNCTION  Ivk_Part_Ok       
          (doc_part_name in varchar2) return BOOLEAN;
FUNCTION  Ci_Ref_Part_Ok       
          (doc_part_name in varchar2) return BOOLEAN;
FUNCTION  Ad_Part_Ok       
          (doc_part_name in varchar2) return BOOLEAN;
PROCEDURE Exec_Verify       
          (doc_drv_list in doc_drv_table);

END VERIFY_DOC;
/
SHOW ERRORS



CREATE OR REPLACE PACKAGE BODY VERIFY_DOC
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
  Dl_Ref_Part_Ok :  Check DOCUMENT_DLV_MSG_REF
***********************************************************
-- Check there are no documents in DOCUMENT_DLV_MSG_REF
   still related to the XML_DOCUMENT partition.
-- If not; print total document to allow the DBA to decide 
   on whether to purge or migrate rows.
*********************************************************** 
*/

FUNCTION Dl_Ref_Part_Ok 
(doc_part_name in varchar2) 
return BOOLEAN 
IS

DL_SUCCESS        BOOLEAN := TRUE; 
dl_total_count    NUMBER;
stmt              VARCHAR2(2000);

BEGIN 

UTL_FILE.Put_Line (PART_HANDLE, 'CHECKING DOCUMENT_DLV_MSG_REF TABLE');

stmt := 'SELECT count(*) '
       || ' FROM XML_DOCUMENT PARTITION(PARTNAME) X '
       || ' WHERE EXISTS '
       || ' (SELECT 1 FROM DOCUMENT_DLV_MSG_REF R '
       || '  WHERE R.dockey = X.dockey) ';
stmt := REPLACE(stmt,'PARTNAME',doc_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO dl_total_count;

IF dl_total_count > 0
THEN
  DL_SUCCESS := FALSE;
  UTL_FILE.Putf     (PART_HANDLE, '** FAIL - TOTAL DOCUMENTS STILL ACTIVE    : %s \n', dl_total_count);
ELSE
  UTL_FILE.Put_Line (PART_HANDLE, '** PASS - NO DOCUMENTS ARE STILL ACTIVE ');
END IF;
UTL_FILE.Put_Line   (PART_HANDLE, '----------------------------------------------------');

RETURN DL_SUCCESS;
END Dl_Ref_Part_Ok;

/*
***********************************************************
  Dlv_Part_Ok :  Check DLV_MESSAGE
***********************************************************
-- Check there are no documents in DLV_MESSAGE
   still related to the XML_DOCUMENT partition.
-- If not; print total document to allow the DBA to decide 
   on whether to purge or migrate rows.
*********************************************************** 
*/

FUNCTION Dlv_Part_Ok 
(doc_part_name in varchar2) 
return BOOLEAN 
IS

DLV_SUCCESS        BOOLEAN := TRUE; 
dlv_total_count    NUMBER;
stmt               VARCHAR2(2000);

BEGIN 

UTL_FILE.Put_Line (PART_HANDLE, 'CHECKING DLV_MESSAGE TABLE');

stmt := 'SELECT count(*) '
       || ' FROM XML_DOCUMENT PARTITION(PARTNAME) X '
       || ' WHERE EXISTS '
       || ' (SELECT 1 FROM DLV_MESSAGE R '
       || '  WHERE R.headers_ref_id = X.dockey) ';
stmt := REPLACE(stmt,'PARTNAME',doc_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO dlv_total_count;

IF dlv_total_count > 0
THEN
  DLV_SUCCESS := FALSE;
  UTL_FILE.Putf     (PART_HANDLE, '** FAIL - TOTAL DOCUMENTS STILL ACTIVE    : %s \n', dlv_total_count);
ELSE
  UTL_FILE.Put_Line (PART_HANDLE, '** PASS - NO DOCUMENTS ARE STILL ACTIVE ');
END IF;
UTL_FILE.Put_Line   (PART_HANDLE, '----------------------------------------------------');

RETURN DLV_SUCCESS;
END Dlv_Part_Ok;


/*
***********************************************************
  Ivk_Part_Ok :  Check INVOKE_MESSAGE
***********************************************************
-- Check there are no documents in INVOKE_MESSAGE
   still related to the XML_DOCUMENT partition.
-- If not; print total document to allow the DBA to decide 
   on whether to purge or migrate rows.
*********************************************************** 
*/

FUNCTION Ivk_Part_Ok 
(doc_part_name in varchar2) 
return BOOLEAN 
IS

IVK_SUCCESS        BOOLEAN := TRUE; 
ivk_total_count    NUMBER;
stmt               VARCHAR2(2000);

BEGIN 

UTL_FILE.Put_Line (PART_HANDLE, 'CHECKING INVOKE_MESSAGE TABLE');

stmt := 'SELECT count(*) '
       || ' FROM XML_DOCUMENT PARTITION(PARTNAME) X '
       || ' WHERE EXISTS '
       || ' (SELECT 1 FROM INVOKE_MESSAGE R '
       || '  WHERE R.headers_ref_id = X.dockey) ';
stmt := REPLACE(stmt,'PARTNAME',doc_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO ivk_total_count;

IF ivk_total_count > 0
THEN
  IVK_SUCCESS := FALSE;
  UTL_FILE.Putf     (PART_HANDLE, '** FAIL - TOTAL DOCUMENTS STILL ACTIVE    : %s \n', ivk_total_count);
ELSE
  UTL_FILE.Put_Line (PART_HANDLE, '** PASS - NO DOCUMENTS ARE STILL ACTIVE ');
END IF;
UTL_FILE.Put_Line   (PART_HANDLE, '----------------------------------------------------');

RETURN IVK_SUCCESS;
END Ivk_Part_Ok;


/*
***********************************************************
  Ci_Ref_Part_Ok :  Check DOCUMENT_CI_REF
***********************************************************
-- Checks there are no documents in DOCUMENT_CI_REF
   still related to the XML_DOCUMENT partition.
-- If not; print total document to allow the DBA to decide 
   on whether to purge or migrate rows.
*********************************************************** 
*/

FUNCTION Ci_Ref_Part_Ok 
(doc_part_name in varchar2) 
return BOOLEAN 
IS

CI_SUCCESS        BOOLEAN := TRUE; 
ci_total_count    NUMBER;
stmt              VARCHAR2(2000);

BEGIN 

UTL_FILE.Put_Line (PART_HANDLE, 'CHECKING DOCUMENT_CI_REF TABLE');

stmt := 'SELECT count(*) '
       || ' FROM XML_DOCUMENT PARTITION(PARTNAME) X '
       || ' WHERE EXISTS '
       || ' (SELECT 1 FROM DOCUMENT_CI_REF R '
       || '  WHERE R.dockey = X.dockey) ';
stmt := REPLACE(stmt,'PARTNAME',doc_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO ci_total_count;

IF ci_total_count > 0
THEN
  CI_SUCCESS := FALSE;
  UTL_FILE.Putf     (PART_HANDLE, '** FAIL - TOTAL DOCUMENTS STILL ACTIVE    : %s \n', ci_total_count);
ELSE
  UTL_FILE.Put_Line (PART_HANDLE, '** PASS - NO DOCUMENTS ARE STILL ACTIVE ');
END IF;
UTL_FILE.Put_Line   (PART_HANDLE, '----------------------------------------------------');


RETURN CI_SUCCESS;
END Ci_Ref_Part_Ok;


/*
***********************************************************
  Ad_Part_Ok :  Check AUDIT_DETAILS
***********************************************************
-- Checks there are no documents in AUDIT_DETAILS
   still related to the XML_DOCUMENT partition.
-- If not; print total document to allow the DBA to decide 
   on whether to purge or migrate rows.
*********************************************************** 
*/

FUNCTION Ad_Part_Ok 
(doc_part_name in varchar2) 
return BOOLEAN 
IS

AD_SUCCESS        BOOLEAN := TRUE; 
ad_total_count    NUMBER;
stmt              VARCHAR2(2000);

BEGIN 

UTL_FILE.Put_Line (PART_HANDLE, 'CHECKING AUDIT_DETAILS TABLE ');

stmt := 'SELECT count(*) '
       || ' FROM XML_DOCUMENT PARTITION(PARTNAME) X '
       || ' WHERE EXISTS '
       || ' (SELECT 1 FROM AUDIT_DETAILS R '
       || '  WHERE R.doc_ref = X.dockey) ';
stmt := REPLACE(stmt,'PARTNAME',doc_part_name);
dbms_output.put_line('stmt : ' || stmt);
EXECUTE IMMEDIATE stmt INTO ad_total_count;

IF ad_total_count > 0
THEN
  AD_SUCCESS := FALSE;
  UTL_FILE.Putf     (PART_HANDLE, '** FAIL - TOTAL DOCUMENTS STILL ACTIVE    : %s \n', ad_total_count);
ELSE
  UTL_FILE.Put_Line (PART_HANDLE, '** PASS - NO DOCUMENTS ARE STILL ACTIVE ');
END IF;
UTL_FILE.Put_Line   (PART_HANDLE, '----------------------------------------------------');

RETURN AD_SUCCESS;
END Ad_Part_Ok;


/* 
***********************************************************
  Exec_Verify : Execute
***********************************************************
-- Loop through the collection of XML_DOCUMENT partitions.
***********************************************************
*/
PROCEDURE Exec_Verify 
(doc_drv_list in doc_drv_table) 
IS

BEGIN

FOR i in doc_drv_list.FIRST..doc_drv_list.LAST LOOP

PART_FILE_NAME := UPPER('DC_'||doc_drv_list(i));
PART_HANDLE := UTL_FILE.fopen(PART_DIR_NAME, PART_FILE_NAME, 'W');

IF (Dl_Ref_Part_Ok(UPPER(doc_drv_list(i))))
THEN
  IF (Dlv_Part_Ok(UPPER(doc_drv_list(i))))
  THEN
    IF (Ivk_Part_Ok(UPPER(doc_drv_list(i))))
    THEN
      IF (Ci_Ref_Part_Ok(UPPER(doc_drv_list(i))))
      THEN
        IF (Ad_Part_Ok(UPPER(doc_drv_list(i))))
        THEN
          UTL_FILE.Put_Line (PART_HANDLE,'PASS: ALL DOCUMENTS ARE UNREFERENCED THUS THE');
          UTL_FILE.Put_line (PART_HANDLE,'        XML_DOCUMENT PARTITION CAN BE DROPPED'); 
        ELSE
          UTL_FILE.Put_Line (PART_HANDLE,'FAIL: AUDIT_DETAILS TABLE HAS ACTIVE DOCUMENTS'); 
          UTL_FILE.Put_Line (PART_HANDLE,'         THUS THE XML_DOCUMENT PARTITON CANNOT BE DROPPED'); 
        END IF;
      ELSE
        UTL_FILE.Put_Line (PART_HANDLE,'FAIL: DOCUMENT_CI_REF TABLE HAS ACTIVE DOCUMENTS'); 
        UTL_FILE.Put_Line (PART_HANDLE,'         THUS THE XML_DOCUMENT PARTITON CANNOT BE DROPPED'); 
      END IF;
    ELSE
      UTL_FILE.Put_Line (PART_HANDLE,'FAIL: INVOKE_MESSAGE TABLE HAS ACTIVE DOCUMENTS'); 
      UTL_FILE.Put_Line (PART_HANDLE,'         THUS THE XML_DOCUMENT PARTITON CANNOT BE DROPPED'); 
    END IF;
  ELSE
    UTL_FILE.Put_Line (PART_HANDLE,'FAIL: DLV_MESSAGE TABLE HAS ACTIVE DOCUMENTS'); 
    UTL_FILE.Put_Line (PART_HANDLE,'         THUS THE XML_DOCUMENT PARTITON CANNOT BE DROPPED'); 
  END IF;
ELSE
  UTL_FILE.Put_Line (PART_HANDLE,'FAIL: DOCUMENT_DLV_MSG_REF TABLE HAS ACTIVE DOCUMENTS'); 
  UTL_FILE.Put_Line (PART_HANDLE,'         THUS THE XML_DOCUMENT PARTITON CANNOT BE DROPPED'); 
END IF;


UTL_FILE.Put_Line (PART_HANDLE,'------------END OF REPORT---------------------------');
UTL_FILE.fclose(PART_HANDLE);

END LOOP;

END Exec_Verify;

END VERIFY_DOC;

/
SHOW ERRORS
