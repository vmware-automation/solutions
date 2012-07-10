Rem
Rem $Header: purge_instances_oracle.sql 11-jun-2008.10:00:08 mnanal Exp $
Rem
Rem purge_instances_oracle.sql
Rem
Rem Copyright (c) 2007, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      purge_instances_oracle.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This file deletes all cube instaces and related data which were closed before given date time
Rem
Rem    NOTES
Rem      Please take backup of your dehydration store before running this script 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mnanal      06/11/08 - Backport mnanal_bug-6865907 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     06/04/08 - Backport ramisra_bug-6940887 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     04/02/08 - Backport ramisra_bug-6806290 from
Rem                           st_pcbpel_10.1.3.1
Rem    marjones    04/01/08 - restoring purge_instances_oracle.sql script
Rem    ramisra     02/28/08 - refactored for performance
Rem    ramisra     01/11/08 - Backport ramisra_bug-6655046 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     01/10/08 - Backport ramisra_bug-6501312 from
Rem    ramisra     09/13/07 - File to purge Instances
Rem    ramisra     09/13/07 - Created
Rem

SET ECHO ON
SET TIMING ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

--First drop temp table before procceding with creation
DROP TABLE temp_cube_instance;
DROP TABLE temp_invoke_message;
DROP TABLE temp_dlv_message;
DROP TABLE temp_wf_instance;


-- Create temporary tables.
--
CREATE TABLE temp_cube_instance
(
    cikey           INTEGER,
    constraint t_ci_pk primary key(cikey)
);

CREATE TABLE temp_invoke_message
(
   message_guid      VARCHAR2(50),
   headers_ref_id      VARCHAR2(100),
   constraint t_im_pk primary key( message_guid )
);

CREATE TABLE temp_dlv_message
(
    message_guid      VARCHAR2(50),
    headers_ref_id      VARCHAR2(100),
    constraint t_dm_pk primary key( message_guid )
);

-- Human workflow table containing taskid's corresponding to instance id's in bpel tables.
CREATE TABLE temp_wf_instance 
( 
    wftask VARCHAR(64),
    constraint t_wf_pk primary key(wftask)   
);

CREATE OR REPLACE PROCEDURE purge_instances (p_older_than TIMESTAMP)
AS
BEGIN
--before starting clean up temp tables
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_cube_instance';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_invoke_message';  
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_dlv_message'; 
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_wf_instance'; 
   --Populate table with information about older instances
   INSERT into temp_cube_instance
      SELECT cikey
        FROM cube_instance
       WHERE state >= 5 AND modify_date < p_older_than;
   INSERT into temp_invoke_message
      SELECT message_guid , headers_ref_id
        FROM invoke_message im
       WHERE state > 1 AND receive_date < p_older_than AND NOT EXISTS 
       -- we do not want to delete those rows which are referenced by the delivered messages
       -- but also by the open cikey instance
       (SELECT 1 FROM cube_instance ci, 
                      document_ci_ref dcr, 
                      document_dlv_msg_ref ddmr 
            WHERE im.message_guid = ddmr.message_guid 
                  AND ddmr.dockey = dcr.dockey 
                  AND dcr.cikey = ci.cikey 
                  AND ci.state < 5);
   INSERT into temp_dlv_message
      SELECT message_guid , headers_ref_id
        FROM dlv_message dm
       WHERE state > 1 AND receive_date < p_older_than AND NOT EXISTS 
       -- we do not want to delete those rows which are referenced by the delivered messages
       -- but also by the open cikey instance 
       (SELECT 1 FROM cube_instance ci, 
                      document_ci_ref dcr, 
                      document_dlv_msg_ref ddmr 
            WHERE dm.message_guid = ddmr.message_guid 
                  AND ddmr.dockey = dcr.dockey 
                  AND dcr.cikey = ci.cikey 
                  AND ci.state < 5);

   -- Fill temp WF table with taskid's corresponding to bpel instance id's.
   INSERT into temp_wf_instance
      SELECT t.taskid
        FROM WFTask t, temp_cube_instance tpic
      WHERE  t.instanceid = tpic.cikey ;

COMMIT;

   -- WHERE clause is to force CBO to use index of temp table and to avoid full scan of temp table
   -- COMMIT after every delete to reduce pressure on undo log in database

   -- Delete all closed instances older than specified date
   DELETE FROM native_correlation
          WHERE conversation_id IN (SELECT /*+ ORDERED */ dlvs.conv_id FROM dlv_subscription dlvs, 
                                             temp_cube_instance tpic 
                                              WHERE dlvs.cikey = tpic.cikey );
COMMIT;

   DELETE FROM cube_scope
         WHERE cikey IN (SELECT /*+ ORDERED */ cs.cikey FROM cube_scope cs, 
                                temp_cube_instance tpic
                                WHERE cs.cikey = tpic.cikey);
COMMIT;

   DELETE FROM work_item
            WHERE cikey IN (SELECT /*+ ORDERED */ wi.cikey FROM work_item wi,
                                   temp_cube_instance tpic
                                   WHERE wi.cikey = tpic.cikey);
