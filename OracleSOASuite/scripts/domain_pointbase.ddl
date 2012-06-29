
/**
 * CONFIDENTIAL AND PROPRIETARY SOURCE CODE OF COLLAXA CORPORATION
 * Copyright (c) 2002, 2005, Oracle. All rights reserved.  
 *
 * Use of this Source Code is subject to the terms of the applicable
 * license agreement from Collaxa Corporation.
 *
 * The copyright notice(s) in this Source Code does not indicate
 * actual or intended publication of this Source Code.
 */


/**
 * Drop all tables/views/procedures before we begin
 */
drop specific procedure cx_drop_object;
create procedure cx_drop_object( in obj_name varchar( 50 ), in obj_type integer )
language java
specific cx_drop_object
deterministic
no sql
external name "com.collaxa.cube.engine.adaptors.pointbase.PointBaseStoredProcedures::dropObject"
parameter style sql;

call cx_drop_object( 'work_list', 2 );
call cx_drop_object( 'admin_list_ci', 2 );
call cx_drop_object( 'admin_list_wi', 2 );
call cx_drop_object( 'scope_activation', 1 );
call cx_drop_object( 'document', 1 );
call cx_drop_object( 'audit_trail', 1 );
call cx_drop_object( 'audit_details', 1 );
call cx_drop_object( 'sync_trail', 1 );
call cx_drop_object( 'sync_store', 1 );
call cx_drop_object( 'dynamic_group', 1 );
call cx_drop_object( 'wi_exception', 1 );
call cx_drop_object( 'work_item', 1 );
call cx_drop_object( 'ci_indexes', 1 );
call cx_drop_object( 'cube_scope', 1 );
call cx_drop_object( 'cube_instance', 1 );
call cx_drop_object( 'loan_customer', 1 );
call cx_drop_object( 'version', 1 );
call cx_drop_object( 'tx_superior', 1 );
call cx_drop_object( 'tx_inferior', 1 );
call cx_drop_object( 'tx_message', 1 );
call cx_drop_object( 'dlv_message', 1 );
call cx_drop_object( 'dlv_subscription', 1 );
call cx_drop_object( 'invoke_message', 1 );
call cx_drop_object( 'cx_delete_cis', 3 );
call cx_drop_object( 'cx_delete_cis_by_pcs_id', 3 );
call cx_drop_object( 'cx_delete_ci', 3 );
call cx_drop_object( 'task', 1 );
call cx_drop_object( 'process_revision', 1 );
call cx_drop_object( 'process_default', 1 );
call cx_drop_object( 'process_log', 1 );
call cx_drop_object( 'native_correlation', 1 );


/**
 * version
 *
 * Version information; allows run-time engine to check if correct database
 * schema has been installed.
 */
create table version
(
    guid            varchar( 50 ),
    dbtype          varchar( 50 )
);
insert into version values( '2.0.40', 'pointbase' );
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
    process_id      varchar( 100 ),
    revision_tag    varchar( 50 ),
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
    root_id         varchar( 100 ),
    parent_id       varchar( 100 ),
    scope_revision  integer,
    scope_csize     integer,
    scope_usize     integer,
    process_guid    varchar( 50 ),
    process_type    integer,
    metadata        varchar( 1000 ),
    ext_string1     varchar( 100 ),
    ext_string2     varchar( 100 ),
    ext_int1        integer,
    test_run_name   varchar( 100 ),
    test_run_id     varchar( 100 ),
    test_suite      varchar( 100 ),
    test_location   varchar( 100 ),
    constraint ci_pk primary key( cikey )
);


/**
 * cube_scope
 *
 * Stores generated scopes of generated cube instances.
 */
create table cube_scope
(
    cikey           integer,
    domain_ref      smallint,
    scope_bin       blob( 20M ),
    modify_date     timestamp,
    constraint cs_pk primary key( cikey )
)
lob pagesize 16K;

/**
 * ci_indexes
 *
 * Stores searchable custom keys associated with an instance.
 */
