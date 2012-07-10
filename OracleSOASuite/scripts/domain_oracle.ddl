
/**
 * CONFIDENTIAL AND PROPRIETARY SOURCE CODE OF COLLAXA CORPORATION
 * Copyright (c) 2002, 2006, Oracle. All rights reserved.  
 *
 * Use of this Source Code is subject to the terms of the applicable
 * license agreement from Collaxa Corporation.
 *
 * The copyright notice(s) in this Source Code does not indicate
 * actual or intended publication of this Source Code.
 */


/**
 * BPEL Process Manager Database Schema for Oracle
 *
 * The tables and views defined within this file may be installed on
 * your Oracle server by using the sqlplus command-line utility.
 * For example:
 *
 * sqlplus user/password@TNSNAME \
 * @c:\orabpel\server-default\system\database\domain_oracle.ddl
 *
 * Before installing the database schema, please ensure that the user
 * has the necessary permissions; usually CONNECT and RESOURCE are
 * sufficient.
 */


/**
 * Drop all tables before we begin
 */
drop table scope_activation;
drop table xml_document;
drop table audit_trail;
drop table audit_details;
drop table wi_exception;
drop table work_item;
drop table ci_indexes;
drop table cube_scope;
drop table cube_instance;
drop table loan_customer;
drop table version;
drop table dlv_message;
drop table dlv_subscription;
drop table sync_store;
drop table sync_trail;
drop table invoke_message;
drop table task;
drop table process;
drop table suitcase_bin;
drop table process_descriptor;
drop table process_default;
drop table process_log;
drop table native_correlation;
drop table test_definitions;
drop table test_details;
drop table document_ci_ref;
drop table document_dlv_msg_ref;
drop table attachment;
drop table attachment_ref;


/**
 * version
 *
 * Version information; allows run-time engine to check if correct database
 * schema has been installed.
 */
create table version
(
    guid            varchar2( 50 ),
    dbtype          varchar2( 50 )
);
insert into version values( '10.1.3.5.0', 'oracle' );
commit;


/**
 * cube_instance
 *
 * Stores generated cube instances; master table of system.  Cube instances
 * are unique across all processes for one installation.
 */
create table cube_instance
(
    cikey           integer,
    domain_ref      smallint,
    process_id      varchar2( 100 ),
    revision_tag    varchar2( 50 ),
    creation_date   timestamp,
    creator         varchar2( 100 ),
    modify_date     timestamp,
    modifier        varchar2( 100 ),
    state           integer,
    priority        integer,
    title           varchar2( 50 ),
    status          varchar2( 100 ),
    stage           varchar2( 100 ),
    conversation_id varchar2( 100 ),
    root_id         varchar2( 100 ),
    parent_id       varchar2( 100 ),
    scope_revision  integer,
    scope_csize     integer,
    scope_usize     integer,
    process_guid    varchar2( 50 ),
    process_type    integer,
    metadata        varchar2( 1000 ),
    ext_string1     varchar2( 100 ),
    ext_string2     varchar2( 100 ),
    ext_int1        integer,
    test_run_id     varchar2(100),
    constraint ci_pk primary key( cikey )
)
storage
(
    freelists 20
);

alter index ci_pk rebuild reverse;

/*create index ci_custom on cube_instance( cikey, conversation_id );*/

create index ci_custom2 on cube_instance( domain_ref, process_id, revision_tag, state );

create index ci_custom3 on cube_instance( test_run_id );

/**
 * cube_scope
 *
 * Stores generated scopes of generated cube instances.
 */
create table cube_scope
(
    cikey           integer,
    domain_ref      smallint,
    modify_date     timestamp,
    scope_bin       blob,
    constraint cs_pk primary key( cikey )
)
storage
(
    freelists 6
)
lob( scope_bin )
store as
(
    storage( initial 16K next 16K )
    chunk 8K
    cache
    pctversion 10
)
pctfree 10
pctused 1;

/**
 * ci_indexes
 *
 * Stores searchable custom keys associated with an instance.
 */
create table ci_indexes
(
    cikey           integer,
    index_1         varchar2( 100 ),
    index_2         varchar2( 100 ),
    index_3         varchar2( 100 ),
    index_4         varchar2( 100 ),
    index_5         varchar2( 100 ),
    index_6         varchar2( 100 ),
    constraint cx_pk primary key( cikey )
);

create index ci_index_1 on ci_indexes( index_1 );
create index ci_index_2 on ci_indexes( index_2 );
create index ci_index_3 on ci_indexes( index_3 );
create index ci_index_4 on ci_indexes( index_4 );
create index ci_index_5 on ci_indexes( index_5 );
create index ci_index_6 on ci_indexes( index_6 );

