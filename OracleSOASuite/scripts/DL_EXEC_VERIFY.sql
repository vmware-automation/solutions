Rem
Rem $Header: 
Rem
Rem DL_EXEC_VERIFY.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem     DL_EXEC_VERIFY.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbousamr     06/20/09 - Created
Rem
Rem
Rem ==========================================================
Rem 
Rem Description
Rem -----------
Rem This procedure will execute a package which verifies a given DLV_MESSAGE partition.
Rem 
Rem Each DLV_MESSAGE partition will be verified to check that:
Rem 1. All DLV_MESSAGES are closed 
Rem      and ALL INVOKE_MESSAGES with same partition name are handled.
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

myDlv_drv_list  verify_dlv.dlv_drv_table; 
myDlv_dep_list  verify_dlv.dlv_dep_table;


BEGIN

/*
Collection of DLV_MESSAGE partitions.
Ensure to set EXTEND number correctly.
*/
myDlv_drv_list   := verify_dlv.dlv_drv_table();
 myDlv_drv_list.extend(4);
 myDlv_drv_list(1) := 'P01_2009';
 myDlv_drv_list(2) := 'P02_2009';
 myDlv_drv_list(3) := 'P03_2009';
 myDlv_drv_list(4) := 'P04_2009';


/*
Collection of DLV_MESSAGE dependent tables
that have been equi-partitioned.
 - For this release the DOCUMENT_DLV_MSG_REF and INVOKE_MESSAGE tables are mandatory.
 - Ensure to set EXTEND number correctly
*/
myDlv_dep_list   := verify_dlv.dlv_dep_table();
 myDlv_dep_list.extend(2);
 myDlv_dep_list(1)  := 'INVOKE_MESSAGE';
 myDlv_dep_list(2)  := 'DOCUMENT_DLV_MSG_REF';


/*
Execute the DLV_MESSAGE verification package.
*/
verify_dlv.exec_verify(myDlv_drv_list,myDlv_dep_list);


END;

/
SHOW ERRORS
