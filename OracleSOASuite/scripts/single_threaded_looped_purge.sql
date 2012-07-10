Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/single_threaded_looped_purge.sql /st_pcbpel_10.1.3.1/2 2010/06/23 11:48:07 ramisra Exp $
Rem
Rem single_threaded_looped_purge.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      single_threaded_looped_purge.sql 
Rem
Rem    DESCRIPTION
Rem      This script defines a procedure which can be used to purge BPEL dehydration store data in loop (batches of instances)
Rem      Use of loop or batching of delete keeps transaction size to reasonable limit and also allow us to exit the purge
Rem      after a pre defined time.
Rem
Rem    NOTES
Rem      This script should only be run by DBA who is familiar with BPEL schema.
Rem
Rem      This Procedure is suitable for small/medium size dehydration store.
Rem
Rem      Running this procedure on large dehydration store may suffer from performance issues.
Rem      For large installations, please consider use of Partitioning OR CTAS OR Multi threaded purge approach
Rem 
Rem      For partitioning approach, please refer partitioning white paper 
Rem             http://www.oracle.com/technology/products/soa/bpel/collateral/BPEL10gPartitioning.pdf
Rem 
Rem      For CTAS approach, please refer bug 9315108 
Rem
Rem      For Multi threaded purge approach, please refer bug 9219019
Rem 
Rem      USAGE :
Rem          Sample run: call SINGLE_THREADED_LOOPED_PURGE.purge_instances_loop(sysdate - 30, 20000, 180);
Rem
Rem          Above will delete instances older than 30 days in batch size of 20000 and will run 
Rem          for max 3 hours (180 mins)
Rem 
Rem          Note : The purge time will most likely exceed 3 hours because the check to exit from loop is performed
Rem                 at the start of each loop, so if 3 hours expires when purge is still in middle of purge loop
Rem                 we do not exit immediately but during next loop when purge starts, we exit. Purpose of
Rem                 3rd parameter (p_stop_time) is only to stop purging after some approximate time.
Rem
Rem      HOW TO ENABLE TRACING :
Rem          For enabling 10046 event tracing, 
Rem          Please compile package as below before running the procedure purge_instances_loop
Rem
Rem          Note : User must have ALTER ANY PROCEDURE and ALTER SESSION privileges
Rem
Rem          ALTER PACKAGE SINGLE_THREADED_LOOPED_PURGE COMPILE PLSQL_CCFLAGS = 'tracing_on:TRUE' REUSE SETTINGS;
Rem
Rem          To disable tracing again, please recompile package with PLSQL_CCFLAGS = 'tracing_on:FALSE'
Rem
Rem      HOW TO ENABLE DEBUG LOGGING: 
Rem          To Enable debug logs to see how many rows are getting deleted from each table in each iteration, 
Rem          Please compile package as below before running the procedure purge_instances_loop 
Rem          (debug_on:TRUE will turn on the logging)
Rem 
Rem          Note : For running below, user must have ALTER ANY PROCEDURE system privilege
Rem
Rem          ALTER PACKAGE SINGLE_THREADED_LOOPED_PURGE COMPILE PLSQL_CCFLAGS = 'debug_on:TRUE' REUSE SETTINGS;
Rem
Rem          Also run "SET SERVEROUTPUT ON" on session before calling purge_instances_loop procedure.
Rem
Rem          To disable logging again, please recompile it with PLSQL_CCFLAGS = 'debug_on:FALSE'
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     06/23/10 - Backport ramisra_bug-9845104 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     04/19/10 - Adding debug information
Rem    ramisra     04/15/10 - This script will create a purge procedure which
Rem                           will delete data in loop
Rem    ramisra     04/15/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE PACKAGE SINGLE_THREADED_LOOPED_PURGE
IS

PROCEDURE purge_instances_loop (p_older_than TIMESTAMP, p_chunksize NUMBER, p_stop_time INTEGER default NULL);

PROCEDURE debug_purge (debug_msg IN VARCHAR2);

END SINGLE_THREADED_LOOPED_PURGE;
/
SHOW ERRORS

--First drop temp table before proceeding with creation
DROP TABLE temp_cube_instance;
DROP TABLE temp_invoke_message;
DROP TABLE temp_dlv_message;
DROP TABLE temp_wf_instance;
DROP TABLE temp_xml_document;

-- Create temporary tables.
--
CREATE TABLE temp_cube_instance
(
    cikey           INTEGER,
    conversation_id VARCHAR2(256)
);

