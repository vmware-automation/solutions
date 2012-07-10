
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
 * Collaxa Database Schema for Sybase
 *
 * The tables and views defined within this file may be installed on
 * your SQL Server instance by using the osql command-line utility.
 * For example:
 *
 * isql -Uuser -Ppassword -Ddatabase
 *      -i c:\orabpel\system\database\scripts\domain_sybase.ddl
 *      -o c:\orabpel\system\database\scripts\domain_sybase.out
 *
 * Before installing the database schema, please ensure that the user
 * has the necessary permissions; CREATE PROCEDURE, CREATE TABLE and
 * CREATE VIEW are required.
 *
 * NOTE: the database user must also have their DEFAULT database
 * set to the database where the Collaxa schema is to be installed.
 * Otherwise, you can uncomment the following line and replace the
 * name of the database with the one you are configuring for Collaxa.
 *
 * -- Uncomment the following lines if your user does not have their
 * -- DEFAULT database set to the Collaxa database.
 * --
 * use [database]
 * go
 */

/**
 * Drop all tables/views/procedures before we begin
 */
if exists ( select name from sysobjects
            where name = 'work_list' and type = 'V' )
begin
    drop view work_list
    print "Dropping view work_list"
end
go
if exists ( select name from sysobjects
            where name = 'admin_list_ci' and type = 'V' )
begin
    drop view admin_list_ci
    print "Dropping view admin_list_ci"
end
go
if exists ( select name from sysobjects
            where name = 'admin_list_cx' and type = 'V' )
begin
    drop view admin_list_cx
    print "Dropping view admin_list_cx"
end
go
if exists ( select name from sysobjects
            where name = 'admin_list_wi' and type = 'V' )
begin
    drop view admin_list_wi
    print "Dropping view admin_list_wi"
end
go
if exists ( select name from sysobjects
            where name = 'scope_activation' and type = 'U' )
begin
    drop table scope_activation
    print "Dropping table scope_activation"
end
go
if exists ( select name from sysobjects
            where name = 'xml_document' and type = 'U' )
begin
    drop table document
    print "Dropping table xml_document"
end
go
if exists ( select name from sysobjects
            where name = 'audit_trail' and type = 'U' )
begin
    drop table audit_trail
    print "Dropping table audit_trail"
end
go
if exists ( select name from sysobjects
            where name = 'audit_details' and type = 'U' )
begin
    drop table audit_details
    print "Dropping table audit_details"
end
go
if exists ( select name from sysobjects
            where name = 'sync_trail' and type = 'U' )
begin
    drop table sync_trail
    print "Dropping table sync_trail"
end
go
if exists ( select name from sysobjects
            where name = 'sync_store' and type = 'U' )
begin
    drop table sync_store
    print "Dropping table sync_store"
end
go
if exists ( select name from sysobjects
            where name = 'wi_exception' and type = 'U' )
begin
    drop table wi_exception
    print "Dropping table wi_exception"
end
go
if exists ( select name from sysobjects
            where name = 'dlv_message' and type = 'U' )
begin
    drop table dlv_message
    print "Dropping table dlv_message"
end
go
if exists ( select name from sysobjects
            where name = 'invoke_message' and type = 'U' )
begin
    drop table invoke_message
    print "Dropping table invoke_message"
end
go
if exists ( select name from sysobjects
            where name = 'dlv_subscription' and type = 'U' )
begin
    drop table dlv_subscription
    print "Dropping table dlv_subscription"
end
go
if exists ( select name from sysobjects
            where name = 'work_item' and type = 'U' )
begin
    drop table work_item
    print "Dropping table work_item"
end
go
if exists ( select name from sysobjects
            where name = 'ci_indexes' and type = 'U' )
begin
    drop table ci_indexes
    print "Dropping table ci_indexes"
end
go
if exists ( select name from sysobjects
            where name = 'cube_scope' and type = 'U' )
begin
    drop table cube_scope
    print "Dropping table cube_scope"
end
go
if exists ( select name from sysobjects
            where name = 'cube_instance' and type = 'U' )
