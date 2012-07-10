Rem
Rem $Header: 
Rem
Rem CI_EXEC_VERIFY.sql for 10G SOA.
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem     CI_EXEC_VERIFY.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbousamr     06/20/09 - Created
Rem
Rem
Rem ==========================================================
Rem 
Rem Description
Rem -----------
Rem This procedure executes the CUBE_INSTANCE verify package.
Rem (Written for SOA 10G.)
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
Rem
Rem SETUP
Rem -----
Rem  The partition directory will contain a file which reports the pass of failure 
Rem      of each enter partition.
Rem  sqlplus> connect <bpel schema owner>/<password>
Rem  sqlplus> create directory PART_DIR as '/.......';
Rem
Rem  Create the CUBE_INSTANCE verify package.
Rem  sqlplus> connect <bpel schema owner>/<password>
Rem  sqlplus> @CI_VERIFY.sql
Rem
Rem  EXECUTION
Rem  ---------
Rem   Two collections are passed to the CI_VERIFY package:
Rem  1. Collection of CUBE_INSTANCE partitions that need to be verified.
Rem  2. Collection of CUBE_INSTANCE dependent tables that have been partitioned
Rem       and need to be dropped along with the CUBE_INSTANCE partition.
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

myChk_tree       BOOLEAN;
myCube_drv_list  verify_cube.cube_drv_table; 
myCube_dep_list  verify_cube.cube_dep_table;


BEGIN

/*
To check that the entire Parent and Child Tree has 
completed for all instances in the cube_instance 
partitions set to TRUE.
Checking Parent and Child trees requires queries 
outside the partition and thus are much more 
expensive to execute.
*/
myChk_tree := FALSE;


/*
Collection of CUBE_INSTANCE partitions.
Ensure to set EXTEND number correctly.
*/
myCube_drv_list   := verify_cube.cube_drv_table();
 myCube_drv_list.extend(4);
 myCube_drv_list(1) := 'P01_2009';
 myCube_drv_list(2) := 'P02_2009';
 myCube_drv_list(3) := 'P03_2009';
 myCube_drv_list(4) := 'P04_2009';


/*
Collection of CUBE_INSTANCE dependent tables
that have been equi-partitioned.
- THE DOCUMENT_CI_REF table is mandatory.
- Ensure to set EXTEND number correctly
*/
myCube_dep_list   := verify_cube.cube_dep_table();
 myCube_dep_list.extend(11);
 myCube_dep_list(1)  := 'ATTACHMENT';
 myCube_dep_list(2)  := 'ATTACHMENT_REF';
 myCube_dep_list(3)  := 'AUDIT_DETAILS';
 myCube_dep_list(4)  := 'AUDIT_TRAIL';
 myCube_dep_list(5)  := 'CI_INDEXES';
 myCube_dep_list(6)  := 'CUBE_SCOPE';
 myCube_dep_list(7)  := 'DLV_SUBSCRIPTION';
 myCube_dep_list(8)  := 'DOCUMENT_CI_REF';
 myCube_dep_list(9)  := 'WI_EXCEPTION';
 myCube_dep_list(10) := 'WI_FAULT';
 myCube_dep_list(11) := 'WORK_ITEM';

/*
Execute the CUBE_INSTANCE verification package.
*/
verify_cube.exec_verify(myChk_tree,myCube_drv_list,myCube_dep_list);


END;

/
SHOW ERRORS