create table ci_indexes
(
    cikey           integer,
    index_1         varchar( 100 ),
    index_2         varchar( 100 ),
    index_3         varchar( 100 ),
    index_4         varchar( 100 ),
    index_5         varchar( 100 ),
    index_6         varchar( 100 ),
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
    scope_id       varchar( 15 ),
    action         integer      default 0       not null,
    creation_date  timestamp,
    modify_date    timestamp,
    process_guid   varchar( 50 ),
    constraint sa_pk primary key( cikey, scope_id, action )
);

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
    node_id         varchar( 15 ),
    scope_id        varchar( 15 ),
    count_id        integer,
    domain_ref      smallint,
    creation_date   timestamp,
    creator         varchar( 100 ),
    modify_date     timestamp,
    modifier        varchar( 100 ),
    state           integer,
    transition      integer,
    exception       smallint    default 0       not null,
    exp_date        timestamp,
    exp_flag        smallint    default 0       not null,
    priority        integer,
    label           varchar( 50 ),
    custom_id       varchar( 100 ),
    comments        varchar( 256 ),
    reference_id    varchar( 128 ),
    idempotent_flag smallint    default 0       not null,
    process_guid    varchar( 50 ),
    execution_type  integer     default 0       not null,
    first_delay     integer,
    delay           integer,
    ext_string1     varchar( 100 ),
    ext_string2     varchar( 100 ),
    ext_int1        integer,
    constraint wi_pk primary key( cikey, node_id, scope_id, count_id )
);

/*
 * Commented the wi indices for pointbase. because if you have index, pointbase
 * going to lock the record everytime it accesses.
 *
 * create index wi_expired on work_item( state, exp_date, exp_flag );
 * create index wi_stranded on work_item( modify_date, state, transition );
 *
 */

/**
 * wi_exception
 *
 * Stores exception messages generated by failed attempts to perform, manage
 * or complete a workitem.  Each failed attempt is logged as an exception
 * message.
 */
create table wi_exception
(
    cikey            integer,
    node_id          varchar( 15 ),
    scope_id         varchar( 15 ),
    count_id         integer,
    domain_ref       smallint,
    retry_count      integer,
    retry_date       timestamp,
    message          varchar( 2000 )
);
create index wx_fk on wi_exception( cikey, node_id, scope_id, count_id );


/**
 * document
 *
 * Large documents are persisted in this table rather than in the scope.
 */
create table document
(
    dockey           varchar( 50 ),
    cikey            integer,
    domain_ref       smallint,
    classname        varchar( 100 ),
    bin_csize        integer,
    bin_usize        integer,
    bin              blob( 20M ),
    modify_date      timestamp,
    constraint doc_pk primary key( dockey )
)
lob pagesize 4K;
create index doc_fk on document( cikey );


/**
 * tx_inferior
 *
 * Stores information about BTP inferiors that have enrolled in a transaction.
 * All necessary information required to callback the inferior is stored.
 */
create table tx_inferior
(
    inferior_id          varchar( 255 )     not null,
    tx_id                varchar( 255 )     not null,
    cikey                integer            null,
    inferior_status      smallint           null,
    engine_action        smallint           null,
    inferior_address     varchar( 255 )     null,
    service_location     varchar( 255 )     null,
    inferior_protocol    varchar( 20 )      null,
    other_attributes     varchar( 2000 )    null,
    correlation_id       varchar( 2000 )    null,
    start_date           timestamp          null,
    modify_date          timestamp          null,
    exp_date             timestamp          null,
    constraint ti_pk primary key( inferior_id, tx_id )
);
create index ti_fk on tx_inferior( cikey );

/**
 * tx_message
 *
 * Stores inferior transaction messages that needs to be retried later on
 * The transaction manager will fetch these messsage in a periodic
 * manner and will try to processes them until it reaches the max.
 * retry count.
 */
create table tx_message
(
    inferior_id          varchar( 255 )     not null,
    tx_id                varchar( 255 )     not null,
    operation            integer            null,
    retry_count          integer            null,
    retry_date           timestamp          null,
    message              varchar( 2000 )    null,
    constraint tm_pk primary key( inferior_id, tx_id )
);

/**
 * tx_superior
 *
 * Stores information about BTP superiors that have started a transaction.
 * Each cube instance may have multiple superiors associated with it.
 */
create table tx_superior
(
    tx_id                varchar( 255 )     not null,
    tx_type              smallint           null,
    cikey                integer            null,
    initiator_id         varchar( 255 )     null,
    process_guid         varchar( 50 )      null,
    method_name          varchar( 255 )     null,
    status               smallint           not null,
    superior_address     varchar( 255 )     null,
    superior_protocol    varchar( 20 )      null,
    other_attributes     varchar( 2000 )    null,
    superior_id          varchar( 255 )     null,
    start_date           timestamp          null,
    modify_date          timestamp          null,
    exp_date             timestamp          null,
    constraint ts_pk primary key( tx_id )
);

create index ts_fk on tx_superior( cikey );

/*
 * Pointbase doensn't support index as we expected, if you have index on
 * status, it locks them whevever the status changes.
 *
 * create index txs_expired on tx_superior( status, exp_date, superior_id );
 * create index txs_instance on tx_superior( instance_id, initiator_id );
 */


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
    log               varchar( 2000 )
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
    bin               blob( 20M ),
    constraint ad_pk primary key( cikey, detail_id )
)
lob pagesize 8K;


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
    bin               blob( 100M )
)
lob pagesize 8K;
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
    bin               blob( 100M )
)
lob pagesize 8K;
create index ss_fk on sync_store( cikey );