begin
    drop table cube_instance
    print "Dropping table cube_instance"
end
go
if exists ( select name from sysobjects
            where name = 'loan_customer' and type = 'U' )
begin
    drop table loan_customer
    print "Dropping table loan_customer"
end
go
if exists ( select name from sysobjects
            where name = 'version' and type = 'U' )
begin
    drop table version
    print "Dropping table version"
end
go
if exists ( select name from sysobjects
            where name = 'task' and type = 'U' )
begin
    drop table task
    print "Dropping table task"
end
go
if exists ( select name from sysobjects
            where name = 'process_revision' and type = 'U' )
begin
    drop table process_revision
    print "Dropping table process_revision"
end
go
if exists ( select name from sysobjects
            where name = 'process_default' and type = 'U' )
begin
    drop table process_default
    print "Dropping table process_default"
end
go
if exists ( select name from sysobjects
            where name = 'process_log' and type = 'U' )
begin
    drop table process_log
    print "Dropping table process_log"
end
go
if exists ( select name from sysobjects
            where name = 'native_correlation' and type = 'U' )
begin
    drop table native_correlation
    print "Dropping table native_correlation"
end
go
if exists ( select name from sysobjects
            where name = 'document_dlv_msg_ref' and type = 'U' )
begin
    drop table document
    print "Dropping table document_dlv_msg_ref"
end
go
if exists ( select name from sysobjects
            where name = 'document_ci_ref' and type = 'U' )
begin
    drop table document
    print "Dropping table document_ci_ref"
end
go

/**
 * version
 *
 * Version information; allows run-time engine to check if correct database
 * schema has been installed.
 */
create table version
(
    guid            varchar( 50 )   not null,
    dbtype          varchar( 50 )
)
lock datarows
print "Creating table version"
go

print "Inserting value '2.0.45' into version"
insert into version values( '2.0.45', 'sybase' )
go


/**
 * cube_instance
 *
 * Stores generated cube instances; master table of system.  Cube instances
 * are unique across all processes for one installation.
 */
create table cube_instance
(
    cikey           integer     constraint ci_pk primary key,
    domain_ref      smallint                not null,
    process_id      varchar( 100 )          not null,
    revision_tag    varchar( 50 )           not null,
    creation_date   datetime                null,
    creator         varchar( 100 )          null,
    modify_date     datetime                null,
    modifier        varchar( 100 )          null,
    state           integer                 not null,
    priority        integer                 null,
    title           varchar( 50 )           null,
    status          varchar( 100 )          null,
    stage           varchar( 100 )          null,
    conversation_id varchar( 100 )          null,
    root_id         varchar( 100 )          null,
    parent_id       varchar( 100 )          null,
    scope_revision  integer                 not null,
    scope_csize     integer                 not null,
    scope_usize     integer                 not null,
    process_guid    varchar( 50 )           not null,
    process_type    integer                 null,
    metadata        text                    null,
    ext_string1     varchar( 100 )          null,
    ext_string2     varchar( 100 )          null,
    ext_int1        integer                 null,
    test_run_name   varchar( 100 )          null,
    test_run_id     varchar( 100 )          null,
    test_suite      varchar( 100 )          null,
    test_location   varchar( 100 )          null    
)
lock datarows
print "Creating table cube_instance"
go

create nonclustered index ci_custom on cube_instance( cikey, conversation_id )
go

/**
 * cube_scope
 *
 * Stores generated scopes of generated cube instances.
 */
create table cube_scope
(
    cikey           integer     constraint cs_pk primary key,
    domain_ref      smallint    not null,
    modify_date     datetime    null,
    scope_bin       image       null
)
lock datarows
print "Creating table cube_scope"
go

/**
 * ci_indexes
 *
 * Stores searchable custom keys associated with an instance.
 */
