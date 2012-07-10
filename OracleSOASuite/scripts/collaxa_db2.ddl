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
-- Collaxa Database Schema for DB2
--
-- The tables and views defined within this file may be installed on
-- your DB2 server by using the db2 command-line utility.
-- For example:
--
-- (For the instructions here we will assume DB2 is installed in c:/ibm)
--
-- db2cmd
-- db2 connect to <db_name> user <db_user>
-- db2 call sqlj.remove_jar( 'cx_db2' )
-- db2 call sqlj.install_jar( 'file:c:/ibm/sqllib/function/cx_db2.jar', 'cx_db2' )
-- db2 -td@ -vf collaxa_db2.ddl
--
-- If you need to rebuild your 
--
-- Before installing the database schema, please ensure that the user
-- has the necessary permissions.
--


--
-- Drop all tables/views/procedures before we begin
--
drop view work_list@
drop view admin_list_ci@
drop view admin_list_wi@
drop table ci_id_range@
drop table scope_activation@
drop table document@
drop table audit_trail@
drop table dynamic_group@
drop table wi_exception@
drop table work_item@
drop table cube_scope@
drop table cube_instance@
drop table loan_customer@
drop table version@
drop table tx_superior@
drop table tx_inferior@
drop table tx_message@
drop table dlv_message@
drop table dlv_subscription@
drop table invoke_message@
drop procedure cx_insert_sa@
drop procedure cx_insert_wx@
drop procedure cx_delete_ci@
drop procedure cx_delete_cis@
drop procedure cx_delete_cis_by_pcs_id@


--
-- version
--
-- Version information; allows run-time engine to check if correct database
-- schema has been installed.
--
create table version
(
    guid            varchar( 38 ),
    dbtype          varchar( 50 )
)@
insert into version values( '2.0.12', 'db2' )@
commit@

--
-- ci_id_range
--
-- Cube instance key generator; contains next range of valid instance
-- keys static generator class can batch.
--
create table ci_id_range
(
    next_range      bigint          not null
)@
insert into ci_id_range( next_range ) values( 1 )@
commit@

--
-- cube_instance
--
-- Stores generated cube instances; master table of system.  Cube instances
-- are unique across all processes for one collaxa installation.
--
create table cube_instance
(
    cikey           bigint          not null,
    process_id      varchar( 100 ),
    process_name    varchar( 100 ),
    creation_date   timestamp,
    creator         varchar( 100 ),
    modify_date     timestamp,
    modifier        varchar( 100 ),
    state           integer,
    priority        integer,
    title           varchar( 50 ),
    status          varchar( 100 ),
    stage           varchar( 100 ),
    conversation_id varchar( 100 ),
    debug_mode      smallint        default 0   not null,
    scope_md5       varchar( 38 ),
    scope_size      integer,
    revision_tag    varchar( 50 ),
    process_guid    varchar( 38 ),
    process_type    integer,
    metadata        varchar( 1000 ),
    constraint ci_pk primary key( cikey )
)@

create index ci_custom on cube_instance( cikey, conversation_id )@

--
-- cube_scope
--
-- Stores generated scopes of generated cube instances.
--
create table cube_scope
(
    cikey           bigint          not null,
    modify_date     timestamp,
    scope_bin       blob( 2000000000 ) not logged  not compact,
    constraint cs_pk primary key( cikey )
)@

create index cs_fk on cube_scope( cikey )@

--
-- scope_activation
--
-- Scope activation table - scopes that need to be routed/closed/compensated
-- are inserted into this table.  In case of system failure, we can pick up and
-- re-perform any scopes that should have been done before the failure.
-- We're re-creating JMS using this strategy, but then at least we can
-- control the re-delivery of the message at failure.
--
-- The process_guid column is replicated here from cube_instance to avoid
-- using a join when the recovery agent runs.
--
create table scope_activation
(
    cikey           bigint          not null,
    scope_id        varchar( 15 ),
    action          integer,
    creation_date   timestamp,
    modify_date     timestamp,
    process_guid    varchar( 38 )
)@

