Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/purge_bpel_ctas.sql /st_pcbpel_10.1.3.1/1 2010/05/05 11:59:02 ramisra Exp $
Rem
Rem purge_bpel_ctas.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      purge_bpel_ctas.sql - This script defines procedure to get rid of all closed instances
Rem                            using CTAS approach 
Rem
Rem    DESCRIPTION
Rem     The procedure defined in this script completely reorganizes the orabpel schema by migrating live/needed rows
Rem     to temporary table and then dropping the original table and renaming temp table
Rem     to original table.
Rem    
Rem     Since this is a complete reorganization of orabpel schema, it should never be run by normal user and
Rem     should only be executed by a DBA after analyzing the complete script and after
Rem     making appropriate changes as per customer installation.
Rem
Rem    NOTES :
Rem
Rem     Please read below points carefully
Rem
Rem     1) Procedure purge_bpel_ctas must only be run by DBA who is familiar with BPEL schema.
Rem
Rem     2) Complete backup of database must be taken BEFORE and AFTER running of purge_bpel_ctas procedure. 
Rem
Rem     3) SOA suite must be shutdown when this script is running.
Rem
Rem     4) If tables containing LOBS (such as cube_scope, xml_document, audit_trail) are taking
Rem        lot of time during CTAS run, DBA could Hash Partition their corresponding temp_ctas
Rem        tables by modifying this script. After Hash partition, please enable parallel DML
Rem        which would cause parallel servers to insert rows into temp_ctas_* table and thus
Rem        improving the performance.
Rem
Rem        One example of how hash partitioning could be done during CTAS for cube_scope table which
Rem        contains a LOB is below
Rem
Rem        create table temp_ctas_cube_scope parallel 16 nologging storage ( freelists 6 ) lob( scope_bin ) 
Rem        store as ( tablespace orabpel storage( initial 16K next 16K ) chunk 8K cache pctversion 10) pctfree 10 pctused 1 
Rem        tablespace orabpel partition by hash(cikey) partitions 16 
Rem        as (select /*+ parallel (ci, 16) full(ci) */ cs.* from cube_scope cs, cube_instance ci where ci.cikey = cs.cikey );
Rem
Rem        You could see that we have created 16 Hash partition of temp_ctas_cube_scope on cikey during CTAS.
Rem        With Hash partitioning DBA could enable parallelism, for example with "parallel 16" for LOB tables and thus CTAS would run
Rem        much faster.  Please look at example above.
Rem
Rem     5) DBA may add "parallel x" where x is degree of parallelism such as 16 for other tables which does not contain LOB to speed up the CTAS. 
Rem        For example DBA could use below for CTAS of invoke_message table which does not have LOB
Rem 
Rem        create table temp_ctas_invoke_message parallel 16 nologging as select /*+ parallel (im,16) */ * from invoke_message im where state < 1
Rem 
Rem        Please remember, use of parallel is only useful if hardware supports running of multiple process together which means 
Rem        box with multiple CPU and with good IO.  On low end box or single CPU box, use of parallel may actually reduce the performance of CTAS.
Rem        You should measure the performance with both parallel and non-parallel approach before deciding.
Rem 
Rem     6) If your LOBS are stored outside orabpel schema, you will need to make appropriate
Rem        changes in this script to reflect that.
Rem
Rem     7) Please make sure that you run create_indexes_after_ctas.sql after CTAS to create 
Rem        necessary indexes as this script does not recreate indexes
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     01/26/10 - adding example of how hash partitioning could be
Rem                           done for LOB tables
Rem    ramisra     01/25/10 - Created
Rem
SET ECHO ON

CREATE OR REPLACE PROCEDURE debug_ctas (table_name IN VARCHAR2, before_after IN VARCHAR2) AS
    stmt  VARCHAR2(300);
    rowcount  NUMBER;
BEGIN
     stmt := 'SELECT COUNT(*) FROM TABLE_NAME';
     stmt := REPLACE(stmt,'TABLE_NAME',table_name);
     execute immediate stmt into rowcount;
     DBMS_OUTPUT.put_line('Number of rows in table ' || table_name || ' ' || before_after || ' CTAS is : ' || rowcount);
END debug_ctas;
/