create table ci_indexes
(
    cikey           integer           constraint cx_pk primary key,
    index_1         varchar( 100 )    null,
    index_2         varchar( 100 )    null,
    index_3         varchar( 100 )    null,
    index_4         varchar( 100 )    null,
    index_5         varchar( 100 )    null,
    index_6         varchar( 100 )    null
)
lock datarows
print "Creating table ci_indexes"
go

create index ci_index_1 on ci_indexes( index_1 )
go
create index ci_index_2 on ci_indexes( index_2 )
go
create index ci_index_3 on ci_indexes( index_3 )
go
create index ci_index_4 on ci_indexes( index_4 )
go
create index ci_index_5 on ci_indexes( index_5 )
go
create index ci_index_6 on ci_indexes( index_6 )
go

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
    cikey          integer              not null,
    domain_ref     smallint             not null,
    scope_id       varchar( 15 )        not null,
    action         integer              not null,
    creation_date  datetime             null,
    modify_date    datetime             null,
    process_guid   varchar( 50 )        not null
)
lock datarows
print "Creating table scope_activation"
go

create unique clustered index sa_fk on scope_activation( cikey, scope_id, action )
go

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
    cikey           integer                     not null,
    node_id         varchar( 15 )               not null,
    scope_id        varchar( 15 )               not null,
    count_id        integer                     not null,
    domain_ref      smallint                    not null,
    creation_date   datetime                    null,
    creator         varchar( 100 )              null,
    modify_date     datetime                    null,
    modifier        varchar( 100 )              null,
    state           integer                     not null,
    transition      integer                     null,
    exception       smallint    default( 0 )    not null,
    exp_date        datetime                    null,
    exp_flag        smallint    default( 0 )    not null,
    priority        integer                     null,
    label           varchar( 50 )               null,
    custom_id       varchar( 100 )              null,
    comments        varchar( 256 )              null,
    reference_id    varchar( 128 )              null,
    idempotent_flag smallint    default( 0 )    not null,
    process_guid    varchar( 50 )               not null,
    execution_type  integer     default( 0 )    not null,
    first_delay     integer                     null,
    delay           integer                     null,
    ext_string1     varchar( 100 )              null,
    ext_string2     varchar( 100 )              null,
    constraint wi_pk primary key( cikey, node_id, scope_id, count_id )
)
lock datarows
print "Creating table work_item"
go

/**
 * wi_exception
 *
 * Stores exception messages generated by failed attempts to perform, manage
 * or complete a workitem.  Each failed attempt is logged as an exception
 * message.
 */
create table wi_exception
(
    cikey           integer             not null,
    node_id         varchar( 15 )       not null,
    scope_id        varchar( 15 )       not null,
    count_id        integer             not null,
    domain_ref      smallint            not null,
    retry_count     integer             null,
    retry_date      datetime            null,
    message         text                null
)
lock datarows
print "Creating table wi_exception"
go

create unique clustered index wx_fk on wi_exception( cikey, node_id, scope_id, count_id )
go

/**
 * document
 *
 * document persistence table; all large objects in the system persist themselves
 * here.
 */
create table xml_document
(
    dockey           varchar( 128 )      constraint xmldoc_pk primary key,
    domain_ref       smallint           not null,
    bin_csize        integer            null,
    bin_usize        integer            null,
    modify_date      datetime           null,
    bin_format       smallint           null,
    bin              image              null
)
lock datarows
print "Creating table xml_document"
go

/**
 * dlv_message
 *
 * Delivery service message table; callback messages are stored here.
 */
create table dlv_message
(
    conv_id              varchar( 128 )             not null,
    conv_type            integer                    not null,
    message_guid         varchar( 50 )              not null,
    domain_ref           smallint                   not null,
    process_id           varchar( 100 )             null,
    revision_tag         varchar( 50 )              null,
    operation_name       varchar( 128 )             null,
    receive_date         datetime                   null,
    state                integer   default( 0 )     not null,
    res_process_guid     varchar( 50 )              null,
    res_subscriber       varchar( 128 )             null,
    properties           text                       null,
    ext_string1          varchar( 100 )             null,
    ext_string2          varchar( 100 )             null,
    ext_int1             integer                    null,
    constraint dm_pk primary key( message_guid )
)
lock datarows
print "Creating table dlv_message"
go


