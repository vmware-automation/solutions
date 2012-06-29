
--
-- CONFIDENTIAL AND PROPRIETARY SOURCE CODE OF COLLAXA CORPORATION
-- Copyright (c) 2002 Collaxa Corporation. All Rights Reserved.
--
-- Use of this Source Code is subject to the terms of the applicable
-- license agreement from Collaxa Corporation.
--
-- The copyright notice(s) in this Source Code does not indicate
-- actual or intended publication of this Source Code.
--

--
-- Collaxa drop procedure script for DB2
--
-- In the event that have happened to modify the stored procedure java
-- classes for the Collaxa schema, you will need to refresh the currently
-- cached java classes stored by the DB2 classloader.
--
-- (For the instructions here we will assume DB2 is installed in c:/ibm)
--
-- <copy new cx_db2.jar to c:/ibm/sqllib/function>
-- db2cmd
-- db2 connect to <db_name> user <db_user>
-- db2 -td@ -vf db2_drop_procs.ddl
-- db2 call sqlj.replace_jar( 'file:c:/ibm/sqllib/function/cx_db2.jar', 'cx_db2' )
-- db2 call sqlj.refresh_classes( void )
--
-- Before installing the database schema, please ensure that the user
-- has the necessary permissions.
--

drop procedure cx_insert_sa@
drop procedure cx_insert_wx@
drop procedure cx_mark_as_stale@
drop procedure cx_delete_ci@
drop procedure cx_delete_cis@
drop procedure cx_delete_cis_by_pcs_id@