/**
 * dlv_message
 *
 * Delivery service message table; callback messages are stored here.
 */
create table dlv_message
(
    conv_id           varchar( 128 ),
    conv_type         integer,
    message_guid      varchar( 50 ),
    domain_ref        smallint,
    process_id        varchar( 100 ),
    revision_tag      varchar( 50 ),
    operation_name    varchar( 128 ),
    receive_date      timestamp,
    state             integer       default 0       not null,
    res_process_guid  varchar( 50 ),
    res_subscriber    varchar( 128 ),
    properties        varchar( 1000 ),
    ext_string1       varchar( 100 ),
    ext_string2       varchar( 100 ),
    ext_int1          integer,
    constraint dm_pk primary key( message_guid )
);

/*
create index dm_conversation on dlv_message( state, conv_id, operation_name );
*/

/**
 * dlv_message_bin
 *
 * The contents of the callback message are stored in this table.  The
 * callback message is split across two tables so that when we update
 * callback message state we do not cause inserting threads to block.
 */
create table dlv_message_bin
(
    message_guid      varchar( 50 ),
    domain_ref        smallint,
    bin_csize         integer,
    bin_usize         integer,
    bin               blob( 20M ),
    constraint dmb_pk primary key( message_guid )
)
lob pagesize 4K;


/**
 * dlv_subscription
 *
 * Delivery service subscription table; Subscriptions are stored here.
 */
create table dlv_subscription
(
    conv_id           varchar( 128 ),
    conv_type         integer,
    cikey             integer,
    domain_ref        smallint,
    process_id        varchar( 100 ),
    revision_tag      varchar( 50 ),
    process_guid      varchar( 50 ),
    operation_name    varchar( 128 ),
    subscriber_id     varchar( 128 ),
    service_name      varchar( 128 ),
    subscription_date timestamp,
    state             integer       default 0       not null,
    properties        varchar( 2000 ),
    ext_string1       varchar( 100 ),
    ext_string2       varchar( 100 ),
    ext_int1          integer,
    constraint ds_pk primary key( conv_id, subscriber_id )
);

/*
 * IMPORTANT: don't create an index on state ... this column changes very
 * often and it doesn't have many values.  When we update we will end up
 * locking a LOT of rows.  This can lead to a lot of lock time-outs.

create index ds_fk on dlv_subscription( cikey );
create index ds_conversation on dlv_subscription( state, process_id, operation_name );
*/


/**
 * invoke_message
 *
 * All the asynchronous invocation messages are stored in this table before
 * being dispatched to the engine.
 */
create table invoke_message
(
    conv_id           varchar( 128 ),
    message_guid      varchar( 50 ),
    domain_ref        smallint,
    process_id        varchar( 100 ),
    revision_tag      varchar( 50 ),
    operation_name    varchar( 128 ),
    receive_date      timestamp,
    state             integer     default 0       not null,
    priority          integer,
    properties        varchar( 2000 ),
    ext_string1       varchar( 100 ),
    ext_string2       varchar( 100 ),
    ext_int1          integer,
    constraint im_pk primary key( message_guid )
);

/**
 * invoke_message_bin
 *
 * The contents of asynchronous invocation messages are stored here.  The
 * invocation message is split across two tables so that when we update
 * invocation message state we do not cause inserting threads to block.
 */
create table invoke_message_bin
(
    message_guid      varchar( 50 ),
    domain_ref        smallint,
    bin_csize         integer,
    bin_usize         integer,
    bin               blob( 20M ),
    constraint im_pk primary key( message_guid )
)
lob pagesize 4K;

/**
 * task
 *
 * All the properties of the task messages are stored here.
 */
create table task
(
    domain_ref        smallint,
    conversation_id   varchar( 128 ),
    title             varchar( 50 ),
    creation_date     timestamp,
    creator           varchar( 100 ),
    modify_date       timestamp,
    modifier          varchar( 100 ),
    assignee          varchar( 100 ),
    status            varchar( 50 ),
    expired           smallint    default 0       not null,
    exp_date          timestamp,
    priority          integer     default 0       not null,
    template          varchar( 50 ),
    custom_key        varchar( 128 ),
    conclusion        varchar( 256 ),
    ext_string1       varchar( 100 ),
    ext_string2       varchar( 100 ),
    ext_int1          integer
);

create index ts_conv on task( conversation_id );

/**
 * process_revision
 *
 * List of all process revisions, recorded in order of deployment
 * for each process (version sequence is incremented each time a new
 * revision of a process is deployed)
 */