/**
 * dlv_subscription
 *
 * Delivery service subscription table; Subscriptions are stored here.
 */
create table dlv_subscription
(
    conv_id              varchar( 128 )     not null,
    conv_type            integer            not null,
    cikey                integer            not null,
    domain_ref           smallint           not null,
    process_id           varchar( 100 )     not null,
    revision_tag         varchar( 50 )      not null,
    process_guid         varchar( 50 )      not null,
    operation_name       varchar( 128 )     not null,
    subscriber_id        varchar( 128 )     not null,
    service_name         varchar( 128 )     null,
    subscription_date    datetime           null,
    state                integer   default( 0 )     not null,
    properties           text               null,
    ext_string1          varchar( 100 )     null,
    ext_string2          varchar( 100 )     null,
    ext_int1             integer            null,
    constraint ds_pk primary key( conv_id, subscriber_id )
)
lock datarows
print "Creating table dlv_subscription"
go

create nonclustered index ds_fk on dlv_subscription( cikey )
go

create nonclustered index ds_conversation on dlv_subscription( state, process_id, operation_name )
go


/**
 * invoke_message
 *
 * All the asynchronous invocation messages are stored in this table before
 * being dispatched to the engine.
 */
create table invoke_message
(
    conv_id           varchar( 128 )        not null,
    message_guid      varchar( 50 )         not null,
    domain_ref        smallint              not null,
    process_id        varchar( 100 )        not null,
    revision_tag      varchar( 50 )         null,
    operation_name    varchar( 128 )        not null,
    receive_date      datetime              null,
    state             integer     default 0       not null,
    priority          integer,
    properties        text                  null,
    ext_string1       varchar( 100 )        null,
    ext_string2       varchar( 100 )        null,
    ext_int1          integer               null,
    master_conv_id    varchar(128)          null,
    constraint im_pk primary key( message_guid )
)
lock datarows
print "Creating table invoke_message"
go

create index im_master_conv_id on invoke_message( master_conv_id )
go


/**
 * task
 *
 * All the properties of the task messages are stored here.
 */
create table task
(
    domain_ref        smallint                    not null,
    conversation_id   varchar( 128 )              not null,
    title             varchar( 50 )               null,
    creation_date     datetime                    null,
    creator           varchar( 100 )              null,
    modify_date       datetime                    null,
    modifier          varchar( 100 )              null,
    assignee          varchar( 100 )              null,
    status            varchar( 50 )               null,
    expired           smallint    default 0       not null,
    exp_date          datetime                    null,
    priority          integer     default 0       not null,
    template          varchar( 50 )               null,
    custom_key        varchar( 128 )              null,
    conclusion        varchar( 256 )              null,
    ext_string1       varchar( 100 )              null,
    ext_string2       varchar( 100 )              null,
    ext_int1          integer                     null
)
lock datarows
print "Creating table task"
go

create clustered index ts_conv on task( conversation_id )
go

/**
 * process_revision
 *
 * List of all process revisions, recorded in order of deployment
 * for each process (version sequence is incremented each time a new
 * revision of a process is deployed)
 */
create table process_revision
(
    domain_ref       smallint               not null,
    process_guid     varchar( 50 )          not null,
    process_id       varchar( 100 )         not null,
    revision_tag     varchar( 50 )          not null,
    version_seq      integer                not null,
    state            integer                not null,
    lifecycle        integer                not null,
    deploy_user      varchar( 100 )         null,
    deploy_timestamp numeric( 38, 0 )       null,
    constraint pr_pk primary key( domain_ref, process_id, revision_tag )
)
lock datarows
print "Creating table process_revision"
go

create table process_default
(
    domain_ref       smallint               not null,
    process_id       varchar( 100 )         not null,
    default_revision varchar( 50 )          not null,
    constraint pd_pk primary key( domain_ref, process_id )
)
lock datarows
print "Creating table process_default"
go