/**
 * scope_activation
 *
 * Scope activation table - scopes that need to be routed/closed/compensated
 * are inserted into this table.  In case of system failure, we can pick up and
 * re-perform any scopes that should have been done before the failure.
 * We're re-creating JMS using this strategy, but then at least we can
 * control the re-delivery of the message at failure.
 *
 * The process_guid column is replicated here from cube_instance to avoid
 * using a join when the recovery agent runs.
 */
create table scope_activation
(
    cikey          integer,
    domain_ref     smallint,
    scope_id       varchar2( 15 ),
    action         integer      default 0       not null,
    creation_date  timestamp,
    modify_date    timestamp,
    process_guid   varchar2( 50 )
)
storage
(
    freelists 3
);

create index sa_fk on scope_activation( cikey, scope_id, action );

/**
 * work_item
 *
 * Stores generated work items; composite key for work items consists of
 * cube instance key, node id work item positioned at, and the scope id
 * for the work item's scope.
 *
 * The process_guid column is replicated here from cube_instance to avoid
 * using a join when the recovery agent runs.
 */
create table work_item
(
    cikey           integer,
    node_id         varchar2( 15 ),
    scope_id        varchar2( 15 ),
    count_id        integer,
    domain_ref      smallint,
    creation_date   timestamp,
    creator         varchar2( 100 ),
    modify_date     timestamp,
    modifier        varchar2( 100 ),
    state           integer,
    transition      integer,
    exception       smallint    default 0       not null,
    exp_date        timestamp,
    exp_flag        smallint    default 0       not null,
    priority        integer,
    label           varchar2( 50 ),
    custom_id       varchar2( 100 ),
    comments        varchar2( 256 ),
    reference_id    varchar2( 128 ),
    idempotent_flag smallint    default 0       not null,
    process_guid    varchar2( 50 ),
    execution_type  integer     default 0       not null,
    first_delay     integer,
    delay           integer,
    ext_string1     varchar2( 100 ),
    ext_string2     varchar2( 100 ),
    ext_int1        integer,
    cluster_node_id     varchar2( 100 ),
    constraint wi_pk primary key( cikey, node_id, scope_id, count_id )
)
storage
(
    freelists 20
);

create index wi_expired on work_item( exp_date );
create index wi_stranded on work_item( modify_date );

/**
 * wi_exception
 *
 * Stores exception messages generated by failed attempts to perform, manage
 * or complete a workitem.  Each failed attempt is logged as an exception
 * message.
 */
create table wi_exception
(
    cikey           integer,
    node_id         varchar2( 15 ),
    scope_id        varchar2( 15 ),
    count_id        integer,
    domain_ref      smallint,
    retry_count     integer,
    retry_date      timestamp,
    message         varchar2( 2000 )
)
storage
(
    freelists 20
);

create index wx_fk on wi_exception( cikey, node_id, scope_id, count_id );

/**
 * xml_document
 *
 * document persistence table; all large objects in the system persist themselves
 * here.
 */
create table xml_document
(
    dockey           varchar2( 200 ),
    domain_ref       smallint,
    bin_csize        integer,
    bin_usize        integer,
    bin              blob,
    modify_date      timestamp,
    bin_format       smallint,
    constraint xml_doc_pk primary key( dockey )
)
storage
(
    freelists 20
)
lob( bin )
store as
(
    storage( initial 16K next 16K )
    chunk 8K
    cache
    pctversion 10
)
pctfree 10
pctused 1;
alter index xml_doc_pk rebuild reverse; 

/**
 * audit_trail
 *
 * Stores record of actions taken on an instance (application, system,
 * administrative and errors).
 */
create table audit_trail
(
    cikey             integer,
    domain_ref        smallint,
    count_id          integer,
    block             integer,
    block_csize       integer,
    block_usize       integer,
    log               raw( 2000 )
);

create index at_fk on audit_trail( cikey );

/**
 * audit_details
 *
 * Stores details for audit trail events that are large in size.  Details
 * that are smaller than a specified size are inlined with the events in
 * the audit_trail table.
 */
create table audit_details
(
    cikey             integer,
    domain_ref        smallint,
    detail_id         integer,
    bin_csize         integer,
    bin_usize         integer,
    doc_ref           varchar2(300),
    bin               blob,
    constraint ad_pk primary key( cikey, detail_id )
)
storage
(
    freelists 6
)
lob( bin )
store as
(
    storage( initial 4k next 4k )
    chunk 2k
    cache
    pctversion 0
)
pctfree 0
pctused 1;

/**
 * sync_trail
 *
 * Audit trail of completed synchronous instances are stored here.  The audit
 * trail is written out here so that we don't have to insert a very LARGE
 * number rows for long running instances.
 */
