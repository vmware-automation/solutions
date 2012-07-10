Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/multi_threaded_looped_purge.sql /st_pcbpel_10.1.3.1/1 2010/05/04 19:02:08 ramisra Exp $
Rem
Rem multi_threaded_looped_purge.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      multi_threaded_looped_purge.sql 
Rem
Rem    DESCRIPTION
Rem      This script creates procedure for purging BPEL dehydration store data in parallel
Rem      thru multiple jobs
Rem
Rem    NOTES
Rem      This Script/Procedure MUST only be run by a DBA who is familiar with ORABPEL schema
Rem 
Rem      Since parallel purge job uses lots of hardware resources, it should only be run
Rem      on high end box with multiple CPUs. 
Rem  
Rem      1) The parameter passed to the purge procedure should be tuned on individual environment.
Rem         For example how many jobs to spawn for purge in parallel should be configured 
Rem         depending on hardware resources available and number of rows to delete should be configured 
Rem         in such as way that purge does not exceed the maintenance window.
Rem
Rem      2) Following Privileges needs to be granted to user running this script
Rem 
Rem         A) CREATE ANY JOB
Rem         B) EXECUTE ON DBMS_LOCK 
Rem
Rem      3) To enable 10046 tracing for the purge threads please recompile the package as below
Rem
Rem         Note: For running below, user must have ALTER ANY PROCEDURE system privilege and to enable
Rem               10046 tracing user must have ALTER SESSION privilege
Rem 
Rem         ALTER PACKAGE MULTI_THREADED_LOOPED_PURGE COMPILE PLSQL_CCFLAGS = 'tracing_on:TRUE' REUSE SETTINGS;
Rem
Rem         To again disable 10046 tracing, run above command with PLSQL_CCFLAGS = 'tracing_on:FALSE'
Rem
Rem      4) After purge completes, you could check in table purge_exception_log for any errors.  This table has thread number and 
Rem         associated error message.
Rem
Rem      5) Please note that procedure purge_instances_loop_jobs spawns purge jobs (threads) in background so when procedure 
Rem         purge_instances_loop_jobs returns it does not mean purge has ended.  To confirm if purge has completed or not
Rem         you need to look at job_flow_control table and if any entry is present, it means some purge thread is still running.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem
Rem    ramisra     04/28/10 - Adding temp_xml_document table for faster delete from xml_document table
Rem
Rem    ramisra     04/14/10 - Removal of temp_message table, as now everything is driven from cube_instance
Rem                           table, this means we only select callbacks which is related with closed instance
Rem                           and thus we do not need temp_message table to check this.
Rem    ramisra     04/14/10 - Using cikey for mod even for dlv_message and invoke_message deletes as 
Rem                           hashing message_guid is more expensive. All delivered dlv_message and invoke_message
Rem                           have their associated cikey which is simple INTEGER and mod of it is easy.
Rem    ramisra     04/13/10 - This script creates procedure for running
Rem                           multithreaded version of purge. This is based on
Rem                           Helmuts script running at customer Deutsche Telecom site.
Rem    ramisra     04/13/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE PACKAGE MULTI_THREADED_LOOPED_PURGE
IS

PROCEDURE purge_instances_loop_jobs (p_older_than TIMESTAMP, p_rownum NUMBER, p_DOP NUMBER, p_chunksize NUMBER); 

PROCEDURE purge_tables_job (p_DOP NUMBER, p_THREAD NUMBER, p_ROWS NUMBER, p_CHUNKS NUMBER);

END MULTI_THREADED_LOOPED_PURGE;
/

--First drop temp table before proceeding with creation
DROP TABLE temp_cube_instance;
DROP TABLE temp_invoke_message;
DROP TABLE temp_dlv_message;
DROP TABLE temp_wf_instance;
DROP TABLE temp_xml_document;
DROP TABLE job_flow_control;
DROP TABLE purge_exception_log;

-- Create temporary tables.
--
CREATE TABLE temp_cube_instance
(
   cikey           INTEGER NOT NULL,
   conversation_id VARCHAR2(256)
);

