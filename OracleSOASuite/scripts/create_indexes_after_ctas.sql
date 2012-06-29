Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/create_indexes_after_ctas.sql /st_pcbpel_10.1.3.1/1 2010/05/05 11:59:02 ramisra Exp $
Rem
Rem create_indexes_after_ctas.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      create_indexes_after_ctas.sql 
Rem
Rem    DESCRIPTION
Rem      This script needs to be run after running of CTAS to recreate indexes
Rem
Rem    NOTES
Rem      If Customer has modified existing index or created new index, this script needs to be 
Rem      customized to take into account those indexes.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     01/26/10 - This script needs to be run after CTAS to create
Rem                           indexes
Rem    ramisra     01/26/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

create index ci_custom2 on cube_instance( domain_ref, process_id, revision_tag, state );
create index ci_custom3 on cube_instance( test_run_id );
create index state_ind on cube_instance( state );
create index ci_index_1 on ci_indexes( index_1 );
create index ci_index_2 on ci_indexes( index_2 );
create index ci_index_3 on ci_indexes( index_3 );
create index ci_index_4 on ci_indexes( index_4 );
create index ci_index_5 on ci_indexes( index_5 );
create index ci_index_6 on ci_indexes( index_6 );
create index sa_fk on scope_activation( cikey, scope_id, action );
create index wi_expired on work_item( exp_date );
create index wi_stranded on work_item( modify_date );
create index wx_fk on wi_exception( cikey, node_id, scope_id, count_id );
create index wf_fk1 on wi_fault( cikey, node_id, scope_id, count_id );
create index wf_fk2 on wi_fault( fault_name );
create index at_fk on audit_trail( cikey );
create index st_fk on sync_trail( cikey );
create index ss_fk on sync_store( cikey );
create index dm_conversation on dlv_message( conv_id, operation_name );
create index ds_fk on dlv_subscription( cikey );
create index ds_conversation on dlv_subscription( conv_id );
create index ds_operation on dlv_subscription( process_id, operation_name );
create index im_master_conv_id on invoke_message( master_conv_id );
create index ddmr_dockey on document_dlv_msg_ref(dockey);
create index pl_fk on process_log( process_id, revision_tag );
create index nc_corr on native_correlation( native_correlation_id );
create index nc_conv on native_correlation( conversation_id );
alter index ci_pk rebuild reverse;
alter index xml_doc_pk rebuild reverse; 
alter index im_pk rebuild reverse;
alter index doc_dlv_msg_ref_pk rebuild reverse; 