create index sa_fk on scope_activation( cikey, scope_id, action )@

--
-- work_item
--
-- Stores generated work items; composite key for work items consists of
-- cube instance key, node id work item positioned at, and the scope id
-- for the work item's scope.
--
-- The process_guid column is replicated here from cube_instance to avoid
-- using a join when the recovery agent runs.
--
create table work_item
(
    cikey           bigint                  not null,
    node_id         varchar( 15 )           not null,
    scope_id        varchar( 15 )           not null,
    count_id        integer                 not null,
    creation_date   timestamp,
    creator         varchar( 100 ),
    modify_date     timestamp,
    modifier        varchar( 100 ),
    state           integer,
    transition      integer,
    exception       smallint    default 0   not null,
    exp_date        timestamp,
    exp_flag        smallint    default 0   not null,
    priority        integer,
    group_flag      smallint    default 0   not null,
    performer_id    varchar( 100 ),
    label           varchar( 50 ),
    custom_id       varchar( 100 ),
    comments        varchar( 256 ),
    reference_id    varchar( 128 ),
    performer_type  integer     default 0   not null,
    process_guid    varchar( 38 ),
    execution_type  integer     default 0   not null,
    first_delay     integer,
    delay           integer,
    retry_count     integer,
    constraint wi_pk primary key( cikey, node_id, scope_id, count_id )
)@

create index wi_fk on work_item( cikey )@
create index wi_expired on work_item( state, exp_date, exp_flag, exception )@
create index wi_stranded on work_item( modify_date, state, transition, exception )@

--
-- wi_exception
--
-- Stores exception messages generated by failed attempts to perform, manage
-- or complete a workitem.  Each failed attempt is logged as an exception
-- message.
--
create table wi_exception
(
    cikey           bigint          not null,
    node_id         varchar( 15 ),
    scope_id        varchar( 15 ),
    count_id        integer,
    retry_count     integer,
    retry_date      timestamp,
    message         varchar( 2000 )
)@

create index wx_fk on wi_exception( cikey, node_id, scope_id, count_id )@

--
-- dynamic_group
--
-- Stores dynamic/static group membership information for work items that are
-- assigned to multiple users.
--
create table dynamic_group
(
    cikey           bigint          not null,
    node_id         varchar( 15 ),
    scope_id        varchar( 15 ),
    count_id        integer,
    performer_id    varchar( 100 )
)@

create index dg_fk on dynamic_group( cikey, node_id, scope_id, count_id )@

--
-- document
--
-- document persistence table; all large objects in the system persist themselves
-- here.
--
create table document
(
    dockey           varchar( 50 )   not null,
    cikey           bigint          not null,
    classname       varchar( 100 ),
    bin_md5         varchar( 38 ),
    bin_size        integer,
    bin             blob( 2000000000 ) not logged  not compact,
    modify_date     timestamp,
    constraint doc_pk primary key( bdkey )
)@

create index doc_fk on document( cikey )@

--
-- tx_inferior
--
-- Stores information about BTP inferiors that have enrolled in a transaction.
-- All necessary information required to callback the inferior is stored.
--
create table tx_inferior
(
    inferior_id          varchar( 255 )     not null,
    tx_id                varchar( 255 )     not null,
    cikey                bigint,
    inferior_status      smallint,
    engine_action        smallint,
    inferior_address     varchar( 255 ),
    inferior_protocol    varchar( 20 ),
    service_location     varchar( 255 ),
    start_date           timestamp,
    modify_date          timestamp,
    exp_date             timestamp,
    correlation_id       varchar( 255 ),
    other_attributes     varchar( 2000 ),
    constraint txi_pk primary key( inferior_id, tx_id )
)@
create index tx_inf_idx on tx_inferior( cikey )@