/*
 * p_older_than : All data (instances/messages/documents) which is yonger than p_older_than will be saved during CTAS
 * drop_table   : This BOOLEAN could be set to FALSE if we do not want to drop the original table.
 *                This parameter is useful for testing CTAS and assessing how CTAS would perform during actual run.
 *                If this parameter is set to FALSE, instead of drop, original table would be rename to table_name_orig
 *                This would help in restoring the tables if we need to run CTAS again.
 */

CREATE OR REPLACE
PROCEDURE purge_bpel_ctas (p_older_than TIMESTAMP, drop_table IN BOOLEAN)
AS
  v_code NUMBER;
  v_errm VARCHAR2(90);
  vstmt  VARCHAR2(2000);
BEGIN

DBMS_OUTPUT.put_line('Starting CTAS');
-- CTAS cube_instance
debug_ctas('cube_instance', 'before');

vstmt := 'create table temp_ctas_cube_instance nologging storage ( freelists 20 ) as ' ||
         ' (select * from cube_instance ci where ci.state < 5 OR ci.modify_date >= TO_TIMESTAMP(''RETENTION_PERIOD'')  )';

vstmt := REPLACE(vstmt,'RETENTION_PERIOD',p_older_than);
execute immediate vstmt;

IF drop_table
THEN
    execute immediate 'drop table cube_instance';
    execute immediate 'alter table temp_ctas_cube_instance rename to cube_instance';
    execute immediate 'alter table cube_instance add constraint ci_pk primary key( cikey )';
ELSE
    execute immediate 'alter table cube_instance rename to cube_instance_orig';
    execute immediate 'alter table temp_ctas_cube_instance rename to cube_instance';
END IF;

debug_ctas('cube_instance', 'after');

-- CTAS work_item
debug_ctas('work_item', 'before');

execute immediate 'create table temp_ctas_work_item nologging storage ( freelists 20 ) as (select wi.* from work_item wi, cube_instance ci where ci.cikey=wi.cikey )' ;

IF drop_table
THEN
    execute immediate 'drop table work_item';
    execute immediate 'alter table temp_ctas_work_item rename to work_item';
    execute immediate 'alter table work_item add constraint wi_pk primary key( cikey, node_id, scope_id, count_id )';
ELSE
    execute immediate 'alter table work_item rename to work_item_orig';
    execute immediate 'alter table temp_ctas_work_item rename to work_item';
END IF;
execute immediate 'alter table work_item modify ( exception default 0, exp_flag default 0, idempotent_flag default 0, execution_type default 0 )';

debug_ctas('work_item', 'after');

-- CTAS wi_exception
debug_ctas('wi_exception', 'before');
execute immediate 'create table temp_ctas_wi_exception nologging storage ( freelists 20 ) as (select we.* from wi_exception we, cube_instance ci where ci.cikey=we.cikey )' ;

IF drop_table
THEN
   execute immediate 'drop table wi_exception';
ELSE
   execute immediate 'alter table wi_exception rename to wi_exception_orig';
END IF;

execute immediate 'alter table temp_ctas_wi_exception rename to wi_exception';

debug_ctas('wi_exception', 'after');

-- CTAS scope_activation
debug_ctas('scope_activation', 'before');

execute immediate 'create table temp_ctas_scope_activation nologging storage ( freelists 3 ) as (select sa.* from scope_activation sa, cube_instance ci where ci.cikey=sa.cikey )';

IF drop_table
THEN
    execute immediate 'drop table scope_activation';
ELSE
    execute immediate 'alter table scope_activation rename to scope_activation_orig';
END IF;

execute immediate 'alter table temp_ctas_scope_activation  rename to scope_activation';
execute immediate 'alter table scope_activation modify (action default 0)';

debug_ctas('scope_activation', 'after');

-- CTAS dlv_subscription
debug_ctas('dlv_subscription', 'before');

execute immediate 'create table temp_ctas_dlv_subscription nologging as (select ds.* from dlv_subscription ds, cube_instance ci where ci.cikey=ds.cikey )';

IF drop_table
THEN
    execute immediate 'drop table dlv_subscription';
    execute immediate 'alter table temp_ctas_dlv_subscription rename to dlv_subscription';
    execute immediate 'alter table dlv_subscription add constraint ds_pk primary key( subscriber_id )';
ELSE
    execute immediate 'alter table dlv_subscription rename to dlv_subscription_orig';
    execute immediate 'alter table temp_ctas_dlv_subscription rename to dlv_subscription';
END IF;
execute immediate 'alter table dlv_subscription modify(  state default 0)';