/**
 * process_log
 *
 * Record of events (informational, debug, error) encountered while
 * interacting with a process.
 */
create table process_log
(
    domain_ref       smallint               not null,
    process_id       varchar( 100 )         not null,
    revision_tag     varchar( 50 )          not null,
    event_date       datetime               null,
    type             integer                not null,
    category         integer                not null,
    message          varchar( 255 )         null,
    details          text                   null
)
lock datarows
print "Creating table process_log"
go

create index pl_fk on process_log( process_id, revision_tag )
go

/**
 * native_correlation
 *
 * Association table (Map) between Engine Conversation Id's
 * and Native Correlation Id's (such as JMS/AQ Message Id's)
 */
create table native_correlation
(
    domain_ref              smallint        not null,
    native_correlation_id   varchar( 100 )  not null,
    conversation_id         varchar( 100 )  not null
)
lock datarows
print "Creating table native_correlation"
go

create index nc_corr on native_correlation( native_correlation_id )
go
create index nc_conv on native_correlation( conversation_id )
go

/**
 * audit_trail
 *
 * Stores record of actions taken on an instance (application, system,
 * administrative and errors).
 */
create table audit_trail
(
    cikey             integer               not null,
    domain_ref        smallint              not null,
    count_id          integer               not null,
    log               text                  null
)
lock datarows
print "Creating table audit_trail"
go

create clustered index at_fk on audit_trail( cikey )
go

/**
 * audit_details
 *
 * Stores details for audit trail events that are large in size.  Details
 * that are smaller than a specified size are inlined with the events in
 * the audit_trail table.
 */
create table audit_details
(
    cikey             integer               not null,
    domain_ref        smallint              not null,
    detail_id         integer               not null,
    bin_csize         integer               null,
    bin_usize         integer               null,
    bin               image                 null,
    doc_ref           varchar(128)          null,
    constraint ad_pk primary key( cikey, detail_id )
)
lock datarows
print "Creating table audit_details"
go


/**
 * sync_trail
 *
 * Audit trail of completed synchronous instances are stored here.  The audit
 * trail is written out here so that we don't have to insert a very LARGE
 * number rows for long running instances.
 */
create table sync_trail
(
    cikey             integer               not null,
    domain_ref        smallint              not null,
    bin_csize         integer               null,
    bin_usize         integer               null,
    bin               image                 null,
    constraint st_pk primary key( cikey )
)
lock datarows
print "Creating table sync_trail"
go

/**
 * sync_store
 *
 * The work items of completed synchronous instances are stored here.
 */
create table sync_store
(
    cikey             integer               not null,
    domain_ref        smallint              not null,
    bin_csize         integer               null,
    bin_usize         integer               null,
    bin               image                 null,
    constraint ss_pk primary key( cikey )
)
lock datarows
print "Creating table sync_store"
go

/**
 * document_ci_ref
 *
 * cube instances reference to document are recorded here.
 */
create table document_ci_ref
(
    dockey           varchar( 128 ),
    cikey            integer,
    domain_ref       smallint,
    constraint doc_ci_ref_pk primary key( dockey, cikey )
)
lock datarows
print "Creating table document_ci_ref"
go

create clustered index doc_ci_fk on document_ci_ref( cikey )
go


/**
 * document_ci_ref
 *
 * invoke_message and dlv_message has references to document which are recorded here.
 */
create table document_dlv_msg_ref
(
    dockey           varchar( 128 ),
    part_name        varchar(50),
    message_guid     varchar( 128 ),
    domain_ref       smallint,
    message_type     smallint,
    constraint doc_dlv_ref_pk primary key( dockey, message_guid )
)
lock datarows
print "Creating table document_dlv_msg_ref"
go

create clustered index doc_dlv_msg_fk on document_dlv_msg_ref( message_guid )
go

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
 *     + work item performer id
 */