--
-- tx_message
--
-- Stores inferior transaction messages that needs to be retried later on
-- The transaction manager will fetch these messsage in a periodic
-- manner and will try to processes them until it reaches the max.
-- retry count.
--
create table tx_message
(
    inferior_id          varchar( 255 )     not null,
    tx_id                varchar( 255 )     not null,
    operation            smallint,
    retry_count          smallint,
    retry_date           timestamp,
    message              varchar( 2000 ),
    constraint txm_pk primary key( inferior_id, tx_id )
)@

--
-- tx_superior
--
-- Stores information about BTP superiors that have started a transaction.
-- Each cube instance may have multiple superiors associated with it.
--
create table tx_superior
(
    tx_id                varchar( 255 )     not null,
    tx_type              smallint,
    cikey                bigint,
    initiator_id         varchar( 255 ),
    process_guid         varchar( 38 ),
    method_name          varchar( 255 ),
    status               smallint           not null,
    superior_address     varchar( 255 ),
    superior_protocol    varchar( 20 ),
    other_attributes     varchar( 2000 ),
    superior_id          varchar( 255 ),
    start_date           timestamp,
    modify_date          timestamp,
    exp_date             timestamp,
    constraint txs_pk primary key( tx_id )
)@

create index txs_expired on tx_superior( status, exp_date, superior_id )@
create index txs_instance on tx_superior( cikey )@

--
-- audit_trail
--
-- Stores record of actions taken on an instance (application, system,
-- administrative and errors).
--
create table audit_trail
(
    cikey           bigint          not null,
    count           smallint,
    location        smallint				not null,
    log0            varchar( 1000 ),
    log1_size       smallint,
    log1            blob( 2000000000 ) not logged  not compact,
)@

create index at_fk on audit_trail( cikey )@

--
-- dlv_message
--
-- Stores objects transfered between CubeEngine and SOAP/JMS transports.
--
create table dlv_message
(
    conv_id             varchar( 128 )          not null,
    conv_type           integer,
    message_guid        varchar( 38 )           not null,
    process_id          varchar( 100 ),
    revision_tag        varchar( 50 ),
    operation_name      varchar( 128 ),
    receive_date        timestamp,
    state               integer    default 0   not null,
    bin_md5             varchar( 38 ),
    bin_size            integer,
    bin                 blob( 2000000000 )      not logged  not compact,
    constraint dm_pk primary key( message_guid )
)@

create index dm_conversation on dlv_message( conv_id, operation_name )@

--
-- dlv_subscription
--
-- Stores message subscriptions from engine.
--
create table dlv_subscription
(
    conv_id             varchar( 128 )      not null,
    conv_type           integer,
    cikey               bigint              not null,
    process_id          varchar( 100 )      not null,
    revision_tag        varchar( 50 )       not null,
    process_guid        varchar( 38 )       not null,
    operation_name      varchar( 128 ),
    subscriber_id       varchar( 128 )      not null,
    service_name        varchar( 128 ),
    subscription_date   timestamp,
    state               integer    default 0   not null,
    bin_md5             varchar( 38 ),
    bin_size            integer,
    bin                 blob( 2000000000 )  not logged  not compact,
    constraint ds_pk primary key( conv_id, subscriber_id )
)@

create index ds_fk on dlv_subscription( cikey )@
create index ds_conversation on dlv_subscription( process_id, operation_name )@

--
-- invoke_message
--
-- All the async invoke messages are stored in this table before dispatching to the engine.
--
create table invoke_message
(
	process_id        varchar( 100 ),
    operation_name    varchar( 128 ),
    message_guid      varchar( 38 ),
    state             integer     default 0       not null,
    properties        varchar( 2000 ),
    bin_size            integer,
    bin                 blob( 2000000000 )      not logged  not compact,
    constraint im_pk primary key( message_guid )
)@

create index im_conversation on dlv_message( message_guid, state )@