create table process_revision
(
    domain_ref       smallint,
    process_guid     varchar( 50 ),
    process_id       varchar( 100 ),
    revision_tag     varchar( 50 ),
    version_seq      integer,
    state            integer,
    lifecycle        integer,
    deploy_user      varchar( 100 ),
    deploy_timestamp number( 38 ),
    constraint pr_pk primary key( domain_ref, process_id, revision_tag )
);

create table process_default
(
    domain_ref       smallint,
    process_id       varchar( 100 ),
    default_revision varchar( 50 ),
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
    process_id       varchar( 100 ),
    revision_tag     varchar( 50 ),
    event_date       timestamp,
    type             integer,
    category         integer,
    message          varchar( 255 ),
    details          varchar( 2000 )
);

create index pl_fk( process_id, revision_tag );

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
 * loan_customer
 *
 * Table used to store customer information for loan EJB.
 */
create table loan_customer
(
    ssn               varchar( 11 ),
    name              varchar( 50 ),
    email             varchar( 30 ),
    provider          varchar( 20 ),
    status            varchar( 1 ),
    constraint lc_pk primary key( email )
);
insert into loan_customer values( '123-12-1234','demo1', 'demo1@otn.com', null, null );
insert into loan_customer values( '087-65-4321','demo2', 'demo2@otn.com', null, null );


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
create view work_list
as select ci.cikey, wi.node_id, wi.scope_id, wi.count_id,
          ci.title, ci.process_id, ci.priority as ci_priority, ci.state as ci_state,
          wi.label, wi.exp_date, wi.priority as wi_priority, wi.state as wi_state
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
 *     + instance test run name       (test_run_name)
 *     + instance test run id         (test_run_id)
 *     + instance test suite          (test_suite)
 *     + instance test location       (test_location)
 */
create view admin_list_ci
as select cikey, domain_ref as ci_domain_ref, process_id, revision_tag,
          creation_date as ci_creation_date, creator as ci_creator,
          modify_date as ci_modify_date, modifier as ci_modifier,
          state as ci_state, priority as ci_priority, title,
          status, stage, conversation_id, metadata, root_id, parent_id,
          test_run_name, test_run_id, test_suite, test_location
   from cube_instance;


/**
 * view admin_list_cx
 *
 * Simple join between cube_instance and ci_indexes tables ... created
 * to allow for consistent administration finder class interface.
 */
create view admin_list_cx
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
create view admin_list_wi
as select wi.cikey, wi.node_id, wi.scope_id, wi.count_id,
          wi.creation_date as wi_creation_date, wi.creator as wi_creator,
          wi.modify_date as wi_modify_date, wi.modifier as wi_modifier,
          wi.state as wi_state, wi.transition,
          wi.exp_date, exp_flag, wi.priority as wi_priority,
          wi.label, wi.custom_id, wi.comments, wi.reference_id,
          wi.execution_type,
          ci.domain_ref as ci_domain_ref,
          ci.process_id as process_id, ci.revision_tag as revision_tag,
          ci.title as title, ci.root_id, ci.parent_id
   from cube_instance ci left outer join work_item wi
   on ci.cikey = wi.cikey;

/**
 * procedure cx_delete_cis
 *
 * Deletes all the cube instances belonging to a particular domain.  Since we
 * don't have referential integrity on the tables (for performance reasons),
 * we need this method to help clean up the database easily.
 */
create procedure cx_delete_cis_by_domain_ref( in p_domain_ref smallint )
language java
specific cx_delete_cis
deterministic
no sql
external name "com.collaxa.cube.engine.adaptors.pointbase.PointBaseStoredProcedures::deleteInstancesByDomainRef"
parameter style sql;

/**
 * procedure cx_delete_cis_by_pcs_id
 *
 * Deletes all the cube instances in the system.  Since we don't have
 * referential integrity on the tables (for performance reasons), we
 * need this method to help clean up the database easily.
 */
create procedure cx_delete_cis_by_pcs_id( in p_pcs_id varchar( 32 ), in p_rev_tag varchar( 50 ))
language java
specific cx_delete_cis_by_pcs_id
deterministic
no sql
external name "com.collaxa.cube.engine.adaptors.pointbase.PointBaseStoredProcedures::deleteAllInstancesByProcessId"
parameter style sql;

/**
 * procedure cx_delete_ci
 *
 * Deletes the cube instance in the system.  Since we don't have
 * referential integrity on the tables (for performance reasons), we
 * need this method to help clean up the database easily.
 */
create procedure cx_delete_ci( in p_ci_key integer )
language java
specific cx_delete_ci
deterministic
no sql
external name "com.collaxa.cube.engine.adaptors.pointbase.PointBaseStoredProcedures::deleteInstance"
parameter style sql;