create table sync_trail
(
    cikey             integer,
    domain_ref        smallint,
    bin_csize         integer,
    bin_usize         integer,
    bin               blob
)
storage
(
    freelists 6
)
lob( bin )
store as
(
    storage( initial 4k next 4k )
    chunk 2k
    cache
    pctversion 0
)
pctfree 0
pctused 1;

create index st_fk on sync_trail( cikey );

/**
 * sync_store
 *
 * The work items of completed synchronous instances are stored here.
 */
create table sync_store
(
    cikey             integer,
    domain_ref        smallint,
    bin_csize         integer,
    bin_usize         integer,
    bin               blob
)
storage
(
    freelists 6
)
lob( bin )
store as
(
    storage( initial 4k next 4k )
    chunk 2k
    cache
    pctversion 0
)
pctfree 0
pctused 1;

create index ss_fk on sync_store( cikey );

/**
 * dlv_message
 *
 * Delivery service message table; callback messages are stored here.
 */
create table dlv_message
(
    conv_id           varchar2( 128 ),
    conv_type         integer,
    message_guid      varchar2( 50 ),
    domain_ref        smallint,
    process_id        varchar2( 100 ),
    revision_tag      varchar2( 50 ),
    operation_name    varchar2( 128 ),
    receive_date      timestamp,
    state             integer       default 0       not null,
    res_process_guid  varchar2( 50 ),
    res_subscriber    varchar2( 128 ),
    properties        varchar2( 2000 ),
    ext_string1       varchar2( 100 ),
    ext_string2       varchar2( 100 ),
    ext_int1          integer,
    headers_ref_id     varchar2(100),
    properties_ref_id   varchar2(100),
    constraint dm_pk primary key( message_guid )
);
create index dm_conversation on dlv_message( conv_id, operation_name );


/**
 * dlv_subscription
 *
 * Stores message subscriptions from engine.
 */
create table dlv_subscription
(
    conv_id           varchar2( 128 ),
    conv_type         integer,
    cikey             integer,
    domain_ref        smallint,
    process_id        varchar2( 100 ),
    revision_tag      varchar2( 50 ),
    process_guid      varchar2( 50 ),
    operation_name    varchar2( 128 ),
    subscriber_id     varchar2( 128 ),
    service_name      varchar2( 128 ),
    subscription_date timestamp,
    state             integer       default 0       not null,
    properties        varchar2( 2000 ),
    ext_string1       varchar2( 100 ),
    ext_string2       varchar2( 100 ),
    ext_int1          integer,
    constraint ds_pk primary key( subscriber_id )
);

create index ds_fk on dlv_subscription( cikey );
create index ds_conversation on dlv_subscription( conv_id );
create index ds_operation on dlv_subscription( process_id, operation_name );

/**
 * invoke_message
 *
 * All the asynchronous invocation messages are stored in this table before
 * being dispatched to the engine.
 */
create table invoke_message
(
    conv_id           varchar2( 128 ),
    message_guid      varchar2( 50 ),
    domain_ref        smallint,
    process_id        varchar2( 100 ),
    revision_tag      varchar2( 50 ),
    operation_name    varchar2( 128 ),
    receive_date      timestamp,
    state             integer     default 0       not null,
    priority          integer,
    properties        varchar2( 4000 ),
    ext_string1       varchar2( 100 ),
    ext_string2       varchar2( 100 ),
    ext_int1          integer,
    master_conv_id    varchar2( 128 ),
    headers_ref_id     varchar2(100),
    properties_ref_id   varchar2(100),
    constraint im_pk primary key( message_guid )
);

/*create index im_message_guid on invoke_message( message_guid, state );*/
create index im_master_conv_id on invoke_message( master_conv_id );
alter index im_pk rebuild reverse;

/**
 * document_ci_ref
 *
 * cube instances reference to document are recorded here.
 */
create table document_ci_ref
(
    dockey           varchar2( 200 ),
    cikey            integer,
    domain_ref       smallint,
    constraint doc_ci_reference_pk primary key( cikey, dockey )
);

/**
 * document_ci_ref
 *
 * invoke_message and dlv_message has references to document which are recorded here.
 */
create table document_dlv_msg_ref
(
    message_guid     varchar2( 50 ),
    dockey           varchar2( 200 ),
    part_name        varchar2(50),
    domain_ref       smallint,
    message_type     smallint,
    constraint doc_dlv_msg_ref_pk primary key( message_guid, dockey )
);
alter index doc_dlv_msg_ref_pk rebuild reverse; 

/**
 * attachment
 *
 * attachment persistence table; all binary attachments are persisted here.
 */
create table attachment
(
    key              varchar2( 50 ),
    bin              blob,
    constraint att_pk primary key( key )
);

