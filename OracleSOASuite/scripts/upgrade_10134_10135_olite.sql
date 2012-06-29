Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vnanjund    07/09/09 - Backport vnanjund_bug-8655721 from
Rem                           st_pcbpel_10.1.3.1
Rem    mchinnan    07/07/09 - Backport mchinnan_bug-8636836 from
Rem                           st_pcbpel_10.1.3.1
Rem    vnanjund    07/06/09 - olite fix
Rem    mchmiele    07/02/09 - Backport mchmiele_bug-8613538 from
Rem    mchmiele    07/01/09 - Backport mchmiele_bug-8613538 from
Rem                           st_pcbpel_10.1.3.1
Rem    mchmiele    06/30/09 - Migrating processes with correlation sets
Rem    mchmiele    06/30/09 - Backport mchmiele_bug-8613538 from
Rem                           st_pcbpel_10.1.3.1
Rem    mchmiele    06/29/09 - Olite resource tables
Rem    mchmiele    06/29/09 - Backport mchmiele_bug-8613538 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     05/11/09 - Backport ramisra_bug-8498498 from
Rem                           st_pcbpel_10.1.3.1
Rem    nverma      04/27/09 - Backport nverma_bug-8463393 from
Rem                           st_pcbpel_10.1.3.1
Rem    mnanal      03/09/09 - Backport mnanal_bug-7286083 from
Rem                           st_pcbpel_10.1.3.1
Rem    mnanal      02/10/09 - RFI bug 7022475
Rem    ramisra     01/02/09 - Backport ramisra_bug-7577303 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     09/17/08 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- Update version
--
update version set guid = '10.1.3.5.0' where dbtype = 'olite';
commit;

/*
 * fix for bug 6211557
 */

CREATE table temp_attachment 
(
key varchar2( 50 ),
bin blob
);
INSERT into temp_attachment (key,bin) SELECT key, bin FROM attachment;

DROP table attachment;

CREATE table attachment
(
key varchar2( 50 ),
content_type varchar2( 50 ),
bin blob,
constraint att_pk primary key( key )
);
INSERT into attachment (key,bin) SELECT key, bin FROM temp_attachment;

DROP table temp_attachment;


/**
* Add constraint in WFRoutingSlip table (Bug 6510734)
*/
DELETE FROM WFRoutingSlip rs WHERE NOT EXISTS (SELECT 1 FROM WFTask t WHERE t.taskid = rs.taskid);
ALTER TABLE WFRoutingSlip ADD CONSTRAINT RoutingSlipTaskConstraint FOREIGN KEY (taskId) REFERENCES WFTask (taskId) ON DELETE CASCADE;

/**
 * Bug 7321408
 */
ALTER TABLE process_descriptor ADD (last_change_time NUMBER(38));

UPDATE process_descriptor SET last_change_time=(SELECT (SYSDATE - TO_DATE('01-01-1970','DD-MM-YYYY')) * (24*60*60*1000) FROM DUAL);

/**
* Bug 6955137 
*/
create index WFTaskTaskGroupId_I on WFTask(taskGroupId);
create index WFTaskWorkflowPattern_I on WFTask(workflowPattern);

/**
 * Bug 7577303, remove old properties
 */

 DELETE FROM domain_properties WHERE prop_id IN  ( 'dspMinThreads' , 'dspMaxThreads', 'dspInvokeAllocFactor' ); 

/**
 * For bug 7154301
 */
ALTER TABLE dlv_subscription ADD ( partner_link VARCHAR2(256) );

UPDATE VERSION SET guid = '10.1.3.5.0';

/* Bug 7022475: cluster reboot sets up dual expiry events */
alter table WFTaskTimer add key varchar(100);

/* 
 * Bug 7286083 
 */
alter table WFAttachment modify (encoding varchar(100));

/*
 * Bug 7429615
 */

ALTER TABLE dlv_subscription DROP CONSTRAINT ds_pk;
ALTER TABLE dlv_subscription ADD CONSTRAINT ds_pk PRIMARY KEY (subscriber_id);
DROP INDEX ds_conversation;
CREATE INDEX ds_conversation ON dlv_subscription( conv_id );
DROP INDEX ds_operation;
CREATE INDEX ds_operation ON dlv_subscription( process_id, operation_name );