--
-- view work_list
--
-- Work list of current open items; a join between cube_instance and
-- work_item tables.  Each row contains:
--     + instance id
--     + instance title
--     + process id
--     + instance priority
--     + instance state
--     + work item label
--     + work item expiration date
--     + work item priority
--     + work item state
--     + work item performer id
--
create view work_list
as select ci.cikey, wi.node_id, wi.scope_id, wi.count_id,
          ci.title, ci.process_id, ci.priority ci_priority, ci.state ci_state,
          wi.label, wi.exp_date, wi.priority wi_priority, wi.state wi_state,
          wi.performer_id
   from cube_instance ci, work_item wi
   where ci.cikey = wi.cikey and
         ( wi.state = 1 or wi.state = 2 or wi.state = 3 ) and
         ( wi.performer_id != 'cx-system' and wi.performer_id != 'cx-noop' )@

--
-- view admin_list_ci
--
-- Simple query on the cube_instance table ... any columns that the
-- cube_instance table has in common with the work_item table are
-- aliased.  The views admin_list_ci, admin_list_wi and admin_list all
-- have the same aliased column names ... this is so the interface to the
-- administration finder class is consistent regardless of the query.
--
-- Each row contains (incl alias):
--     + instance id                  (cikey)
--     + instance process id          (process_id)
--     + instance process name        (process_name)
--     + instance revision tag        (revision_tag)
--     + instance creation date       (ci_creation_date)
--     + instance creator             (ci_creator)
--     + instance modify date         (ci_modify_date)
--     + instance modifier            (ci_modifier)
--     + instance state               (ci_state)
--     + instance priority            (ci_priority)
--     + instance title               (title)
--     + instance status              (status)
--     + instance stage               (stage)
--     + instance conversation id     (conversation_id)
--     + instance metadata            (metadata)
--     + instance debug mode flag     (debug_mode)
--
create view admin_list_ci
as select cikey, process_id, process_name, revision_tag,
          creation_date ci_creation_date, creator ci_creator,
          modify_date ci_modify_date, modifier ci_modifier,
          state ci_state, priority ci_priority, title,
          status, stage, conversation_id, metadata, debug_mode
   from cube_instance@

--
-- view admin_list_wi
--
-- Simple query on the work_item table ... any columns that the
-- work_item table has in common with the cube_instance table are
-- aliased.  The views admin_list_ci, admin_list_wi and admin_list all
-- have the same aliased column names ... this is so the interface to the
-- administration finder class is consistent regardless of the query.
--
-- Each row contains (incl alias):
--     + instance id                  (cikey)
--     + work item node id            (node_id)
--     + work item scope id           (scope_id)
--     + work item count id           (count_id)
--     + work item creation date      (wi_creation_date)
--     + work item creator id         (wi_creator)
--     + work item modify date        (wi_modify_date)
--     + work item modifier           (wi_modifier)
--     + work item state              (wi_state)
--     + work item priority           (wi_priority)
--     + work item transition         (transition)
--     + work item expiration date    (exp_date)
--     + work item expiration flag    (exp_flag)
--     + work item exception flag     (exception)
--     + work item group flag         (group_flag)
--     + work item performer id       (performer_id)
--     + work item label              (label)
--     + work item custom id          (custom_id)
--     + work item comments           (comments)
--     + work item reference id       (reference_id)
--     + instance process id          (process_id)
--     + instance revision tag        (revision_tag)
--     + instance title               (title)
--
create view admin_list_wi
as select wi.cikey, wi.node_id, wi.scope_id, wi.count_id,
          wi.creation_date wi_creation_date, wi.creator wi_creator,
          wi.modify_date wi_modify_date, wi.modifier wi_modifier,
          wi.state wi_state, wi.transition,
          wi.exp_date, exp_flag, exception, wi.priority wi_priority,
          wi.group_flag, wi.performer_id, wi.label, wi.custom_id,
          wi.comments, wi.reference_id,
          ci.process_id process_id, ci.revision_tag revision_tag,
          ci.title title
   from cube_instance ci left outer join work_item wi
   on ci.cikey = wi.cikey@