/**
 * attachment_ref
 *
 * references to attachments are recorded here.
 */
create table attachment_ref
(
    cikey            integer,
    domain_ref       smallint,
    key              varchar2( 50 ),
    constraint attref_pk primary key( cikey, key )
);

/**
 * task
 *
 * All the properties of the task messages are stored here.
 */
create table task
(
    domain_ref        smallint,
    conversation_id   varchar2( 128 ),
    title             varchar2( 50 ),
    creation_date     timestamp,
    creator           varchar2( 100 ),
    modify_date       timestamp,
    modifier          varchar2( 100 ),
    assignee          varchar2( 100 ),
    status            varchar2( 50 ),
    expired           smallint   default 0        not null,
    exp_date          timestamp,
    priority          integer    default 0        not null,
    template          varchar2( 50 ),
    custom_key        varchar2( 128 ),
    conclusion        varchar2( 256 ),
    ext_string1       varchar2( 100 ),
    ext_string2       varchar2( 100 ),
    ext_int1          integer
);

create index ta_conversation_id on task( conversation_id );

create table process
(
    domain_ref          smallint,
    process_guid        varchar2( 50 ),
    process_id          varchar2( 100 ),
    revision_tag        varchar2( 50 ),
    suitcase_id         varchar2( 200 ),
    state               integer,
    lifecycle           integer,
    deploy_user         varchar2( 100 ),
    deploy_timestamp    number( 38 ),
    sla_completion_time number( 38 ),
    constraint p_pk primary key( domain_ref, process_id, revision_tag )
);

create table suitcase_bin
(
    domain_ref          smallint,
    suitcase_id         varchar2( 200 ),
    bin_csize           integer,
    bin_usize           integer,
    bin                 blob,
    constraint pb_pk primary key( domain_ref, suitcase_id )
)
storage
(
    freelists 6
)
lob( bin )
store as
(
    storage( initial 16K next 16K )
    chunk 8K
    cache
    pctversion 0
)
pctfree 0
pctused 1;

create table process_descriptor
(
    domain_ref          smallint,
    process_id          varchar2( 100 ),
    revision_tag        varchar2( 50 ),
    descriptor          clob,
    constraint pds_pk primary key( domain_ref, process_id, revision_tag )
)
storage
(
    freelists 6
)
lob( descriptor )
store as
(
    storage( initial 16K next 16K )
    chunk 8K
    cache
    pctversion 10
)
pctfree 10
pctused 1;

create table process_default
(
    domain_ref       smallint,
    process_id       varchar2( 100 ),
    default_revision varchar2( 50 ),
    constraint pd_pk primary key( domain_ref, process_id )
);

/**
 * process_log
 *
 * Record of events (informational, debug, error) encountered while
 * interacting with a process.
 */
create table process_log
(
    domain_ref       smallint,
    process_id       varchar2( 100 ),
    revision_tag     varchar2( 50 ),
    event_date       timestamp,
    type             integer,
    category         integer,
    message          nvarchar2( 255 ),
    details          nvarchar2( 2000 )
);

create index pl_fk on process_log( process_id, revision_tag );

/**
 * native_correlation
 *
 * Association table (Map) between Engine Conversation Id's
 * and Native Correlation Id's (such as JMS/AQ Message Id's)
 */
create table native_correlation
(
    domain_ref              smallint,
    native_correlation_id   varchar2( 100 ),
    conversation_id         varchar2( 100 )
);

create index nc_corr on native_correlation( native_correlation_id );
create index nc_conv on native_correlation( conversation_id );

/**
 * test_definition
 *
 * Table that stores the test definitions and associated documents
 * (messages, include files). There is a 1-*  relationship between 
 * process and this table and a 1-* relationship between this table 
 * and test_details, although test_details can outlive their 
 * associated definition.
 */
create table test_definitions
(
    process_id      varchar2(100),
    revision_tag    varchar2(50),
    domain_ref      smallint,
    test_suite      varchar2(100),
    location        varchar2(100),
    type            varchar2(10) not null,
    creation_date   timestamp not null,
    definition      blob not null,
    constraint tdef_pk primary key(process_id, revision_tag, domain_ref, test_suite, location, type)
)
storage
(
    freelists 6
)
lob( definition )
store as
(
    storage( initial 16K next 16K )
    chunk 8K
    cache
    pctversion 90
)
pctfree 99
pctused 1;

/**
 * test_details
 *
 * Table that stores details about tests run. Each row has a 1-1
 * relationship with cube_instance.
 */