CREATE TABLE temp_invoke_message
(
   message_guid      VARCHAR2(50),
   headers_ref_id      VARCHAR2(100),
   cikey           INTEGER NOT NULL
);

CREATE TABLE temp_dlv_message
(
   message_guid      VARCHAR2(50),
   headers_ref_id      VARCHAR2(100),
   cikey           INTEGER NOT NULL
);

CREATE TABLE temp_xml_document
(
   cikey  INTEGER NOT NULL,
   dockey VARCHAR2(200) 
);

-- Human workflow table containing taskid's corresponding to instance id's in bpel tables.
CREATE TABLE temp_wf_instance 
( 
   wftask VARCHAR(64),
   constraint t_wf_pk primary key(wftask)   
);

CREATE TABLE job_flow_control
(
   job_thread NUMBER
);

CREATE TABLE purge_exception_log
(
   job_thread VARCHAR2(20),
   exception_time timestamp,
   exception_message VARCHAR2(500)
);

CREATE OR REPLACE PACKAGE BODY MULTI_THREADED_LOOPED_PURGE
IS

/*
 * Below procedure is a wrapper procedure which will spawn jobs for
 * purging BPEL dehydration store data in parallel. 
 *
 * Requirement :
 *    Privileges : System Privilege CREATE ANY JOB, Execute Privilege on DBMS_LOCK
 *    
 * Description of parameters:
 *
 * p_older_than    Retention period, for example 'sysdate - 21' 
 * p_rownum        Total number of rows to be deleted during purge window, for example : 1000000
 * p_DOP           Number of parallel jobs to spawn for delete, ideally a prime number such as 7
 * p_chunksize     Number of Rows after which a COMMIT will be issued. For example 1000
 *
 */
PROCEDURE purge_instances_loop_jobs (
  p_older_than TIMESTAMP,
  p_rownum NUMBER,
  p_DOP NUMBER,
  p_chunksize NUMBER)
AS
  v_code NUMBER;
  v_errm VARCHAR2(150);
  v_stmt VARCHAR2(200);
  v_errorMessage VARCHAR2(500);
  v_sqlstmt varchar2(2000);
  v_thread number := 0;
  v_jobname VARCHAR2(20);
  v_jobsrunning number;
  bCond number;
BEGIN

$IF $$tracing_on $THEN
    v_stmt := 'Setting 10046 trace in MAIN THREAD';
    execute immediate 'alter session set events ''10046 trace name context forever, level 8'''; 
$ELSE
    null;
$END

v_stmt := 'Start of purge';

--check whether any job is running or whether they shut down properly
SELECT count(*) INTO v_jobsrunning FROM job_flow_control;
-- if not, raise an error and let the exception handling take care of it
IF v_jobsrunning != 0
THEN
   raise_application_error (-20001,'Jobs still running or not shut down properly');
END IF;

v_stmt := 'Cleanup temp tables';
--before starting clean up temp tables
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_cube_instance';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_invoke_message';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_dlv_message';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_wf_instance';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_xml_document';
EXECUTE IMMEDIATE 'TRUNCATE TABLE job_flow_control';
EXECUTE IMMEDIATE 'TRUNCATE TABLE purge_exception_log';

-- Populate table with information about older instances
v_stmt := 'Insert into temp_cube_instance';
INSERT into temp_cube_instance
      SELECT cikey, conversation_id
        FROM cube_instance
       WHERE state >= 5 AND modify_date < p_older_than
         AND rownum <= p_rownum;
COMMIT;
   
v_stmt := 'Insert into temp_invoke_message';
-- RAMISRA : There is no need to use rownum as we are driving from temp_cube_instance which has already been
-- limited by rownum clause
INSERT into temp_invoke_message 
             SELECT /*+ ORDERED full(im) parallel(im,4) */ im.message_guid , im.headers_ref_id, tci.cikey
             FROM  temp_cube_instance tci, invoke_message im
             WHERE  tci.conversation_id=im.conv_id AND im.state > 1;
COMMIT;