CREATE TABLE temp_invoke_message
(
   message_guid      VARCHAR2(50),
   headers_ref_id      VARCHAR2(100)
);

CREATE TABLE temp_dlv_message
(
    message_guid      VARCHAR2(50),
    headers_ref_id      VARCHAR2(100)
);

-- Human workflow table containing taskid's corresponding to instance id's in bpel tables.
CREATE TABLE temp_wf_instance
(
    wftask VARCHAR(64),
    constraint t1_wf_pk primary key(wftask)
);

CREATE TABLE temp_xml_document
(
    dockey  VARCHAR2( 200 )
);


CREATE OR REPLACE PACKAGE BODY SINGLE_THREADED_LOOPED_PURGE
IS

PROCEDURE debug_purge (debug_msg IN VARCHAR2) AS
BEGIN

$IF $$debug_on $THEN
    DBMS_OUTPUT.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' ' || debug_msg );
$ELSE
    null;
$END

END debug_purge;

/*
 * Purpose of below procedure is to purge BPEL dehydration store in loop and stop after
 * a defined time or when all data is deleted.
 *
 * Notes :
 *
 *   Creation of index on conv_id column of invoke_message table 
 *   would probably make this script run faster.
 *    
 *   You might need to do some tuning exercise to find good value for p_chunksize
 *   that would give most benefit (number of rows deleted in a given time) to your environment. 
 *
 *   If EXISTS clause does not perform well in your environment, you could change it to IN.
 *   Ideally CBO should exchange EXISTS with IN based on cost but in some cases you might need to change
 *   it manually inside this script.
 *
 *   We used EXISTS clause because it worked well on most of the customer environments 
 *   where this script was tested.
 *
 *   Please use "SET SERVEROUTPUT ON" on session before calling purge_instances_loop procedure. This is needed
 *   to print the error message in case some problem happens with purge.
 *
 * Description of parameters:
 *
 * p_older_than    Retention period, for example sysdate - 21 
 * p_chunksize     Max number of instances that should be deleted in one loop , for example 20000.
 *                 Purpose of this parameter is to keep transaction size in reasonable limit. 
 *
 *                 Setting it to very small number should be avoided as it will increase the number of loops
 *                 and every loop would scan all the tables, and thus large number of loops would increase scanning
 *                 and decrease performance.  
 *
 *                 Setting it to very high is also not recommended as 
 *                 high value would cause large transaction size which would badly affect the redo
 *                 and undo segments.
 * p_stop_time     Max number of minutes after which purge should exit, for example 60 (for 1 hour)
 */

PROCEDURE purge_instances_loop (p_older_than TIMESTAMP, p_chunksize NUMBER, p_stop_time INTEGER default NULL)
AS
  v_stoptime DATE := sysdate + NVL(p_stop_time,24*60)/(24*60); 
  v_code     NUMBER;
  v_errm     VARCHAR2(150);
  v_stmt     VARCHAR2(200);
  loop_count NUMBER := 0;
  ci_flag    BOOLEAN := TRUE;
  im_flag    BOOLEAN := TRUE;
  dlv_flag   BOOLEAN := TRUE;
  wf_flag    BOOLEAN := TRUE;
  xml_flag   BOOLEAN := TRUE;

BEGIN

$IF $$tracing_on $THEN
    v_stmt := 'Setting 10046 trace';
    execute immediate 'alter session set events ''10046 trace name context forever, level 8'''; 
$ELSE
    null;
$END

v_stmt := 'Start of purge';

EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_cube_instance reuse storage';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_invoke_message reuse storage';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_dlv_message reuse storage';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_wf_instance reuse storage';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_xml_document reuse storage';

v_stmt := 'Jump into Loop';

