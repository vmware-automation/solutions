
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
 * Update the version tables
 */
update version set guid = '10.1.3.4.5';
update version_server set guid = '10.1.3.4.1';
commit;