v_stmt := 'Insert into temp_dlv_message';
INSERT into temp_dlv_message
             SELECT /*+  ORDERED full(dm) parallel(dm,4) */ message_guid , headers_ref_id, tci.cikey 
             FROM   temp_cube_instance tci, dlv_subscription ds, dlv_message dm
             WHERE  tci.cikey=ds.cikey and ds.subscriber_id=dm.res_subscriber and dm.state > 1;
COMMIT;

v_stmt := 'Insert into temp_xml_document where dockey in documen_ci_ref'; 

INSERT INTO temp_xml_document
           SELECT /*+ ORDERED use_nl(tpic,doc_ref) */ tpic.cikey, doc_ref.dockey
           FROM temp_cube_instance tpic, document_ci_ref doc_ref
           WHERE doc_ref.cikey =  tpic.cikey;

COMMIT;

v_stmt := 'Insert into temp_xml_document where dockey in document_dlv_msg_ref thru invoke_message'; 

INSERT INTO temp_xml_document
        SELECT /*+ ORDERED use_nl(tpiim,dlv_ref) */ tpiim.cikey, dlv_ref.dockey
        FROM temp_invoke_message tpiim, document_dlv_msg_ref dlv_ref
        WHERE dlv_ref.message_guid =  tpiim.message_guid;

COMMIT;

v_stmt := 'Insert into temp_xml_document where dockey in document_dlv_msg_ref thru dlv_message'; 

INSERT INTO temp_xml_document
        SELECT /*+ ORDERED use_nl(tpdlv,dlv_ref) */ tpdlv.cikey, dlv_ref.dockey
        FROM temp_dlv_message tpdlv, document_dlv_msg_ref dlv_ref
        WHERE dlv_ref.message_guid =  tpdlv.message_guid;

COMMIT;

v_stmt := 'Insert into temp_xml_document referenced by header_ref_id of temp_invoke_message';

--NULL check has been put to keep temp_xml_document small as lots of message will have NULL header_ref_id which we
--do not want to insert into temp_xml_document table
INSERT INTO temp_xml_document SELECT cikey, headers_ref_id from temp_invoke_message where headers_ref_id IS NOT NULL;

COMMIT;

v_stmt := 'Insert into temp_xml_document referenced by header_ref_id of temp_dlv_message';

INSERT INTO temp_xml_document SELECT cikey, headers_ref_id from temp_dlv_message where headers_ref_id IS NOT NULL;

COMMIT;

v_stmt := 'Deleting duplicate rows from temp_xml_document table';   
--Now delete duplicate dockey from temp_xml_document table.
DELETE FROM temp_xml_document txd1 WHERE txd1.rowid > ANY (SELECT txd2.rowid FROM temp_xml_document txd2 WHERE txd1.dockey = txd2.dockey);

COMMIT;

v_stmt := 'Insert into temp_wf_instance';   
-- Fill temp WF table with taskid's corresponding to bpel instance id's.
INSERT into temp_wf_instance
      SELECT t.taskid
        FROM WFTask t, temp_cube_instance tpic
      WHERE  t.instanceid = tpic.cikey ;
COMMIT;

v_stmt := 'Delete from process_log';
   DELETE FROM process_log
                 WHERE event_date < p_older_than;

v_stmt := 'Inner Loop to launch Jobs';

LOOP
-- exit loop when DOP jobs have been started
   EXIT WHEN p_DOP=v_thread;

   v_jobname := 'ORABPEL_DELETE'||v_thread;
   INSERT INTO job_flow_control (job_thread) values (v_thread);
   COMMIT;

   dbms_scheduler.create_job (v_jobname, 'STORED_PROCEDURE', 'MULTI_THREADED_LOOPED_PURGE.PURGE_TABLES_JOB', 4);

   dbms_scheduler.set_job_argument_value (v_jobname,1,to_char(p_DOP));
   dbms_scheduler.set_job_argument_value (v_jobname,2,to_char(v_thread));
   dbms_scheduler.set_job_argument_value (v_jobname,3,to_char(p_rownum));
   dbms_scheduler.set_job_argument_value (v_jobname,4,to_char(p_chunksize));
   dbms_scheduler.enable (v_jobname);
   v_thread := v_thread +1;

END LOOP;

-- here come the DELETEs that cannot parallelized in the Job

v_stmt := 'Delete from native_correlation';   