create table test_details
(
    cikey           number primary key,
    domain_ref      smallint not null,
    test_suite      varchar2(100) not null,
    test_location   varchar2(100) not null,
    test_run_name   varchar2(100) not null,
    test_run_id     varchar2(100) not null,
    test_status     varchar2(50) not null,
    test_result     blob not null
)
storage
(
    freelists 6
)
lob( test_result )
store as
(
    storage( initial 16K next 16K )
    chunk 8K
    cache
    pctversion 90
)
pctfree 99
pctused 1;

/**
 * view work_list
 *
 * Work list of current open items; a join between cube_instance and
 * work_item tables.  Each row contains:
 *     + instance id
 *     + instance title
 *     + process id
 *     + instance priority
 *     + instance state
 *     + work item label
 *     + work item expiration date
 *     + work item priority
 *     + work item state
 */
create or replace view work_list
as select ci.cikey, wi.node_id, wi.scope_id, wi.count_id,
          ci.title, ci.process_id, ci.priority ci_priority, ci.state ci_state,
          wi.label, wi.exp_date, wi.priority wi_priority, wi.state wi_state
   from cube_instance ci, work_item wi
   where ci.cikey = wi.cikey and
         ( wi.state = 1 or wi.state = 2 or wi.state = 3 );

/**
 * view admin_list_ci
 *
 * Simple query on the cube_instance table ... any columns that the
 * cube_instance table has in common with the work_item table are
 * aliased.  The views admin_list_ci, admin_list_wi and admin_list all
 * have the same aliased column names ... this is so the interface to the
 * administration finder class is consistent regardless of the query.
 *
 * Each row contains (incl alias):
 *     + instance id                  (cikey)
 *     + instance domain ref          (ci_domain_ref)
 *     + instance process id          (process_id)
 *     + instance revision tag        (revision_tag)
 *     + instance creation date       (ci_creation_date)
 *     + instance creator             (ci_creator)
 *     + instance modify date         (ci_modify_date)
 *     + instance modifier            (ci_modifier)
 *     + instance state               (ci_state)
 *     + instance priority            (ci_priority)
 *     + instance title               (title)
 *     + instance status              (status)
 *     + instance stage               (stage)
 *     + instance conversation id     (conversation_id)
 *     + instance metadata            (metadata)
 *     + instance root id             (root_id)
 *     + instance parent id           (parent_id)
 *     + instance test run id         (test_run_id)
 */
create or replace view admin_list_ci
as select cikey, domain_ref as ci_domain_ref, process_id, revision_tag,
          creation_date ci_creation_date, creator ci_creator,
          modify_date ci_modify_date, modifier ci_modifier,
          state ci_state, priority ci_priority, title,
          status, stage, conversation_id, metadata, root_id, parent_id,
          test_run_id
   from cube_instance;

/**
 * view admin_list_cx
 *
 * Simple join between cube_instance and ci_indexes tables ... created
 * to allow for consistent administration finder class interface.
 */
create or replace view admin_list_cx
as select ci.cikey, domain_ref as ci_domain_ref, process_id, revision_tag,
          creation_date ci_creation_date, creator ci_creator,
          modify_date ci_modify_date, modifier ci_modifier,
          state ci_state, priority ci_priority, title,
          status, stage, conversation_id, metadata,
          root_id, parent_id,
          index_1, index_2, index_3, index_4, index_5, index_6
   from cube_instance ci, ci_indexes cx
   where ci.cikey = cx.cikey;

/**
 * view admin_list_wi
 *
 * Simple query on the work_item table ... any columns that the
 * work_item table has in common with the cube_instance table are
 * aliased.  The views admin_list_ci, admin_list_wi and admin_list all
 * have the same aliased column names ... this is so the interface to the
 * administration finder class is consistent regardless of the query.
 *
 * Each row contains (incl alias):
 *     + instance id                  (cikey)
 *     + work item node id            (node_id)
 *     + work item scope id           (scope_id)
 *     + work item count id           (count_id)
 *     + work item creation date      (wi_creation_date)
 *     + work item creator            (wi_creator)
 *     + work item modify date        (wi_modify_date)
 *     + work item modifier           (wi_modifier)
 *     + work item state              (wi_state)
 *     + work item priority           (wi_priority)
 *     + work item transition         (transition)
 *     + work item expiration date    (exp_date)
 *     + work item expiration flag    (exp_flag)
 *     + work item label              (label)
 *     + work item custom id          (custom_id)
 *     + work item comments           (comments)
 *     + work item reference id       (reference_id)
 *     + work item execution type     (execution_type)
 *     + instance domain ref          (ci_domain_ref)
 *     + instance process id          (process_id)
 *     + instance revision tag        (revision_tag)
 *     + instance title               (title)
 *     + instance root id             (root_id)
 *     + instance parent id           (parent_id)
 */
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
          ci.title title, ci.root_id, ci.parent_id
   from cube_instance ci, work_item wi
   where ci.cikey = wi.cikey (+);