COMMIT;
 
   DELETE FROM wi_exception
            WHERE cikey IN (SELECT /*+ ORDERED */ wie.cikey FROM  wi_exception wie,
                                   temp_cube_instance tpic
                                   WHERE wie.cikey = tpic.cikey);
COMMIT;

   DELETE FROM scope_activation
            WHERE cikey IN (SELECT /*+ ORDERED */ sa.cikey FROM scope_activation sa,
                                   temp_cube_instance tpic
                                   WHERE sa.cikey = tpic.cikey);
COMMIT;

   DELETE FROM dlv_subscription
            WHERE cikey IN (SELECT /*+ ORDERED */ dlvs.cikey FROM dlv_subscription dlvs,
                                   temp_cube_instance tpic
                                   WHERE dlvs.cikey = tpic.cikey);
COMMIT;

   DELETE FROM audit_trail
            WHERE cikey IN (SELECT /*+ ORDERED */ at.cikey FROM audit_trail at,
                                   temp_cube_instance tpic
                                   WHERE at.cikey = tpic.cikey);
COMMIT;

   DELETE FROM audit_details
            WHERE cikey IN (SELECT /*+ ORDERED */ ad.cikey FROM audit_details ad,
                                   temp_cube_instance tpic
                                   WHERE ad.cikey = tpic.cikey);
COMMIT;

   DELETE FROM sync_trail
            WHERE cikey IN (SELECT /*+ ORDERED */ st.cikey FROM sync_trail st,
                                   temp_cube_instance tpic
                                   WHERE st.cikey = tpic.cikey);
COMMIT;

   DELETE FROM sync_store
            WHERE cikey IN (SELECT /*+ ORDERED */ ss.cikey FROM sync_store ss,
                                   temp_cube_instance tpic
                                   WHERE ss.cikey = tpic.cikey); 
COMMIT;
        
   DELETE FROM xml_document 
                 WHERE dockey IN (SELECT /*+ ORDERED */ doc_ref.dockey FROM document_ci_ref doc_ref,
                                          temp_cube_instance tpic
			                   WHERE doc_ref.cikey =  tpic.cikey);
COMMIT;

   DELETE FROM document_dlv_msg_ref 
                  WHERE dockey IN (SELECT /*+ ORDERED */ doc_ref.dockey FROM document_ci_ref doc_ref,
                                           temp_cube_instance tpic
			                   WHERE doc_ref.cikey =  tpic.cikey);
COMMIT;

   DELETE FROM document_ci_ref 
                  WHERE cikey IN (SELECT /*+ ORDERED */ dcr.cikey FROM document_ci_ref dcr,
                                   temp_cube_instance tpic
                                   WHERE dcr.cikey = tpic.cikey);  
COMMIT;

   DELETE FROM attachment
                 WHERE key IN (SELECT /*+ ORDERED */ attach_ref.key FROM attachment_ref attach_ref,
                                           temp_cube_instance tpic
			                   WHERE attach_ref.cikey = tpic.cikey);
COMMIT;

   DELETE FROM attachment_ref 
                 WHERE cikey IN (SELECT /*+ ORDERED */ ar.cikey FROM attachment_ref ar,
                                   temp_cube_instance tpic
                                   WHERE ar.cikey = tpic.cikey);
COMMIT;

   DELETE FROM ci_indexes 
                 WHERE cikey IN (SELECT /*+ ORDERED */ cin.cikey FROM ci_indexes cin,
                                   temp_cube_instance tpic
                                   WHERE cin.cikey = tpic.cikey);
COMMIT;

   DELETE FROM wi_fault
                 WHERE cikey IN (SELECT /*+ ORDERED */ wf.cikey FROM wi_fault wf,
                                   temp_cube_instance tpic
                                   WHERE wf.cikey = tpic.cikey);
COMMIT;

   DELETE FROM cube_instance
            WHERE cikey IN (SELECT /*+ ORDERED */ ci.cikey FROM cube_instance ci,
                                   temp_cube_instance tpic
                                   WHERE ci.cikey = tpic.cikey);

COMMIT;

   -- Purge all handled invoke_messages older than specified date
   --

   DELETE FROM xml_document 
             WHERE dockey IN (SELECT /*+ ORDERED */ dlv_ref.dockey FROM  document_dlv_msg_ref dlv_ref,
                                        temp_invoke_message tpiim
		                        WHERE dlv_ref.message_guid =  tpiim.message_guid);
COMMIT;
   DELETE FROM document_ci_ref
            WHERE dockey IN (SELECT /*+ ORDERED */ dlv_ref.dockey FROM  document_dlv_msg_ref dlv_ref,
                                   temp_invoke_message tpiim
		                   WHERE dlv_ref.message_guid =  tpiim.message_guid);
COMMIT;

   DELETE FROM document_dlv_msg_ref
             WHERE message_guid IN (SELECT /*+ ORDERED */ dlv_ref.message_guid FROM document_dlv_msg_ref dlv_ref,
                                          temp_invoke_message tpiim
                                          WHERE dlv_ref.message_guid  = tpiim.message_guid);
