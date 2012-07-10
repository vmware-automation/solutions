Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/upgrade_10133_10134_olite.sql /st_pcbpel_10.1.3.1/11 2009/06/03 00:37:24 nverma Exp $
Rem
Rem upgrade_10133_10134_olite.sql
Rem
Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      upgrade_10133_10134_olite.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This script can be used to upgrade orabpel schema on olite database from 10.1.3.3.0 to 10.1.3.4.0
Rem
Rem    NOTES
Rem      This script can be used to upgrade orabpel schema on olite database from 10.1.3.3.0 to 10.1.3.4.0
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nverma      04/27/09 - Backport nverma_bug-8463393 from
Rem    nverma      04/14/09 - Backport nverma_bug-7171739 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     06/05/08 - 
Rem    ralmuell    03/28/08 - Sensor schema change for 6819678
Rem    ramisra     03/17/08 - Backport ramisra_bug-6845586 from
Rem                           st_pcbpel_10.1.3.1
Rem    atam        03/06/08 - update version
Rem    nverma      01/29/08 - Upgrade script (10.1.3.3.0 to 10.1.3.4.0) for orabpel schema on olite
Rem                           database.
Rem    nverma      01/29/08 - Created
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

ALTER TABLE DLV_MESSAGE MODIFY (CONV_ID VARCHAR2(256));

/*
bug 7171739: an olite issue: we need to drop the pkey constraint as a workaround.
*/

ALTER TABLE DLV_SUBSCRIPTION DROP CONSTRAINT DS_PK;

ALTER TABLE DLV_SUBSCRIPTION MODIFY (CONV_ID VARCHAR2(256));

/*
bug 7171739: an olite issue: we temprarily dropped the constraint; so add it back.
*/

ALTER TABLE DLV_SUBSCRIPTION ADD CONSTRAINT DS_PK PRIMARY KEY(CONV_ID, SUBSCRIBER_ID);

ALTER TABLE INVOKE_MESSAGE MODIFY (CONV_ID VARCHAR2(256));
ALTER TABLE INVOKE_MESSAGE MODIFY (MASTER_CONV_ID VARCHAR2(256));
ALTER TABLE NATIVE_CORRELATION MODIFY (CONVERSATION_ID VARCHAR2(1000));
ALTER TABLE NATIVE_CORRELATION MODIFY (NATIVE_CORRELATION_ID VARCHAR2(1000));
ALTER TABLE CUBE_INSTANCE MODIFY (CONVERSATION_ID VARCHAR2(256));
ALTER TABLE TASK MODIFY (CONVERSATION_ID VARCHAR2(256));
ALTER TABLE WORK_ITEM MODIFY (CUSTOM_ID VARCHAR2(256));

/**
* increase column size for bug 	6802070
*/

/*
bug 7171739: an olite issue: we need to drop the pkey constraint as a workaround.
*/

ALTER TABLE DLV_SUBSCRIPTION DROP CONSTRAINT DS_PK;

ALTER TABLE DLV_SUBSCRIPTION MODIFY (SUBSCRIBER_ID VARCHAR2(256));

/*
bug 7171739: an olite issue: we temprarily dropped the constraint; so add it back.
*/

ALTER TABLE DLV_SUBSCRIPTION ADD CONSTRAINT DS_PK PRIMARY KEY(CONV_ID, SUBSCRIBER_ID);


ALTER TABLE DLV_MESSAGE MODIFY (RES_SUBSCRIBER VARCHAR2(256));

/**
* Creating index on doc_key to improve performance of purge_instances_oracle
* Bug 6501312
*/
CREATE INDEX DDMR_DOCKEY ON DOCUMENT_DLV_MSG_REF(DOCKEY);

/**
* Bug 7027343
*/
CREATE INDEX CI_CUSTOM4 ON CUBE_INSTANCE (MODIFY_DATE);


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
 * Changing the column type of error_message (in table activity_sensor_values) 
 * to CLOB for RFI 6650525, base bug 6395060.
 */

alter table activity_sensor_values add error_message_temp clob;

update activity_sensor_values set error_message_temp=error_message;

alter table activity_sensor_values drop column error_message;

alter table activity_sensor_values add error_message clob;

update activity_sensor_values set error_message=error_message_temp;

alter table activity_sensor_values drop column error_message_temp;

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
modify constraint activity_sensor_pk enable;

 alter table variable_sensor_values
modify constraint variable_sensor_pk enable;

 alter table variable_sensor_values
modify constraint variable_sensor_fk1 enable;

 alter table fault_sensor_values
modify constraint fault_sensor_pk enable;

drop index activity_sensor_values_indx;

create index activity_sensor_values_indx
    on activity_sensor_values(process_instance_id, sensor_name, action_name);

/**
 * Update the schema version so the runtime can detect the change
 */
update version set guid = '10.1.3.4.0';
update version_server set guid = '10.1.3.4.0';

COMMIT;