/**
 * view admin_list_td
 *
 * Simple query on the test_details table ... any columns that the
 * test_details table has in common with the cube_instance table are
 * aliased.
 *
 * Each row contains (incl alias):
 *     + instance id                  (cikey)
 *     + instance domain ref          (ci_domain_ref)
 *     + test run name                (test_run_name)
 *     + test run id                  (test_run_id)
 *     + test suite                   (test_suite)
 *     + test location                (test_location)
 *     + test status                  (test_status)
 *     + test result                  (test_result)
 */
create or replace view admin_list_td
as select cikey, 
          domain_ref as ci_domain_ref, 
          test_run_name, 
          test_run_id, 
          test_suite, 
          test_location,
          test_status,
          test_result
     from test_details td;

/**
 * view admin_list_tdef
 *
 * Simple query on the test_definitions table 
 *
 * Each row contains (incl alias):
 *     + process_id     
 *     + revision_tag   
 *     + test_suite     
 *     + location       
 *     + type           
 *     + creation_date  
 *     + definition     
 */
create or replace view admin_list_tdef
as select process_id,
          revision_tag, 
          domain_ref,
          test_suite, 
          location,
          type,
          creation_date,
          definition
     from test_definitions;

/**
 * view dbg_wi
 *
 * Simplified view of work item columns ... used for debugging purposes.
 * Each row contains:
 *     + instance id
 *     + node id
 *     + scope id
 *     + state
 *     + transition
 */
create or replace view dbg_wi
as select cikey, node_id, scope_id, count_id,
          to_char( creation_date, 'mm/dd/yyyy hh24:mi:ss' ) creation_date,
          state, transition
   from work_item
   order by creation_date asc;

/**
 * view activity_perf
 * Simple query on work_item table to extrace performance related data.
 * Each row contains:
 *     + cikey
 *     + domain_ref
 *     + label
 *     + creation_date
 *     + modify_date
 *     + eval_time (difference in milliseconds)
 */
create or replace view activity_perf
as select cikey, domain_ref, node_id, label, creation_date, modify_date,
          (86400 * (modify_date - creation_date)) eval_time
   from work_item;

/**
 * view instance_perf
 * Simple query on cube_instance table to extrace performance related data.
 * Each row contains:
 *     + cikey
 *     + domain_ref
 *     + process_id
 *     + creation_date
 *     + modify_date
 *     + eval_time (difference in milliseconds)
 */
create or replace view instance_perf
as select cikey, domain_ref, process_id, creation_date, modify_date,
          (86400 * (modify_date - creation_date)) eval_time
   from cube_instance;

-- <tables for sample processes>

/**
 * loan_customer
 *
 * Table used to store customer information for loan EJB.
 */
create table loan_customer
(
    ssn               varchar2( 11 ),
    name              varchar2( 50 ),
    email             varchar2( 30 ),
    provider          varchar2( 20 ),
    status            char( 1 ),
    constraint lc_pk primary key( email )
);
insert into loan_customer values( '123-12-1234','demo1', 'demo1@otn.com', null, null );
insert into loan_customer values( '087-65-4321','demo2', 'demo2@otn.com', null, null );
commit;

-- </tables for sample processes>


/**
 * package collaxa
 *
 * PL/SQL declarations for stored procedures and types contained in collaxa
 * package.
 */
create or replace package collaxa
as
    procedure insert_sa( p_cikey in integer,
                         p_domain_ref in smallint,
                         p_scope_id in varchar2,
                         p_process_guid in varchar2,
                         p_creation_date in timestamp,
                         r_success out integer );

    procedure insert_wx( p_cikey in integer,
                         p_node_id in varchar2,
                         p_scope_id in varchar2,
                         p_count_id in integer,
                         p_domain_ref in smallint,
                         p_retry_date in timestamp,
                         p_message in varchar2,
                         r_retry_count out integer );

    procedure update_doc( p_dockey in varchar2,
                          p_domain_ref in smallint,
                          p_bin_csize in integer,
                          p_bin_usize in integer,
                          p_bin_format in integer,
                          r_bin out blob );

    procedure delete_ci( p_cikey in integer );

    procedure delete_cis_by_domain_ref( p_domain_ref in smallint,
                                        r_row_count out integer );

    procedure delete_cis_by_pcs_id( p_pcs_id in varchar2,
                                    p_rev_tag varchar2,
                                    r_row_count out integer );
                                    
    procedure insert_document_ci_ref( p_cikey in integer,
                                      p_dockey in varchar2, 
                                      p_domain_ref in smallint,
                                      r_success out integer);

end collaxa;
/

/**
 * package body collaxa
 *
 * PL/SQL package implementation for stored procedures used in collaxa system.
 */
