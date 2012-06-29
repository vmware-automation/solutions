Rem
Rem $Header: online_rebuild_index_oracle.sql 04-mar-2008.16:45:41 ramisra Exp $
Rem
Rem online_rebuild_index_oracle.sql
Rem
Rem Copyright (c) 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      online_rebuild_index_oracle.sql - to rebuild the indexes online 
Rem
Rem    DESCRIPTION
Rem      Whenever purge_instances_oracle.sql script is run, we delete lot of rows from
Rem      dehydration table and that may cause B*Tree indexes to get fragmented and
Rem      performance may degrade, we can avoid that by rebuilding indexes online.
Rem      Oracle 9i and above with enterprise edition database has option of rebuilding
Rem      indexes without shutting down database or without affecting dml operations
Rem      on database.
Rem
Rem    NOTES
Rem     This is an optional script to run after purge_instances_oracle.sql if customer is
Rem     seeing performance degration after purge_instances_oracle.sql or next run 
Rem     of purge_instances_oracle.sql is taking lot of time.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     02/29/08 - For rebuilding fragmented B*Tree indexes of dehydration
Rem                           store online
Rem    ramisra     02/29/08 - Created
Rem

SET ECHO ON
SET TIMING ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

COLUMN TIMECOL NEW_VALUE TIMESTAMP;
SELECT to_char(SYSDATE,'YYYY-MM-DD_HHMISS') TIMECOL FROM DUAL;
SPOOL online_rebuild_index_oracle_&&timestamp

ALTER INDEX ci_pk REBUILD REVERSE ONLINE;
ALTER INDEX ci_custom2 REBUILD ONLINE;
ALTER INDEX ci_custom3 REBUILD ONLINE;
ALTER INDEX state_ind REBUILD ONLINE;
ALTER INDEX ci_index_1 REBUILD ONLINE;
ALTER INDEX ci_index_2 REBUILD ONLINE;
ALTER INDEX ci_index_3 REBUILD ONLINE;
ALTER INDEX ci_index_4 REBUILD ONLINE;
ALTER INDEX ci_index_5 REBUILD ONLINE;
ALTER INDEX ci_index_6 REBUILD ONLINE;
ALTER INDEX sa_fk REBUILD ONLINE;
ALTER INDEX wi_expired REBUILD ONLINE;
ALTER INDEX wi_stranded REBUILD ONLINE;
ALTER INDEX wx_fk REBUILD ONLINE;
ALTER INDEX wf_fk1 REBUILD ONLINE;
ALTER INDEX wf_fk2 REBUILD ONLINE;
ALTER INDEX wf_fk2 REBUILD ONLINE;
ALTER INDEX xml_doc_pk rebuild REVERSE ONLINE;
ALTER INDEX at_fk REBUILD ONLINE;
ALTER INDEX st_fk REBUILD ONLINE;
ALTER INDEX ss_fk REBUILD ONLINE;
ALTER INDEX dm_conversation REBUILD ONLINE;
ALTER INDEX ds_fk REBUILD ONLINE;
ALTER INDEX ds_conversation REBUILD ONLINE;
ALTER INDEX ds_operation REBUILD ONLINE;
ALTER INDEX im_master_conv_id REBUILD ONLINE;
ALTER INDEX im_pk REBUILD REVERSE ONLINE;
ALTER INDEX doc_dlv_msg_ref_pk REBUILD REVERSE ONLINE;
ALTER INDEX ddmr_dockey REBUILD ONLINE;
ALTER INDEX ta_conversation_id REBUILD ONLINE;
ALTER INDEX pl_fk REBUILD ONLINE;
ALTER INDEX nc_corr REBUILD ONLINE;
ALTER INDEX nc_conv REBUILD ONLINE;

SPOOL OFF

EXIT;