DELETE FROM native_correlation nc
   WHERE NOT EXISTS (
      SELECT dlvs.conv_id
      FROM dlv_subscription dlvs
      WHERE dlvs.conv_id = nc.conversation_id);

COMMIT;
 
-- Workflow Tables
v_stmt := 'Delete from WFAssignee';
DELETE FROM WFAssignee wft
        WHERE wft.taskid IN  (SELECT twi.wftask FROM temp_wf_instance twi);
COMMIT;
v_stmt := 'Delete from WFAttachment';
DELETE FROM WFAttachment wft
        WHERE wft.taskid IN  (SELECT twi.wftask FROM temp_wf_instance twi);

COMMIT;

v_stmt := 'Delete from WFComments';
DELETE FROM WFComments wft
        WHERE wft.taskid IN  (SELECT twi.wftask FROM temp_wf_instance twi);
COMMIT;

v_stmt := 'Delete from WFMessageAttribute';
DELETE FROM WFMessageAttribute wft
        WHERE wft.taskid IN  (SELECT twi.wftask FROM temp_wf_instance twi);

COMMIT;

v_stmt := 'Delete from WFRoutingslip';
DELETE FROM WFRoutingSlip wft
       WHERE wft.taskid IN  (SELECT twi.wftask FROM  temp_wf_instance twi);

COMMIT;

v_stmt := 'Delete from WFTaskHistory';
DELETE FROM WFTaskHistory wft
      WHERE wft.taskid IN  (SELECT twi.wftask FROM temp_wf_instance twi);

COMMIT;

v_stmt := 'Delete from WFTasktimer';
DELETE FROM WFTaskTimer wft
      WHERE wft.taskid IN  (SELECT twi.wftask FROM  temp_wf_instance twi);

COMMIT;

v_stmt := 'Delete from WFTask';
/* Lastly delete from WFTask table ...*/
DELETE FROM WFTask wft
      WHERE wft.taskid IN  (SELECT twi.wftask FROM temp_wf_instance twi);
COMMIT;

v_stmt := 'Delete from process_log';
DELETE FROM process_log
                 WHERE event_date < p_older_than;

EXCEPTION
  when others then 
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 150);
    v_errorMessage := 'Error code v_code : v_errm , Error Location =  v_stmt';
    v_errorMessage := REPLACE(v_errorMessage,'v_code',v_code);
    v_errorMessage := REPLACE(v_errorMessage,'v_errm',v_errm);
    v_errorMessage := REPLACE(v_errorMessage,'v_stmt',v_stmt);

    -- insert error into table so that it could be analyzed after all jobs finishes
    INSERT INTO purge_exception_log values ('MAIN_THREAD', sysdate, v_errorMessage );
    COMMIT;
   
END purge_instances_loop_jobs;

/* Requirements:
 * System Privilege CREATE ANY JOB
 * Execute Privilege on DBMS_LOCK
 *
 * Description of parameters:
 * p_DOP        Total Number of Jobs
 * p_THREAD     Number of THIS job (First Job has number 0)
 * p_ROWS       Number of Rows of TEMP tables
 * p_CHUNKS     Number of Rows after that a COMMIT will be issued.
 *
*/

PROCEDURE purge_tables_job (p_DOP number, p_THREAD number, p_ROWS number, p_CHUNKS number) 
AS
  v_code NUMBER;
  v_errm VARCHAR2(150);
  v_stmt VARCHAR2(200);
  v_sqlstmt varchar2(2000);
  v_errorMessage VARCHAR2(500);
  v_sleeptime number;
  v_deleted boolean:=true;
  f1_flag boolean:=true;
  f2_flag boolean:=true;
  f3_flag boolean:=true;
  f4_flag boolean:=true;
  f5_flag boolean:=true;
  f6_flag boolean:=true;
  f7_flag boolean:=true;
  f8_flag boolean:=true;
  f9_flag boolean:=true;
  f10_flag boolean:=true;
  f11_flag boolean:=true;
  f12_flag boolean:=true;
  f13_flag boolean:=true;
  f14_flag boolean:=true;
  f15_flag boolean:=true;
  f16_flag boolean:=true;
  f17_flag boolean:=true;
  f18_flag boolean:=true;
  f19_flag boolean:=true;
  f20_flag boolean:=true;
  f21_flag boolean:=true;