COMMIT;
   DELETE FROM invoke_message
            WHERE message_guid IN (SELECT /*+ ORDERED */ im.message_guid FROM invoke_message im,
                                          temp_invoke_message tpiim
                                          WHERE im.message_guid  = tpiim.message_guid);
 
COMMIT;

   -- Purge all handled callback messages older than specified date
   --

   DELETE FROM xml_document 
             WHERE dockey IN (SELECT /*+ ORDERED */ dlv_ref.dockey FROM  document_dlv_msg_ref dlv_ref,
                                        temp_dlv_message tpidm
		                        WHERE dlv_ref.message_guid =  tpidm.message_guid);
COMMIT;
   DELETE FROM document_ci_ref
            WHERE dockey IN (SELECT /*+ ORDERED */ dlv_ref.dockey FROM  document_dlv_msg_ref dlv_ref,
                                   temp_dlv_message tpidm
		                   WHERE dlv_ref.message_guid =  tpidm.message_guid);

COMMIT;
   DELETE FROM document_dlv_msg_ref
             WHERE message_guid IN (SELECT /*+ ORDERED */ ddmr.message_guid FROM document_dlv_msg_ref ddmr,
                                                 temp_dlv_message tpidm
                                                WHERE ddmr.message_guid =  tpidm.message_guid);
COMMIT;
   DELETE FROM dlv_message
            WHERE message_guid IN (SELECT /*+ ORDERED */  dm.message_guid FROM  dlv_message dm,
                                               temp_dlv_message tpidm
                                               WHERE dm.message_guid = tpidm.message_guid); 

COMMIT;

   -- delete all unreferenced xml_documents rows from xml_document table
 DELETE FROM xml_document
               WHERE dockey IN (SELECT headers_ref_id from temp_invoke_message);

 DELETE FROM xml_document
               WHERE dockey IN (SELECT headers_ref_id from temp_dlv_message);

COMMIT;
   -- IF conversation_id is not present in dlv_subscription, we can delete it from native_correlation
   DELETE FROM native_correlation nc
                 WHERE NOT EXISTS (SELECT dlvs.conv_id from dlv_subscription dlvs
                                                              WHERE dlvs.conv_id = nc.conversation_id);
COMMIT;

   --  Bug 6865907  - Might be moved to another file later if needed. 
   -- Create a temp table containing qualifying taskid's. These values will be used to join
   -- with other taskid's in other tables.



   DELETE FROM WFAssignee wft
        WHERE wft.taskid IN  (SELECT ta.taskid FROM WFAssignee ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);
   commit;

   DELETE FROM WFAttachment wft
        WHERE wft.taskid IN  (SELECT ta.taskid FROM WFAttachment ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);

   commit;

   DELETE FROM WFComments wft
        WHERE wft.taskid IN  (SELECT ta.taskid FROM WFComments  ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);
   commit;

   DELETE FROM WFMessageAttribute wft
        WHERE wft.taskid IN  (SELECT ta.taskid FROM WFMessageAttribute ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);

   commit;

   DELETE FROM WFRoutingSlip wft
       WHERE wft.taskid IN  (SELECT ta.taskid FROM WFRoutingSlip ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);

   commit;
   
   DELETE FROM WFTaskHistory wft
      WHERE wft.taskid IN  (SELECT ta.taskid FROM WFTaskHistory ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);

   commit;

   DELETE FROM WFTaskTimer wft
      WHERE wft.taskid IN  (SELECT ta.taskid FROM WFTaskTimer ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);

   commit;
   
   /* Lastly delete from WFTask table ...*/
   DELETE FROM WFTask wft
      WHERE wft.taskid IN  (SELECT ta.taskid FROM WFTask ta, temp_wf_instance twi
                      WHERE ta.taskid = twi.wftask);
   commit;

   DELETE FROM process_log
                 WHERE event_date < p_older_than;

EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_cube_instance';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_invoke_message';  
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_dlv_message'; 
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_wf_instance'; 

COMMIT;

END purge_instances;
/
/*-----------------------------------------------------------------------------------------------
  SELECT STATEMENTS TO COUNT THE NUMBER OF RECORDS IN EACH OF THE MAIN DEHYDRATION TABLES
 -----------------------------------------------------------------------------------------------*/

--select count(*) from cube_instance where modify_date <= to_timestamp('2006-05-11 00:00:00','YYYY-MM-DD HH24:MI:SS')

--select count(*) from invoke_message where receive_date <= to_timestamp('2006-05-11 00:00:00','YYYY-MM-DD HH24:MI:SS')

--select count(*) from dlv_message where receive_date <= to_timestamp('2006-05-11 00:00:00','YYYY-MM-DD HH24:MI:SS')

-- To delete all instances older than given timestamp
--call purge_instances(to_timestamp('2006-05-11 00:00:00','YYYY-MM-DD HH24:MI:SS'));

-- To delete all instances older than 120 days
--call purge_instances(SYSDATE - 120);