-- Since all other tables are driven by temp_cube_instance, if ci_flag is false, we are done.
WHILE (ci_flag AND sysdate < v_stoptime) LOOP

   loop_count := loop_count + 1;
   debug_purge('----------------------------------------------------------------------');
   debug_purge('Start of loop = ' || loop_count);
   v_stmt := 'Insert into temp_cube_instance';
   INSERT into temp_cube_instance
       SELECT cikey, conversation_id
         FROM cube_instance
         WHERE state >= 5 AND modify_date < p_older_than
           AND rownum <= p_chunksize;
   IF SQL%NOTFOUND THEN
         ci_flag := FALSE;
   END IF;
   debug_purge('Number of cikey inserted into temp_cube_instance = ' || SQL%ROWCOUNT);
   COMMIT;

   im_flag  := FALSE;
   dlv_flag := FALSE;
   xml_flag := FALSE;
   wf_flag  := FALSE;

   IF ci_flag THEN
       -- RAMISRA : There is no need to use rownum as we are driving from temp_cube_instance which has already been
       -- limited by rownum clause
       v_stmt := 'Insert into temp_invoke_message';
       INSERT into temp_invoke_message 
                  SELECT /*+ ORDERED */ im.message_guid , im.headers_ref_id
                  FROM  temp_cube_instance tci, invoke_message im
                  WHERE  tci.conversation_id=im.conv_id AND im.state > 1;
       IF SQL%FOUND THEN
           im_flag:=TRUE;
       END IF;
       debug_purge('Number of message_guid inserted into temp_invoke_message = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Insert into temp_dlv_message';
       INSERT into temp_dlv_message
               SELECT /*+  ORDERED */ message_guid , headers_ref_id 
               FROM   temp_cube_instance tci, dlv_subscription ds, dlv_message dm
               WHERE  tci.cikey=ds.cikey AND ds.subscriber_id=dm.res_subscriber AND dm.state > 1;
       IF SQL%FOUND THEN
           dlv_flag:=TRUE;
       END IF;
       debug_purge('Number of message_guid inserted into temp_dlv_message = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Insert into temp_wf_instance';   
       INSERT into temp_wf_instance
              SELECT /*+ ORDERED */ t.taskid
                FROM temp_cube_instance tpic, WFTask t
                WHERE  t.instanceid = tpic.cikey ;
       IF SQL%FOUND THEN
          wf_flag:=TRUE;
       END IF;
       debug_purge('Number of taskid inserted into temp_wf_instance = ' || SQL%ROWCOUNT);
       COMMIT;
   END IF;

   IF wf_flag THEN
      v_stmt := 'Delete from WFAssignee';
      DELETE FROM WFAssignee wft
        WHERE EXISTS (SELECT 1 FROM temp_wf_instance twi where twi.wftask =  wft.taskid);

      debug_purge('Number of rows deleted from WFAssignee = ' || SQL%ROWCOUNT);
      COMMIT;

      v_stmt := 'Delete from WFAttachment';
      DELETE FROM WFAttachment wft
        WHERE EXISTS  (SELECT 1 FROM temp_wf_instance twi WHERE twi.wftask = wft.taskid);

      debug_purge('Number of rows deleted from WFAttachment = ' || SQL%ROWCOUNT);
      COMMIT;

      v_stmt := 'Delete from WFComments';
      DELETE FROM WFComments wft
        WHERE EXISTS  (SELECT 1 FROM temp_wf_instance twi WHERE twi.wftask = wft.taskid);

      debug_purge('Number of rows deleted from WFComments = ' || SQL%ROWCOUNT);
      COMMIT;

      v_stmt := 'Delete from WFMessageAttribute';
      DELETE FROM WFMessageAttribute wft
        WHERE EXISTS  (SELECT 1 FROM temp_wf_instance twi WHERE twi.wftask = wft.taskid);

      debug_purge('Number of rows deleted from WFMessageAttribute = ' || SQL%ROWCOUNT);
      COMMIT;

      v_stmt := 'Delete from WFRoutingslip';
      DELETE FROM WFRoutingSlip wft
        WHERE EXISTS  (SELECT 1 FROM  temp_wf_instance twi WHERE twi.wftask = wft.taskid);
 
      debug_purge('Number of rows deleted from WFRoutingslip = ' || SQL%ROWCOUNT);
      COMMIT;

      v_stmt := 'Delete from WFTaskHistory';
      DELETE FROM WFTaskHistory wft
        WHERE EXISTS  (SELECT 1 FROM temp_wf_instance twi WHERE twi.wftask = wft.taskid);

      debug_purge('Number of rows deleted from WFTaskHistory = ' || SQL%ROWCOUNT);
      COMMIT;

      v_stmt := 'Delete from WFTasktimer';
      DELETE FROM WFTaskTimer wft
        WHERE EXISTS  (SELECT 1 FROM  temp_wf_instance twi WHERE twi.wftask = wft.taskid);

      debug_purge('Number of rows deleted from WFTasktimer = ' || SQL%ROWCOUNT);
      COMMIT;

      v_stmt := 'Delete from WFTask';
      DELETE FROM WFTask wft
        WHERE EXISTS  (SELECT 1 FROM temp_wf_instance twi WHERE twi.wftask = wft.taskid);

      debug_purge('Number of rows deleted from WFTask = ' || SQL%ROWCOUNT);
      COMMIT;

   END IF; -- END workflow tables

   /* CUBE_INSTANCE AND ITS DEPENDENT TABLE DELETE START */
   IF ci_flag THEN

       v_stmt := 'Delete from native_correlation';
       DELETE FROM native_correlation
          WHERE conversation_id IN (SELECT /*+ ORDERED */ dlvs.conv_id FROM 
                                    temp_cube_instance tpic, dlv_subscription dlvs
                                    WHERE dlvs.cikey = tpic.cikey );
       debug_purge('Number of rows deleted from native_correlation = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from cube_scope'; 
       DELETE FROM cube_scope cs
         WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = cs.cikey);

       debug_purge('Number of rows deleted from cube_scope = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from work_item'; 
       DELETE FROM work_item wi
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = wi.cikey);

       debug_purge('Number of rows deleted from work_item = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from wi_exception'; 
       DELETE FROM wi_exception we
            WHERE EXISTS (SELECT 1 FROM  temp_cube_instance tpic WHERE tpic.cikey = we.cikey);

       debug_purge('Number of rows deleted from wi_exception = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from scope_activation'; 
       DELETE FROM scope_activation sa
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = sa.cikey);

       debug_purge('Number of rows deleted from scope_activation = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from dlv_subscription'; 
       DELETE FROM dlv_subscription ds
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = ds.cikey);

       debug_purge('Number of rows deleted from dlv_subscription = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from audit_trail'; 

       DELETE FROM audit_trail at
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = at.cikey);

       debug_purge('Number of rows deleted from audit_trail = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from audit_details'; 
       DELETE FROM audit_details ad
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = ad.cikey);

       debug_purge('Number of rows deleted from audit_details = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from sync_trail'; 
       DELETE FROM sync_trail st
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = st.cikey);

       debug_purge('Number of rows deleted from sync_trail = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from sync_store'; 
       DELETE FROM sync_store st
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey=st.cikey);

       debug_purge('Number of rows deleted from sync_store = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Insert into temp_xml_document dockey where dockey in temp_cube_instance and document_ci_ref';
       INSERT INTO temp_xml_document 
          SELECT doc_ref.dockey  
               FROM temp_cube_instance tpic, document_ci_ref doc_ref
                 WHERE tpic.cikey = doc_ref.cikey;

       IF SQL%FOUND THEN
          xml_flag:=TRUE;
       END IF;

       debug_purge('Number of rows inserted into temp_xml_document with document_ci_ref matching is = ' || SQL%ROWCOUNT);
       COMMIT;
   
       v_stmt := 'Delete from document_ci_ref'; 
       DELETE FROM document_ci_ref dcr
                  WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = dcr.cikey);

       debug_purge('Number of rows deleted from document_ci_ref = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from attachment'; 
       DELETE FROM attachment at
             WHERE EXISTS (SELECT 1
             FROM temp_cube_instance tpic, attachment_ref attach_ref
             WHERE attach_ref.cikey = tpic.cikey AND attach_ref.key = at.key);

       debug_purge('Number of rows deleted from attachment = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from attachment_ref'; 
       DELETE FROM attachment_ref ar
                 WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey=ar.cikey);

       debug_purge('Number of rows deleted from attachment_ref = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from ci_indexes'; 
       DELETE FROM ci_indexes ci
                 WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = ci.cikey);

       debug_purge('Number of rows deleted from ci_indexes = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from wi_fault'; 
       DELETE FROM wi_fault wf
                 WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = wf.cikey);

       debug_purge('Number of rows deleted from wi_fault = ' || SQL%ROWCOUNT);
       COMMIT;


   END IF; 
   /* CUBE_INSTANCE AND ITS DEPENDENT TABLE DELETE END */

   /* INVOKE_MESSAGE AND ITS DEPENDENT TABLE DELETE START */
   IF im_flag THEN
       v_stmt := 'Insert temp_xml_document dockey callback messages';
       INSERT INTO temp_xml_document SELECT dlv_ref.dockey FROM
                            temp_invoke_message tpiim, document_dlv_msg_ref dlv_ref
                            WHERE tpiim.message_guid =  dlv_ref.message_guid;
       IF SQL%FOUND THEN
          xml_flag:=TRUE;
       END IF;

       debug_purge('Number of rows inserted into temp_xml_document with document_dlv_msg_ref and invoke_message matching is = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from invoke_message where invoke_message older';
       DELETE FROM invoke_message im
            WHERE EXISTS (SELECT 1 FROM temp_invoke_message tpiim WHERE tpiim.message_guid=im.message_guid);

       debug_purge('Number of rows deleted from invoke_message = ' || SQL%ROWCOUNT);
       COMMIT;
   END IF;
   /* INVOKE_MESSAGE AND ITS DEPENDENT TABLE DELETE END */

   /* DLV_MESSAGE AND ITS DEPENDENT TABLE DELETE START */
   IF dlv_flag THEN
       v_stmt := 'Insert temp_xml_document from document_dlv_msg_ref dlv messages';
       INSERT INTO temp_xml_document SELECT dlv_ref.dockey FROM
                            temp_dlv_message tpidm, document_dlv_msg_ref dlv_ref
                            WHERE dlv_ref.message_guid =  tpidm.message_guid;

       IF SQL%FOUND THEN
          xml_flag:=TRUE;
       END IF;

       debug_purge('Number of rows inserted into temp_xml_document with document_dlv_msg_ref and dlv_message matching is = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Delete from dlv_message callback messages';
       DELETE FROM dlv_message dm
            WHERE EXISTS (SELECT 1 FROM  temp_dlv_message tpidm WHERE tpidm.message_guid=dm.message_guid);

       debug_purge('Number of rows deleted from dlv_message = ' || SQL%ROWCOUNT);
       COMMIT;

   END IF;
   /* DLV_MESSAGE AND ITS DEPENDENT TABLE DELETE END */

   IF im_flag OR dlv_flag THEN
       v_stmt := 'Delete from document_dlv_msg_ref where invoke_message + dlv_message'; 
       --MERGE 2 tables delete together
       DELETE FROM document_dlv_msg_ref ddmr
                 WHERE ddmr.message_guid IN (SELECT tpiim.message_guid FROM temp_invoke_message tpiim 
                            UNION SELECT tpdlv.message_guid FROM temp_dlv_message tpdlv);
       debug_purge('Number of rows deleted from document_dlv_msg_ref = ' || SQL%ROWCOUNT);
       COMMIT;

       v_stmt := 'Insert temp_xml_document referenced from temp_invoke_message';
       INSERT INTO temp_xml_document SELECT headers_ref_id from temp_invoke_message 
                                     UNION 
                                     SELECT headers_ref_id from temp_dlv_message;

       IF SQL%FOUND THEN
          xml_flag:=TRUE;
       END IF;

       debug_purge('Number of rows inserted into temp_xml_document with matching header_ref_id is = ' || SQL%ROWCOUNT);
       COMMIT;
   END IF;

   /* XML_DOCUMENT TABLE DELETE */
   IF xml_flag THEN
       v_stmt := 'Delete from xml_document';
       DELETE from XML_DOCUMENT xd where exists (SELECT 1 from temp_xml_document where temp_xml_document.dockey = xd.dockey);

       debug_purge('Number of rows deleted from xml_document = ' || SQL%ROWCOUNT);
       COMMIT;
   END IF;

   /* CUBE_INSTANCE is driving table so data from it is deleted at end */ 
   IF ci_flag THEN
       v_stmt := 'Delete from cube_instance'; 
       DELETE FROM cube_instance ci
            WHERE EXISTS (SELECT 1 FROM temp_cube_instance tpic WHERE tpic.cikey = ci.cikey);

       debug_purge('Number of rows deleted from cube_instance = ' || SQL%ROWCOUNT);
       COMMIT;
   END IF;

   v_stmt := 'Truncate Tables';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_cube_instance reuse storage';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_invoke_message reuse storage';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_dlv_message reuse storage';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_wf_instance reuse storage';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_xml_document reuse storage';

   v_stmt := 'Loop End Control';
   debug_purge('End of loop = ' || loop_count);
   debug_purge('----------------------------------------------------------------------');
END LOOP;

v_stmt := 'Delete from native_correlation';   
DELETE FROM native_correlation nc
              WHERE NOT EXISTS (SELECT dlvs.conv_id from dlv_subscription dlvs
                                                              WHERE dlvs.conv_id = nc.conversation_id);
COMMIT;

v_stmt := 'Delete from process_log';
DELETE FROM process_log WHERE event_date < p_older_than;

COMMIT;

EXCEPTION
  when others then 
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);
    DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm || ' at line : ' || v_stmt);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_cube_instance reuse storage';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_invoke_message reuse storage';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_dlv_message reuse storage';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_wf_instance reuse storage';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_xml_document reuse storage';

    COMMIT;
   
END purge_instances_loop;

END SINGLE_THREADED_LOOPED_PURGE;

/
SHOW ERRORS