create view work_list
as select ci.cikey, wi.node_id, wi.scope_id, wi.count_id,
          ci.title, ci.process_id, ci.priority ci_priority, ci.state ci_state,
          wi.label, wi.exp_date, wi.priority wi_priority, wi.state wi_state
   from cube_instance ci, work_item wi
   where ci.cikey = wi.cikey and
         ( wi.state = 1 or wi.state = 2 or wi.state = 3 )
go
print "Creating view work_list"
go

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
as select cikey, domain_ref ci_domain_ref, process_id, revision_tag,
          creation_date ci_creation_date, creator ci_creator,
          modify_date ci_modify_date, modifier ci_modifier,
          state ci_state, priority ci_priority, title,
          status, stage, conversation_id, metadata, root_id, parent_id,
          test_run_name, test_run_id, test_suite, test_location
   from cube_instance
go
print "Creating view admin_list_ci"
go

/**
 * view admin_list_cx
 *
 * Simple join between cube_instance and ci_indexes tables ... created
 * to allow for consistent administration finder class interface.
 */
create view admin_list_cx
as select ci.cikey, domain_ref ci_domain_ref, process_id, revision_tag,
          creation_date ci_creation_date, creator ci_creator,
          modify_date ci_modify_date, modifier ci_modifier,
          state ci_state, priority ci_priority, title,
          status, stage, conversation_id, metadata,
          root_id, parent_id,
          index_1, index_2, index_3, index_4, index_5, index_6
   from cube_instance ci, ci_indexes cx
   where ci.cikey = cx.cikey
go
print "Creating view admin_list_cx"
go

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
          wi.creation_date wi_creation_date, wi.creator wi_creator,
          wi.modify_date wi_modify_date, wi.modifier wi_modifier,
          wi.state wi_state, wi.transition,
          wi.exp_date, exp_flag, wi.priority wi_priority,
          wi.label, wi.custom_id, wi.comments, wi.reference_id,
          wi.execution_type,
          ci.domain_ref ci_domain_ref,
          ci.process_id process_id, ci.revision_tag revision_tag,
          ci.title title, ci.root_id, ci.parent_id
   from cube_instance ci, work_item wi
   where ci.cikey *= wi.cikey
go
print "Creating view admin_list_wi"
go


-- <tables for sample processes>

/**
 * loan_customer
 *
 * Table used to store customer information for loan EJB.
 */
create table loan_customer
(
    ssn               varchar( 11 )     null,
    name              varchar( 50 )     null,
    email             varchar( 30 )     constraint lc_pk primary key,
    provider          varchar( 20 )     null,
    status            char( 1 )         null
)
lock datarows
print "Creating table loan_customer"
go

print "Inserting sample data into loan_customer"
insert into loan_customer values( '123-12-1234', 'demo1', 'demo1@otn.com', null, null )
insert into loan_customer values( '087-65-4321', 'demo2', 'demo2@otn.com', null, null )
go

-- </tables for sample processes>


if exists ( select * from sysobjects
            where name = 'cx_insert_cs' and type = 'P' )
begin
    drop procedure cx_insert_cs
    print "Dropping procedure cx_insert_cs"
end
go
print "Creating procedure cx_insert_cs"
go

/**
 * procedure cx_insert_cs
 *
 * Stored procedure to initialize the binary column of a cube scope row.
 * If the row does not exist, the row is created (a default value is
 * used for the scope binary).
 */
create procedure cx_insert_cs
    @p_cikey int,
    @p_domain_ref smallint
as
    -- Eliminating the row count message results in a slight performance
    -- boost for stored procedures
    --
    set nocount on

    -- Find out if the scope row for this instance has already been inserted
    --
    if not exists ( select *
                    from cube_scope
                    where cikey = @p_cikey )
    begin
        insert into cube_scope( cikey, domain_ref, scope_bin )
        values( @p_cikey, @p_domain_ref, 0x0 )
    end

    return 0
go

exec sp_procxmode 'cx_insert_cs', 'anymode'
go


if exists ( select * from sysobjects
            where name = 'cx_insert_sa' and type = 'P' )
begin
    drop procedure cx_insert_sa
    print "Dropping procedure cx_insert_sa"
