Rem
Rem $Header: upgrade_10133_10134_oracle.sql 05-jun-2008.19:46:27 ramisra Exp $
Rem
Rem upgrade_10133_10134_oracle.sql
Rem
Rem Copyright (c) 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      upgrade_10133_10134_oracle.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This sql script will be used for upgrading 10.1.3.3.0 orabpel schema to 10.1.3.4.0
Rem
Rem    NOTES
Rem      This sql script will be used for upgrading 10.1.3.3.0 orabpel schema to 10.1.3.4.0
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     06/05/08 - 
Rem    atam        05/22/08 - Change admin_list_cx to outer join
Rem    atam        04/17/08 - Backport atam_bug-6977826 from st_pcbpel_10.1.3.1
Rem    ramisra     04/09/08 - Backport ramisra_bug-6802070 from
Rem                           st_pcbpel_10.1.3.1
Rem    ralmuell    03/28/08 - Sensor schema change for 6819678
Rem    atam        03/06/08 - update version
Rem    nverma      01/29/08 - RFI 6650525
Rem    mchinnan    01/25/08 - Added three columns for storing audit trail meta info.
Rem    ramisra     01/23/08 - Upgrading 10.1.3.3.0 orabpel schema to 10.1.3.4.0
Rem    ramisra     01/23/08 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

/**
* Increase the colum size of conversation id Bug 6494921
*/
ALTER TABLE DLV_MESSAGE MODIFY CONV_ID VARCHAR2(256);
ALTER TABLE DLV_SUBSCRIPTION MODIFY CONV_ID VARCHAR2(256);
ALTER TABLE INVOKE_MESSAGE MODIFY CONV_ID VARCHAR2(256);
ALTER TABLE INVOKE_MESSAGE MODIFY MASTER_CONV_ID VARCHAR2(256);
ALTER TABLE NATIVE_CORRELATION MODIFY CONVERSATION_ID VARCHAR2(1000);
ALTER TABLE NATIVE_CORRELATION MODIFY NATIVE_CORRELATION_ID VARCHAR2(1000);
ALTER TABLE CUBE_INSTANCE MODIFY CONVERSATION_ID VARCHAR2(256);
ALTER TABLE TASK MODIFY CONVERSATION_ID VARCHAR2(256);
ALTER TABLE WORK_ITEM MODIFY CUSTOM_ID VARCHAR2(256);

/**
* increase column size for bug 	6802070
*/
ALTER TABLE DLV_SUBSCRIPTION MODIFY SUBSCRIBER_ID VARCHAR2(256);
ALTER TABLE DLV_MESSAGE MODIFY RES_SUBSCRIBER VARCHAR2(256);

/**
* Creating index on doc_key to improve performance of purge_instances_oracle
* Bug 6501312
*/
CREATE INDEX DDMR_DOCKEY ON DOCUMENT_DLV_MSG_REF(DOCKEY);

/**
* Bug 7027343
*/
CREATE INDEX CI_CUSTOM4 ON CUBE_INSTANCE (MODIFY_DATE DESC) NOPARALLEL;

/**
* changing the storage parameter of LOB column message, Bug 6619720
*/
ALTER TABLE WI_FAULT MODIFY LOB (MESSAGE) (CACHE);
ALTER TABLE WI_FAULT MODIFY LOB (MESSAGE) (PCTVERSION 10);

/**
 * New columns on WFUserTaskViewGrant (base bug 5971534, RFI 6027809)
 */
ALTER TABLE WFUserTaskViewGrant
  ADD (
         granteeType        VARCHAR2(20),
         applicationContext VARCHAR2(200)
      ) ;

/**
 * New columns for cube_instance table (base bug 6669055, RFI 6771447)
 */
alter table cube_instance add (
    at_count_id integer,
    at_event_id integer,
    at_detail_id integer
  );

/**
 * Changing the column type of error_message to NCLOB for RFI 6650525, base-bug 6395060.
 */
alter table activity_sensor_values add error_message_temp nclob;

update activity_sensor_values set error_message_temp=error_message;

alter table activity_sensor_values drop column error_message;

alter table activity_sensor_values add error_message nclob;

update activity_sensor_values set error_message=error_message_temp;

/**
 * Include cube_instance.cikey in primary key of sensor value tables (RFI 6923016)
 */
alter table activity_sensor_values drop column error_message_temp;

alter table fault_sensor_values drop primary key;
alter table variable_sensor_values drop primary key;
alter table activity_sensor_values drop primary key cascade;

alter table activity_sensor_values
  add constraint activity_sensor_pk primary key(id, process_instance_id);

alter table variable_sensor_values
  add constraint variable_sensor_pk primary key(id, process_instance_id);

alter table variable_sensor_values
  add constraint variable_sensor_fk1 foreign key(activity_sensor_id, process_instance_id)
                                     references activity_sensor_values(id, process_instance_id);

alter table fault_sensor_values
  add constraint fault_sensor_pk primary key(id, process_instance_id);

 alter table activity_sensor_values
enable constraint activity_sensor_pk;

 alter table variable_sensor_values
enable constraint variable_sensor_pk;

 alter table variable_sensor_values
enable constraint variable_sensor_fk1;

 alter table fault_sensor_values
enable constraint fault_sensor_pk;

drop index activity_sensor_values_indx;

create index activity_sensor_values_indx
    on activity_sensor_values(process_instance_id, sensor_name, action_name);


create or replace view admin_list_wi
as select wi.cikey, wi.node_id, wi.scope_id, wi.count_id,
          wi.creation_date wi_creation_date, wi.creator wi_creator,
          wi.modify_date wi_modify_date, wi.modifier wi_modifier,
          wi.state wi_state, wi.transition,
          wi.exp_date, exp_flag, wi.priority wi_priority,
          wi.label, wi.custom_id, wi.comments, wi.reference_id,
          wi.execution_type,
          ci.domain_ref as ci_domain_ref,
          ci.process_id process_id, ci.revision_tag revision_tag,
          ci.process_guid process_guid,
          ci.title title, ci.root_id, ci.parent_id, fault_name,
          index_1, index_2, index_3, index_4, index_5, index_6
   from cube_instance ci, work_item wi, wi_fault fault, ci_indexes indexes
   where ci.cikey = wi.cikey (+)
   and fault.cikey (+) = wi.cikey
   and fault.node_id (+) = wi.node_id
   and fault.scope_id (+) = wi.scope_id
   and fault.count_id (+) = wi.count_id
   and indexes.cikey (+) = ci.cikey ;

create or replace view admin_list_cx
as select ci.cikey, domain_ref as ci_domain_ref, process_id, revision_tag,
          creation_date ci_creation_date, creator ci_creator,
          modify_date ci_modify_date, modifier ci_modifier,
          state ci_state, priority ci_priority, title,
          status, stage, conversation_id, metadata,
          root_id, parent_id,
          index_1, index_2, index_3, index_4, index_5, index_6, ci.test_run_id
   from cube_instance ci, ci_indexes cx
   where ci.cikey = cx.cikey (+);


/**
 * Update the schema version so the runtime can detect the change
 */
update version set guid = '10.1.3.4.0';
update version_server set guid = '10.1.3.4.0';

COMMIT;