BEGIN

$IF $$tracing_on $THEN
    v_stmt := 'Setting 10046 trace';
    execute immediate 'alter session set events ''10046 trace name context forever, level 8'''; 
$ELSE
    null;
$END

-- to avoid starting all jobs at the same time causing concurrency issues we put a sleep here into 
v_stmt := 'Sleep at start of job';

v_sleeptime := 10*p_THREAD;
dbms_lock.sleep(v_sleeptime);

WHILE v_deleted LOOP -- this loop is for keeping transactions short

   v_deleted := false;

   v_stmt := 'Delete from audit_details'; 

   IF f1_flag THEN
     f1_flag:=false;
     DELETE FROM audit_details
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
     IF SQL%FOUND THEN
        f1_flag:=true;
        v_deleted := true;
     END IF;
   END IF;
   
   COMMIT;

   v_stmt := 'Delete from cube_scope'; 

   IF f2_flag THEN
     f2_flag:=false;
     DELETE FROM cube_scope
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;  
     IF SQL%FOUND THEN
        f2_flag:=true;
        v_deleted := true;
     END IF;
   END IF;
 
   COMMIT;

   v_stmt := 'Delete from work_item'; 
  
   IF f3_flag THEN
     f3_flag:=false;
     DELETE FROM work_item
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)   
        AND rownum < p_CHUNKS;
     IF SQL%FOUND THEN
        f3_flag := true;
        v_deleted := true;
     END IF;
   END IF;
 
   COMMIT;

   v_stmt := 'Delete from wi_exception'; 

   IF f4_flag THEN
     f4_flag:=false;
     DELETE FROM wi_exception
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f4_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;
 
   v_stmt := 'Delete from scope_activation'; 

   IF f5_flag THEN
     f5_flag:=false;
     DELETE FROM scope_activation
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)   
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f5_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;
 
   v_stmt := 'Delete from dlv_subscription'; 

   IF f6_flag THEN
     f6_flag:=false;
     DELETE FROM dlv_subscription
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)   
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f6_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from audit_trail'; 

   IF f7_flag THEN
     f7_flag:=false;
     DELETE FROM audit_trail
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f7_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from sync_trail'; 

   IF f8_flag THEN
     f8_flag:=false;
     DELETE FROM sync_trail
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f8_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from sync_store'; 

   IF f9_flag THEN
     f9_flag:=false;
     DELETE FROM sync_store
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f9_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from attachment'; 

   IF f10_flag THEN
     f10_flag:=false;
     DELETE FROM attachment
        WHERE key IN (
        SELECT /*+ ORDERED */ attach_ref.key 
        FROM temp_cube_instance tpic, attachment_ref attach_ref
        WHERE attach_ref.cikey = tpic.cikey
           AND mod(tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f10_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;
   v_stmt := 'Delete from attachment_ref'; 

   IF f11_flag THEN
     f11_flag:=false;
     DELETE FROM attachment_ref
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)   
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f11_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from ci_indexes'; 

   IF f12_flag THEN
     f12_flag:=false;
     DELETE FROM ci_indexes
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f12_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;


   v_stmt := 'Delete from wi_fault'; 

   IF f13_flag THEN
     f13_flag:=false;
     DELETE FROM wi_fault
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f13_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;


   v_stmt := 'Delete from document_ci_ref'; 

   IF f14_flag THEN
     f14_flag:=false;
     DELETE FROM document_ci_ref
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f14_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from native_correlation';

   IF f15_flag THEN
     f15_flag:=false;
     DELETE FROM native_correlation
        WHERE conversation_id IN (
           SELECT /*+ ORDERED */ dlvs.conv_id 
           FROM temp_cube_instance tpic, dlv_subscription dlvs
           WHERE dlvs.cikey = tpic.cikey
           AND mod(tpic.cikey, p_DOP)=p_THREAD)
        AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f15_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from cube_instance'; 

   IF f16_flag THEN
     f16_flag:=false;
     DELETE FROM cube_instance
        WHERE cikey IN (
           SELECT tpic.cikey
           FROM temp_cube_instance tpic
           WHERE mod (tpic.cikey, p_DOP)=p_THREAD)
       AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f16_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;


   v_stmt := 'Delete from document_dlv_msg_ref where invoke_message related with closed instance'; 

   IF f17_flag THEN
     f17_flag:=false;
     DELETE FROM document_dlv_msg_ref
     WHERE message_guid IN (
        SELECT tpiim.message_guid FROM temp_invoke_message tpiim
        WHERE mod (tpiim.cikey, p_DOP)=p_THREAD)
     AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f17_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from invoke_message where invoke_message related with closed instances';

   IF f18_flag THEN
     f18_flag:=false;
     DELETE FROM invoke_message
     WHERE message_guid IN (
        SELECT tpiim.message_guid FROM temp_invoke_message tpiim
        WHERE mod (tpiim.cikey, p_DOP)=p_THREAD)
     AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f18_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete from document_dlv_msg_ref which is linked with dlv_message of closed instances';

   IF f19_flag THEN
     f19_flag:=false;
     DELETE FROM document_dlv_msg_ref
     WHERE message_guid IN (
        SELECT tpidm.message_guid FROM temp_dlv_message tpidm
        WHERE mod (tpidm.cikey, p_DOP)=p_THREAD)
     AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f19_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete rows from dlv_message of closed instances';

   IF f20_flag THEN
     f20_flag:=false;
     DELETE FROM dlv_message
     WHERE message_guid IN (
        SELECT tpidm.message_guid FROM  temp_dlv_message tpidm
        WHERE mod (tpidm.cikey, p_DOP)=p_THREAD)
     AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f20_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

   v_stmt := 'Delete rows from xml_document';

   IF f21_flag THEN
     f21_flag:=false;
     DELETE FROM xml_document xd
     WHERE xd.dockey IN (
        SELECT txd.dockey FROM  temp_xml_document txd
        WHERE mod (txd.cikey, p_DOP)=p_THREAD)
     AND rownum < p_CHUNKS;
 
     IF SQL%FOUND THEN
        f21_flag := true;
        v_deleted := true;
     END IF;
   END IF;

   COMMIT;

END LOOP;

v_stmt := 'Loop End Control';

-- delete flag from job_flow_control table 

DELETE FROM job_flow_control WHERE job_thread = p_THREAD;

COMMIT;

EXCEPTION
  when others then 
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 150);

    v_errorMessage := 'Error code v_code : v_errm , Error Location =  v_stmt';
    v_errorMessage := REPLACE(v_errorMessage,'v_code',v_code);
    v_errorMessage := REPLACE(v_errorMessage,'v_errm',v_errm);
    v_errorMessage := REPLACE(v_errorMessage,'v_stmt',v_stmt);

    -- insert error into table so that it could be analyzed later
    INSERT INTO purge_exception_log values (p_THREAD, sysdate, v_errorMessage );

    DELETE FROM job_flow_control WHERE job_thread = p_THREAD;

    COMMIT;
   
END purge_tables_job;

END MULTI_THREADED_LOOPED_PURGE;
/
SHOW ERRORS;

--USER could create below kind of procedure to invoke purge which runs in parallel
/*
DECLARE
  P_OLDER_THAN TIMESTAMP;
  P_ROWNUM NUMBER;
  P_DOP NUMBER;
  P_CHUNKSIZE NUMBER;
BEGIN
  P_OLDER_THAN := NULL; -- Retention period for example sysdate-21
  P_ROWNUM := NULL;     -- Max number of rows to be deleted in this run
  P_DOP := NULL;        -- Degree of Parallelism
  P_CHUNKSIZE := NULL;  -- Number of rows to be deleted in one loop

  MULTI_THREADED_LOOPED_PURGE.PURGE_INSTANCES_LOOP_JOBS(
    P_OLDER_THAN => sysdate-21, 
    P_ROWNUM => 1000000,
    P_DOP => 7, -- Preferably Some prime number
    P_CHUNKSIZE => 1000
  );
END;
/
*/