end
go
print "Creating procedure cx_insert_sa"
go

/**
 * procedure cx_insert_sa
 *
 * Stored procedure to do a "smart" insert of a scope activation message.
 * If a scope activation message already exists, don't bother to insert
 * and return 0 (this process can happen if two concurrent threads generate
 * an activation message for the same scope - say the method scope for
 * example - only one will insert properly; but both threads will race to
 * consume the activation message).
 */
create procedure cx_insert_sa
    @p_cikey int,
    @p_domain_ref smallint,
    @p_scope_id varchar( 10 ),
    @p_process_guid varchar( 50 ),
    @p_creation_date datetime,
    @r_success int output
as
    -- Eliminating the row count message results in a slight performance
    -- boost for stored procedures
    --
    set nocount on

    select @r_success = 1

    -- Find out if the scope activation row has already been inserted
    --
    if not exists ( select *
                    from scope_activation
                    where cikey = @p_cikey and scope_id = @p_scope_id )

        insert into scope_activation( cikey, domain_ref, scope_id,
                                      process_guid, creation_date )
        values( @p_cikey, @p_domain_ref, @p_scope_id,
                @p_process_guid, @p_creation_date )
    else
        select @r_success = 0

    return 0
go

exec sp_procxmode 'cx_insert_sa', 'anymode'
go


if exists ( select * from sysobjects
            where name = 'cx_insert_wx' and type = 'P' )
begin
    drop procedure cx_insert_wx
    print "Dropping procedure cx_insert_wx"
end
go
print "Creating procedure cx_insert_wx"
go

/**
 * procedure cx_insert_wx
 *
 * Stored procedure to insert a retry exception message into the
 * wi_exception table.  Each failed attempt to retry a work item
 * gets logged in this table; each attempt is keyed by the work item
 * key and an increasing retry count value.
 */
create procedure cx_insert_wx
    @p_cikey int,
    @p_node_id varchar( 5 ),
    @p_scope_id varchar( 10 ),
    @p_count_id int,
    @p_domain_ref smallint,
    @p_retry_date datetime,
    @p_message varchar( 2000 ),
    @r_retry_count int output
as
    -- Eliminating the row count message results in a slight performance
    -- boost for stored procedures
    --
    set nocount on

    declare @v_retry_count int
    select @v_retry_count = ( select max( retry_count )
                              from wi_exception
                              where cikey = @p_cikey and
                                    node_id = @p_node_id and
                                    scope_id = @p_scope_id and
                                    count_id = @p_count_id )
    select @v_retry_count = @v_retry_count + 1

    insert into wi_exception( cikey, node_id, scope_id, count_id,
                              domain_ref, retry_count, retry_date, message )
    values( @p_cikey, @p_node_id, @p_scope_id, @p_count_id,
            @p_domain_ref, @v_retry_count, @p_retry_date, @p_message )

    -- Set the retry count out parameter to the retry count just
    -- inserted into the database.
    --
    select @r_retry_count = @v_retry_count
    return 0
go

exec sp_procxmode 'cx_insert_wx', 'anymode'
go


if exists ( select * from sysobjects
            where name = 'cx_delete_ci' and type = 'P' )
begin
    drop procedure cx_delete_ci
    print "Dropping procedure cx_delete_ci"
end
go
print "Creating procedure cx_delete_ci"
go

/**
 * procedure cx_delete_ci
 *
 * Deletes a cube instance and all rows in other Collaxa tables that
 * reference the cube instance.  Since we don't have referential
 * integrity on the tables (for performance reasons), we need this
 * method to help clean up the database easily.
 */
create procedure cx_delete_ci
    @p_cikey int