create or replace package body collaxa
as
    /**
     * procedure insert_sa
     *
     * Stored procedure to do a "smart" insert of a scope activation message.
     * If a scope activation message already exists, don't bother to insert
     * and return 0 (this process can happen if two concurrent threads generate
     * an activation message for the same scope - say the method scope for
     * example - only one will insert properly; but both threads will race to
     * consume the activation message).
     */
     procedure insert_sa( p_cikey in integer,
                          p_domain_ref in smallint,
                          p_scope_id in varchar2,
                          p_process_guid in varchar2,
                          p_creation_date in timestamp,
                          r_success out integer )
     as
         v_row_found boolean;

         cursor c_scope_activation is
             select *
             from scope_activation
             where cikey = p_cikey and
                   scope_id = p_scope_id;

         r_scope_activation c_scope_activation%ROWTYPE;
     begin
         -- Find out if the scope activation row has already been inserted
         --
         open c_scope_activation;
         fetch c_scope_activation into r_scope_activation;
         v_row_found := c_scope_activation%FOUND;
         close c_scope_activation;

         if not v_row_found
         then
             insert into scope_activation( cikey, domain_ref, scope_id,
                                           process_guid, creation_date )
              values( p_cikey, p_domain_ref, p_scope_id,
                     p_process_guid, p_creation_date );
             r_success := 1;
         else
             r_success := 0;
         end if;
    end insert_sa;

    /**
     * procedure insert_wx
     *
     * Stored procedure to insert a retry exception message into the
     * wi_exception table.  Each failed attempt to retry a work item
     * gets logged in this table; each attempt is keyed by the work item
     * key and an increasing retry count value.
     */
    procedure insert_wx( p_cikey in integer,
                         p_node_id in varchar2,
                         p_scope_id in varchar2,
                         p_count_id in integer,
                         p_domain_ref in smallint,
                         p_retry_date in timestamp,
                         p_message in varchar2,
                         r_retry_count out integer )
    as
        v_retry_count integer := 1;

        cursor c_wi_exception is
            select max( retry_count ) retry_count
            from wi_exception
            where cikey = p_cikey and
                  node_id = p_node_id and
                  scope_id = p_scope_id and
                  count_id = p_count_id;

        r_wi_exception c_wi_exception%ROWTYPE;
    begin
        -- Find the highest retry_count value for the given work item
        --
        open c_wi_exception;
        fetch c_wi_exception into r_wi_exception;

        if c_wi_exception%FOUND
        then
            v_retry_count := r_wi_exception.retry_count + 1;
        end if;

        close c_wi_exception;

        insert into wi_exception( cikey, node_id, scope_id, count_id,
                                  domain_ref, retry_count, retry_date, message )
        values( p_cikey, p_node_id, p_scope_id, p_count_id,
                p_domain_ref, v_retry_count, p_retry_date, p_message );

        -- Set the retry count out parameter to the retry count just
        -- inserted into the database.
        --
        r_retry_count := v_retry_count;
    end insert_wx;

    /**
     * procedure update_doc
     *
     * Stored procedure to do a "smart" insert of a document row.  If the
     * document row has not been inserted yet, insert the row with an empty
     * blob before returning it.
     */
    procedure update_doc( p_dockey in varchar2,
                          p_domain_ref in smallint,
                          p_bin_csize in integer,
                          p_bin_usize in integer,
                          p_bin_format in integer,
                          r_bin out blob )
    as
        v_row_found boolean := false;

        cursor c_document is
            select *
            from xml_document
            where dockey = p_dockey
        for update;

        r_document c_document%ROWTYPE;
    begin
        -- Try to fetch the row associated with the document key.
        --
        open c_document;
        fetch c_document into r_document;

        if c_document%FOUND
        then
            -- The document entry already exists ... update the columns with
            -- the new values and return the blob.
            --
            update xml_document
            set bin_csize = p_bin_csize,
                bin_usize = p_bin_usize
            where current of c_document;

            r_bin := r_document.bin;
            v_row_found := true;
        end if;

        close c_document;

        -- If a document entry has not been inserted yet, insert it.
        --
        if not v_row_found
        then
            insert into xml_document( dockey, domain_ref, bin_csize, bin_usize, bin_format, bin )
            values( p_dockey, p_domain_ref, p_bin_csize, p_bin_usize, p_bin_format, empty_blob() )
            returning bin into r_bin;
        end if;
    end update_doc;

    /**
     * procedure delete_ci
     *
     * Deletes a cube instance and all rows in other Collaxa tables that
     * reference the cube instance.  Since we don't have referential
     * integrity on the tables (for performance reasons), we need this
     * method to help clean up the database easily.
     */
    procedure delete_ci( p_cikey in integer )
    as
    begin
        -- Delete the cube instance first
        --
        delete from cube_instance where cikey = p_cikey;

        -- Then cascade the delete to other tables with references
        --
        delete from cube_scope where cikey = p_cikey;
        delete from work_item where cikey = p_cikey;
        delete from wi_exception where cikey = p_cikey;
        delete from scope_activation where cikey = p_cikey;
        delete from dlv_subscription where cikey = p_cikey;
        delete from audit_trail where cikey = p_cikey;
        delete from audit_details where cikey = p_cikey;
        delete from sync_trail where cikey = p_cikey;
        delete from sync_store where cikey = p_cikey;
        delete from test_details where cikey = p_cikey;
        delete from document_ci_ref where cikey = p_cikey;
    end delete_ci;

    /**
     * procedure delete_cis_by_domain_ref
     *
     * Deletes all the cube instances in the system.  Since we don't have
     * referential integrity on the tables (for performance reasons), we
     * need this method to help clean up the database easily.
     */
    procedure delete_cis_by_domain_ref( p_domain_ref in smallint,
                                        r_row_count out integer )
    as
    begin
        delete from cube_instance where domain_ref = p_domain_ref;
        r_row_count := SQL%ROWCOUNT;
        commit;

        delete from cube_scope where domain_ref = p_domain_ref;
        commit;

        delete from work_item where domain_ref = p_domain_ref;
        commit;

        delete from wi_exception where domain_ref = p_domain_ref;
        commit;

        delete from xml_document where domain_ref = p_domain_ref;
        commit;

        delete from invoke_message where domain_ref = p_domain_ref;
        commit;

        delete from dlv_message where domain_ref = p_domain_ref;
        commit;

        delete from dlv_subscription where domain_ref = p_domain_ref;
        commit;

        delete from scope_activation where domain_ref = p_domain_ref;
        commit;

        delete from audit_trail where domain_ref = p_domain_ref;
        commit;

        delete from audit_details where domain_ref = p_domain_ref;
        commit;

        delete from sync_trail where domain_ref = p_domain_ref;
        commit;

        delete from sync_store where domain_ref = p_domain_ref;
        commit;

        delete from task where domain_ref = p_domain_ref;
        commit;

        delete from test_details where domain_ref = p_domain_ref;
        commit;
        
        delete from document_dlv_msg_ref where domain_ref = p_domain_ref;
        commit;
        
        delete from document_ci_ref where domain_ref = p_domain_ref;
        commit;
        delete from attachment_ref where domain_ref = p_domain_ref;
        commit;

        delete attachment where not exists (select 1 from attachment_ref where attachment_ref.key = attachment.key);
        commit;

    end delete_cis_by_domain_ref;

    /**
     * procedure delete_cis_by_pcs_id( processId )
     *
     * Deletes all the cube instances in the system for the specified process.
     * Since we don't have referential integrity on the tables
     * (for performance reasons), we need this method to help clean
     * up the database easily.
     */
    procedure delete_cis_by_pcs_id( p_pcs_id in varchar2,
                                    p_rev_tag in varchar2,
                                    r_row_count out integer )
    as
        cursor c_cube_instance is
            select *
            from cube_instance
            where process_id = p_pcs_id and revision_tag = p_rev_tag;
    begin
        r_row_count := 0;

        -- Iterate through all the cube instances and delete all references
        -- from other tables
        --
        for r_cube_instance in c_cube_instance
        loop
            collaxa.delete_ci( r_cube_instance.cikey );
            r_row_count := r_row_count + 1;
        end loop;
    end delete_cis_by_pcs_id;

    /**
      * procedure insert_document_ci_ref
      *
      * Stored procedure to do a "smart" insert of a document reference.
      * If a document reference already exists for a cube instance, don't bother to insert
      * and return 0.
      */
    procedure insert_document_ci_ref( p_cikey in integer,
                                      p_dockey in varchar2, 
                                      p_domain_ref in smallint,
                                      r_success out integer)
    as
         v_row_found boolean;

         cursor c_document_ci is
             select *
             from document_ci_ref
             where cikey = p_cikey and
                   dockey = p_dockey;

         r_document_ci c_document_ci%ROWTYPE;
     begin
         -- Find out if the document key row has already been inserted
         --
         open c_document_ci;
         fetch c_document_ci into r_document_ci;
         v_row_found := c_document_ci%FOUND;
         close c_document_ci;

         if not v_row_found
         then
             insert into document_ci_ref( cikey, domain_ref, dockey )
              values( p_cikey, p_domain_ref, p_dockey);
             r_success := 1;
         else
             r_success := 0;
         end if;
    end insert_document_ci_ref;
    
end collaxa;
/

@@sensor_oracle
