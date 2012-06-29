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


DECLARE

myDoc_drv_list  verify_doc.doc_drv_table; 

BEGIN

/*
Collection of XML_DOCUMENT partitions.
Ensure to set EXTEND number correctly.
*/
myDoc_drv_list   := verify_doc.doc_drv_table();
 myDoc_drv_list.extend(4);
 myDoc_drv_list(1) := 'P01_2009';
 myDoc_drv_list(2) := 'P02_2009';
 myDoc_drv_list(3) := 'P03_2009';
 myDoc_drv_list(4) := 'P04_2009';



/*
Execute the XML_DOCUMENT verification package.
*/
verify_doc.exec_verify(myDoc_drv_list);


END;

/
SHOW ERRORS