debug_ctas('dlv_subscription', 'after');

-- CTAS audit_trail
debug_ctas('audit_trail', 'before');

execute immediate 'create table temp_ctas_audit_trail nologging as (select at.* from audit_trail at, cube_instance ci where ci.cikey=at.cikey )' ;

IF drop_table
THEN
    execute immediate 'drop table audit_trail';
ELSE
    execute immediate 'alter table audit_trail rename to audit_trail_orig';
END IF;
execute immediate 'alter table temp_ctas_audit_trail rename to audit_trail';

debug_ctas('audit_trail', 'after');

-- CTAS sync_trail
debug_ctas('sync_trail', 'before');

execute immediate 'create table temp_ctas_sync_trail nologging as (select st.* from sync_trail st, cube_instance ci where ci.cikey=st.cikey )' ;

IF drop_table
THEN
    execute immediate 'drop table sync_trail';
ELSE
    execute immediate 'alter table sync_trail rename to sync_trail_orig';
END IF;
execute immediate 'alter table temp_ctas_sync_trail  rename to sync_trail';

debug_ctas('sync_trail', 'after');

-- CTAS sync_store
debug_ctas('sync_store', 'before');

execute immediate 'create table temp_ctas_sync_store nologging storage ( freelists 6) lob( bin ) store as ( storage( initial 4k next 4k ) chunk 2k cache pctversion 0) pctfree 0 pctused 1 as (select ss.* from sync_store ss, cube_instance ci where ci.cikey=ss.cikey )';

IF drop_table
THEN
    execute immediate 'drop table sync_store';
ELSE
    execute immediate 'alter table sync_store rename to sync_store_orig';
END IF;

execute immediate 'alter table temp_ctas_sync_store rename to sync_store';

debug_ctas('sync_store', 'after');

-- CTAS attachment
debug_ctas('attachment', 'before');

execute immediate 'create table temp_ctas_attachment nologging as (select aa.* from attachment aa, attachment_ref attach_ref, cube_instance ci where aa.key=attach_ref.key and ci.cikey=attach_ref.cikey)' ;

IF drop_table
THEN
    execute immediate 'drop table attachment';
    execute immediate 'alter table temp_ctas_attachment rename to attachment';
    execute immediate 'alter table attachment add constraint att_pk primary key( key )';
ELSE
    execute immediate 'alter table attachment rename to attachment_orig';
    execute immediate 'alter table temp_ctas_attachment rename to attachment';
END IF;

debug_ctas('attachment', 'after');

-- CTAS attachment_ref
debug_ctas('attachment_ref', 'before');

execute immediate 'create table temp_ctas_attachment_ref nologging as (select attach_ref.* from attachment_ref attach_ref, cube_instance ci where ci.cikey=attach_ref.cikey)' ;

IF drop_table
THEN
    execute immediate 'drop table attachment_ref';
    execute immediate 'alter table temp_ctas_attachment_ref rename to attachment_ref';
    execute immediate 'alter table attachment_ref add constraint attref_pk primary key( cikey, key )';
ELSE
    execute immediate 'alter table attachment_ref rename to attachment_ref_orig';
    execute immediate 'alter table temp_ctas_attachment_ref rename to attachment_ref';
END IF;

debug_ctas('attachment_ref', 'after');

-- CTAS ci_indexes
debug_ctas('ci_indexes', 'before');

execute immediate 'create table temp_ctas_ci_indexes nologging as (select cind.* from ci_indexes cind, cube_instance ci where ci.cikey=cind.cikey)' ;

IF drop_table
THEN
    execute immediate 'drop table ci_indexes';
    execute immediate 'alter table temp_ctas_ci_indexes rename to ci_indexes';
    execute immediate 'alter table ci_indexes add constraint cx_pk primary key( cikey )';
ELSE
    execute immediate 'alter table ci_indexes rename to ci_indexes_orig';
    execute immediate 'alter table temp_ctas_ci_indexes rename to ci_indexes';
END IF;

debug_ctas('ci_indexes', 'after');

-- CTAS wi_fault
debug_ctas('wi_fault', 'before');

execute immediate 'create table temp_ctas_wi_fault nologging storage ( freelists 20 ) as (select wf.* from wi_fault wf, cube_instance ci where ci.cikey=wf.cikey )';

IF drop_table
THEN
    execute immediate 'drop table wi_fault';