/** Add cx_resource, cx_content tables */
drop table cx_resource;

/**
 * A resource table is used to access hierarchically organized data.
 * This primary reason is to allow configuration items that are domain wide to be stored
 * int the db and accessible by any node. The API that handles them is com.oracle.resource.*
 * Only leaf nodes that are of type "f" (file) will have cx_content table entry.
 */

create table cx_resource
(
    id    integer,
    pid   integer,
   name   varchar(64),
   kind   char(1),
   modify_date timestamp default sysdate,
   constraint cx_resource_pk primary key( id ),
   constraint cx_resource_no_dups_pk unique (pid,name)
);

create index cx_resource_name_idx on cx_resource (name);
create index cx_resource_pid_idx on cx_resource (pid);

/** Here is the 2nd one, call it "cx_content"*/

drop table cx_content;
create table cx_content
(
        id       integer,       /* id of the resource content, pointing to Resource.id */
        content  blob,             /* the content as a blob */
    constraint cx_content_pk primary key( id )
);


-- Add debugger tables
--
@@debugger_olite.ddl

/*
 * Bug 8596431
 * Add partitioning key column
 */
ALTER TABLE work_item ADD (ci_partition_date TIMESTAMP);
ALTER TABLE dlv_subscription  ADD (ci_partition_date TIMESTAMP);
ALTER TABLE ci_indexes ADD (ci_partition_date TIMESTAMP);
ALTER TABLE wi_exception ADD (ci_partition_date TIMESTAMP);
ALTER TABLE wi_fault ADD (ci_partition_date TIMESTAMP);
ALTER TABLE document_ci_ref ADD (ci_partition_date TIMESTAMP);
ALTER TABLE audit_trail ADD (ci_partition_date TIMESTAMP);
ALTER TABLE audit_details ADD (ci_partition_date TIMESTAMP);
ALTER TABLE cube_scope ADD (ci_partition_date TIMESTAMP);

ALTER TABLE attachment ADD (ci_partition_date TIMESTAMP);
ALTER TABLE attachment_ref ADD (ci_partition_date TIMESTAMP);

ALTER TABLE document_dlv_msg_ref ADD (dlv_partition_date TIMESTAMP);

ALTER TABLE xml_document ADD (doc_partition_date TIMESTAMP);

create or replace view admin_list_cx
as select ci.cikey, domain_ref as ci_domain_ref, process_id, revision_tag,
          creation_date ci_creation_date, creator ci_creator,
          modify_date ci_modify_date, modifier ci_modifier,
          state ci_state, priority ci_priority, title,
          status, stage, conversation_id, metadata,
          root_id, parent_id, test_run_id,
          index_1, index_2, index_3, index_4, index_5, index_6, ci.test_run_id
   from cube_instance ci, ci_indexes cx
   where ci.cikey = cx.cikey (+);

/**
 * Database tables for DB-based cluster support.  Expected to be
 * added on top of 10.1.3.4.0 MLR8 database schema.
 */
drop table cluster_message;
drop table cluster_master;
drop table cluster_node;

/**
 * Cluster messages used to synchronize deployment and configuration
 * changes across BPEL cluster nodes.
 */
create table cluster_message
(
    domain_id       varchar2( 50 )    not null,
    node_id         integer           not null,
    msg_type        integer           not null,
    msg_text        varchar2( 1000 ),
    msg_date        date              not null
);

create table cluster_master
(
    node_id         integer           not null,
    dummy_col       varchar2( 1 )     null
);
insert into cluster_master( node_id ) values( -1 );
commit;

create table cluster_node
(
    node_id         integer           not null,
    ip_address      varchar2( 100 )   null,
    last_update     date              not null
);

/**
 * Add deleted column to domain.  Needed for edge case where domain
 * is not present in the DB but found locally, but the domain really
 * has been removed from the cluster.
 */
alter table domain add
(
    deleted smallint default 0 not null
);

/**
 * Update the DB version tables
 */
update version set guid = '10.1.3.5.0';
update version_server set guid = '10.1.3.5.0';
commit;