as
    -- Eliminating the row count message results in a slight performance
    -- boost for stored procedures
    --
    set nocount on

    -- Delete the cube instance first
    --
    delete from cube_instance where cikey = @p_cikey

    -- Then cascade the delete to other tables with references
    --
    delete from cube_scope where cikey = @p_cikey
    delete from work_item where cikey = @p_cikey
    delete from wi_exception where cikey = @p_cikey
    delete from document_ci_ref where cikey = @p_cikey
    delete from scope_activation where cikey = @p_cikey
    delete from dlv_subscription where cikey = @p_cikey
    delete from audit_trail where cikey = @p_cikey
    delete from audit_details where cikey = @p_cikey
    delete from sync_trail where cikey = @p_cikey
    delete from sync_store where cikey = @p_cikey
    execute cx_delete_txs @p_cikey

    return 0
go

exec sp_procxmode 'cx_delete_ci', 'anymode'
go


if exists ( select * from sysobjects
            where name = 'cx_delete_cis' and type = 'P' )
begin
    drop procedure cx_delete_cis
    print "Dropping procedure cx_delete_cis"
end
go
print "Creating procedure cx_delete_cis"
go

/**
 * procedure cx_delete_cis
 *
 * Deletes all the cube instances in the system.  Since we don't have
 * referential integrity on the tables (for performance reasons), we
 * need this method to help clean up the database easily.
 */
create procedure cx_delete_cis
    @p_domain_ref smallint,
    @r_row_count int output
as
    -- Eliminating the row count message results in a slight performance
    -- boost for stored procedures
    --
    set nocount on

    delete from cube_instance where domain_ref = @p_domain_ref
    select @r_row_count = @@rowcount

    delete from cube_scope where domain_ref = @p_domain_ref
    delete from work_item where domain_ref = @p_domain_ref
    delete from wi_exception where domain_ref = @p_domain_ref
    delete from xml_document where domain_ref = @p_domain_ref
    delete from invoke_message where domain_ref = @p_domain_ref
    delete from dlv_message where domain_ref = @p_domain_ref
    delete from dlv_subscription where domain_ref = @p_domain_ref
    delete from scope_activation where domain_ref = @p_domain_ref
    delete from audit_trail where domain_ref = @p_domain_ref
    delete from audit_details where domain_ref = @p_domain_ref
    delete from sync_trail where domain_ref = @p_domain_ref
    delete from sync_store where domain_ref = @p_domain_ref
    delete from task where domain_ref = @p_domain_ref
    delete from document_ci_ref where domain_ref = @p_domain_ref
    delete from document_dlv_msg_ref where domain_ref = @p_domain_ref

    commit

    return 0
go

exec sp_procxmode 'cx_delete_cis', 'anymode'
go

if exists ( select * from sysobjects
            where name = 'cx_delete_cis_by_pcs_id' and type = 'P' )
begin
    drop procedure cx_delete_cis_by_pcs_id
    print "Dropping procedure cx_delete_cis_by_pcs_id"
end
go
print "Creating procedure cx_delete_cis_by_pcs_id"
go

/**
 * procedure cx_delete_cis_by_pcs_id
 *
 * Deletes all the cube instances in the system for the specified process id.
 * Since we don't have referential integrity on the tables
 * (for performance reasons), we need this method to help
 * clean up the database easily.
 */
create procedure cx_delete_cis_by_pcs_id
    @p_pcs_id varchar( 100 ),
    @p_rev_tag varchar( 50 ),
    @r_row_count int output
 as
    -- Eliminating the row count message results in a slight performance
    -- boost for stored procedures
    --
    set nocount on

    select @r_row_count = 0
    declare @v_cikey int

    declare c_cube_instance cursor for
        select cikey
        from cube_instance where
        process_id = @p_pcs_id and revision_tag = @p_rev_tag
        for update

    -- Iterate through all the cube instances and delete all references
    -- from other tables
    --
    open c_cube_instance
    fetch c_cube_instance into @v_cikey

    while( @@sqlstatus  = 0 )
    begin
        execute cx_delete_ci @v_cikey
        select @r_row_count = @r_row_count + 1

        -- Continue the traversal
        --
        fetch c_cube_instance into @v_cikey
    end

    close c_cube_instance
    deallocate cursor c_cube_instance
    
    commit
    return 0
go

exec sp_procxmode 'cx_delete_cis_by_pcs_id', 'anymode'
go