ELSE
    execute immediate 'alter table wi_fault rename to wi_fault_orig';
END IF;
execute immediate 'alter table  temp_ctas_wi_fault rename to wi_fault';

debug_ctas('wi_fault', 'after');

-- CTAS native_correlation
debug_ctas('native_correlation', 'before');

execute immediate 'create table temp_ctas_native_correlation nologging as (select nc.* from native_correlation nc, dlv_subscription ds where ds.conv_id = nc.conversation_id)';

IF drop_table
THEN
    execute immediate 'drop table native_correlation';
ELSE
    execute immediate 'alter table native_correlation rename to native_correlation_orig';
END IF;
execute immediate 'alter table temp_ctas_native_correlation rename to native_correlation';

debug_ctas('native_correlation', 'after');

-- CTAS process_log
debug_ctas('process_log', 'before');

vstmt := 'create table temp_ctas_process_log nologging as (select pl.* from process_log pl where pl.event_date >= TO_TIMESTAMP(''RETENTION_PERIOD'')  )';

vstmt := REPLACE(vstmt,'RETENTION_PERIOD',p_older_than);
execute immediate vstmt;
 
IF drop_table
THEN
    execute immediate 'drop table process_log';
ELSE
    execute immediate 'alter table process_log rename to process_log_orig';
END IF;
execute immediate 'alter table temp_ctas_process_log rename to process_log';

debug_ctas('process_log', 'after');

-- CTAS for cube_scope
debug_ctas('cube_scope', 'before');

execute immediate 'create table temp_ctas_cube_scope nologging storage ( freelists 6 ) lob( scope_bin ) store as ( storage( initial 16K next 16K ) chunk 8K cache pctversion 10) pctfree 10 pctused 1 tablespace orabpel as (select cs.* from cube_scope cs, cube_instance ci where ci.cikey = cs.cikey )';

IF drop_table
THEN
    execute immediate 'drop table cube_scope';
    execute immediate 'alter table temp_ctas_cube_scope rename to cube_scope';
    execute immediate 'alter table cube_scope add constraint cs_pk primary key( cikey )';
ELSE
    execute immediate 'alter table cube_scope rename to cube_scope_orig';
    execute immediate 'alter table temp_ctas_cube_scope rename to cube_scope';
END IF;

debug_ctas('cube_scope', 'after');

-- CTAS for audit_details
debug_ctas('audit_details', 'before');

execute immediate 'create table temp_ctas_audit_details nologging as (select ad.* from audit_details ad, cube_instance ci where ci.cikey = ad.cikey )';

IF drop_table
THEN
    execute immediate 'drop table audit_details';
    execute immediate 'alter table temp_ctas_audit_details rename to audit_details';
    execute immediate 'alter table audit_details add constraint ad_pk primary key( cikey, detail_id )';
ELSE
    execute immediate 'alter table audit_details rename to audit_details_orig';
    execute immediate 'alter table temp_ctas_audit_details rename to audit_details';
END IF;

debug_ctas('audit_details', 'after');

-- CTAS for invoke_message
debug_ctas('invoke_message', 'before');

execute immediate 'create table temp_ctas_invoke_message nologging as select * from invoke_message where state < 1';

IF drop_table
THEN
    execute immediate 'drop table invoke_message';
    execute immediate 'alter table temp_ctas_invoke_message rename to invoke_message ';
    execute immediate 'alter table invoke_message add constraint im_pk primary key( message_guid )';
ELSE
    execute immediate 'alter table invoke_message rename to invoke_message_orig';
    execute immediate 'alter table temp_ctas_invoke_message rename to invoke_message ';
END IF;
execute immediate 'alter table invoke_message modify( state default 0 )';

debug_ctas('invoke_message', 'after');

-- CTAS for dlv_message
debug_ctas('dlv_message', 'before');

vstmt := 'create table temp_ctas_dlv_message nologging as ' ||
         ' ( select * from dlv_message dm    where dm.state < 2 or dm.receive_date >=TO_TIMESTAMP(''RETENTION_PERIOD'') ' ||
        ' UNION ' ||
        ' SELECT dm.* ' ||
        ' FROM cube_instance ci,     dlv_message dm, ' ||
        ' document_ci_ref dcr, ' ||
        ' document_dlv_msg_ref ddmr  WHERE dm.message_guid = ddmr.message_guid ' ||
        ' AND ddmr.dockey = dcr.dockey AND dcr.cikey = ci.cikey)  ';