-- <tables for sample processes>

--
-- loan_customer
--
-- Table used to store customer information for loan EJB.
--
create table loan_customer
(
    ssn             varchar( 11 ),
    name            varchar( 50 ),
    email           varchar( 30 )       not null,
    provider        varchar( 20 ),
    status          char( 1 ),
    constraint lc_pk primary key( email )
)@
insert into loan_customer values( '123-12-1234','demo1', 'demo1@collaxa.com', null, null )@
insert into loan_customer values( '087-65-4321','demo2', 'demo2@collaxa.com', null, null )@
commit@

-- </tables for sample processes>


--
-- procedure cx_insert_sa
--
-- Stored procedure to do a "smart" insert of a scope activation message.
-- If a scope activation message already exists, don't bother to insert
-- and return 0 (this process can happen if two concurrent threads generate
-- an activation message for the same scope - say the method scope for
-- example - only one will insert properly; but both threads will race to
-- consume the activation message).
--
create procedure cx_insert_sa( in p_cikey integer,
                               in p_scope_id varchar( 15 ),
                               in p_process_guid varchar( 38 ),
                               in p_creation_date timestamp,
                               out r_success integer )
external name 'cx_db2:com.collaxa.cube.engine.adaptors.db2.DB2StoredProcedures.cx_insert_sa'
language java parameter style java fenced
modifies sql data@

--
-- procedure cx_insert_wx
--
-- Stored procedure to insert a retry exception message into the
-- wi_exception table.  Each failed attempt to retry a work item
-- gets logged in this table; each attempt is keyed by the work item
-- key and an increasing retry count value.
--
create procedure cx_insert_wx( in p_cikey integer,
                               in p_node_id varchar( 15 ),
                               in p_scope_id varchar( 15 ),
                               in p_count_id integer,
                               in p_domain_ref smallint,
                               in p_retry_date timestamp,
                               in p_message varchar( 2000 ),
                               out r_retry_count integer )
external name 'cx_db2:com.collaxa.cube.engine.adaptors.db2.DB2StoredProcedures.cx_insert_wx'
language java parameter style java fenced
modifies sql data@
 
--
-- procedure cx_delete_ci
--
-- Deletes a cube instance and all rows in other Collaxa tables that
-- reference the cube instance.  Since we don't have referential
-- integrity on the tables (for performance reasons), we need this
-- method to help clean up the database easily.
--
create procedure cx_delete_ci( in p_cikey integer )
external name 'cx_db2:com.collaxa.cube.engine.adaptors.db2.DB2StoredProcedures.cx_delete_ci'
language java parameter style java fenced
modifies sql data@
    
--
-- procedure cx_delete_cis
--
-- Deletes all the cube instances in the system.  Since we don't have
-- referential integrity on the tables (for performance reasons), we
-- need this method to help clean up the database easily.
--
create procedure cx_delete_cis( )
external name 'cx_db2:com.collaxa.cube.engine.adaptors.db2.DB2StoredProcedures.cx_delete_cis'
language java parameter style java fenced
modifies sql data@

--
-- procedure cx_delete_cis_by_pcs_id(processId)
--
-- Deletes all the cube instances in the system for the specified process.
-- Since we don't have referential integrity on the tables 
-- (for performance reasons), we need this method to help clean 
-- up the database easily.
--
create procedure cx_delete_cis_by_pcs_id( in p_pcs_id varchar( 100 ),
                                          in p_rev_tag varchar( 50 ) )
external name 'cx_db2:com.collaxa.cube.engine.adaptors.db2.DB2StoredProcedures.cx_delete_cis_by_pcs_id'
language java parameter style java fenced
modifies sql data@