vstmt := REPLACE(vstmt,'RETENTION_PERIOD',p_older_than);
execute immediate vstmt;

IF drop_table
THEN
    execute immediate 'drop table dlv_message';
    execute immediate 'alter table temp_ctas_dlv_message rename to dlv_message ';
    execute immediate 'alter table dlv_message add constraint dm_pk primary key( message_guid )';
ELSE
    execute immediate 'alter table dlv_message rename to dlv_message_orig';
    execute immediate 'alter table temp_ctas_dlv_message rename to dlv_message ';
END IF;
execute immediate 'alter table dlv_message modify ( state default 0)';

debug_ctas('dlv_message', 'after');

-- CTAS for document_dlv_msg_ref
debug_ctas('document_dlv_msg_ref', 'before');

execute immediate 'create table temp_document_dlv_msg_ref nologging as 
                select * from (select ddmr.* from document_dlv_msg_ref  ddmr, 
                invoke_message im  where  im.message_guid = ddmr.message_guid 
                union 
                select ddmr.* from document_dlv_msg_ref  ddmr, dlv_message dm 
                 where dm.message_guid = ddmr.message_guid)';

IF drop_table
THEN
    execute immediate 'drop table document_dlv_msg_ref';
    execute immediate 'alter table temp_document_dlv_msg_ref rename to document_dlv_msg_ref ';
    execute immediate 'alter table document_dlv_msg_ref add constraint doc_dlv_msg_ref_pk primary key( message_guid, dockey )';
ELSE
    execute immediate 'alter table document_dlv_msg_ref rename to document_dlv_msg_ref_orig';
    execute immediate 'alter table temp_document_dlv_msg_ref rename to document_dlv_msg_ref ';
END IF;

debug_ctas('document_dlv_msg_ref', 'after');

-- CTAS for document_ci_ref
debug_ctas('document_ci_ref', 'before');

execute immediate 'create table temp_document_ci_ref nologging as select * from document_ci_ref dcr where exists ( select 1 from cube_instance ci where ci.cikey = dcr.cikey)'
 ;
IF drop_table
THEN
    execute immediate 'drop table document_ci_ref';
    execute immediate 'alter table temp_document_ci_ref rename to document_ci_ref ';
    execute immediate 'alter table document_ci_ref add constraint doc_ci_reference_pk primary key( cikey, dockey )';
ELSE
    execute immediate 'alter table document_ci_ref rename to document_ci_ref_orig';
    execute immediate 'alter table temp_document_ci_ref rename to document_ci_ref ';
END IF;

debug_ctas('document_ci_ref', 'after');
---------------------------------------------------------------

-- now create temp_xml_dockey table to dump all alive refs for easy join with xml_document table

execute immediate 'create table temp_xml_dockey nologging as 
                    select dockey from document_ci_ref
                    union
                    select dockey from document_dlv_msg_ref
                    union
                    select headers_ref_id as dockey from invoke_message where headers_ref_id IS NOT NULL
                    union
                    select  headers_ref_id as dockey from dlv_message where headers_ref_id IS NOT NULL';
                   
-- CTAS for xml_document table
debug_ctas('xml_document', 'before');

execute immediate 'create table temp_ctas_xml_document nologging storage ( freelists 20) lob( bin ) store as ( storage( initial 16K next 16K ) chunk 8K cache pctversion 10) pctfree 10 pctused 1 as select x.* from XML_DOCUMENT x,temp_xml_dockey txd where txd.dockey = x.dockey';

IF drop_table
THEN
    execute immediate 'drop table xml_document';
    execute immediate 'alter table temp_ctas_xml_document rename to xml_document ';
    execute immediate 'alter table xml_document add constraint xml_doc_pk primary key( dockey )';
ELSE
    execute immediate 'alter table xml_document rename to xml_document_orig';
    execute immediate 'alter table temp_ctas_xml_document rename to xml_document ';
END IF;

debug_ctas('xml_document', 'after');

-- drop temp_xml_dockey
execute immediate 'drop table temp_xml_dockey';

DBMS_OUTPUT.put_line('Finished CTAS');

EXCEPTION
  when others then 
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);
    DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);
    execute immediate 'drop table temp_xml_dockey';
   
END purge_bpel_ctas;
/
SHOW ERRORS
