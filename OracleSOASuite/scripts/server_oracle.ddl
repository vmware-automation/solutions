
/**
 * CONFIDENTIAL AND PROPRIETARY SOURCE CODE OF COLLAXA CORPORATION
 * Copyright (c) 2002 Collaxa Corporation. All Rights Reserved.
 *
 * Use of this Source Code is subject to the terms of the applicable
 * license agreement from Collaxa Corporation.
 *
 * The copyright notice(s) in this Source Code does not indicate
 * actual or intended publication of this Source Code.
 */


/**
 * Collaxa Server Database Schema for Oracle
 *
 * The tables and views defined within this file may be installed on
 * your Oracle server by using the sqlplus command-line utility.
 * For example:
 *
 * sqlplus user/password@TNSNAME \
 * @c:\orabpel\system\database\scripts\server_oracle.ddl
 *
 * Before installing the database schema, please ensure that the user
 * has the necessary permissions; usually CONNECT and RESOURCE are
 * sufficient.
 */


/**
 * Drop all tables before we begin
 */
drop table version_server;
drop table domain;
drop table id_range;
drop table domain_properties;

drop table cluster_message;
drop table cluster_master;
drop table cluster_node;

/**
 * version
 *
 * Version information; allows run-time engine to check if correct database
 * schema has been installed.
 */
create table version_server
(
    guid            varchar2( 50 ),
    dbtype          varchar2( 50 )
);
insert into version_server values( '10.1.3.5.0', 'oracle' );
commit;


/**
 * domain
 *
 * Domain identifiers are mapped to an internal integer (ref).  All the tables
 * in the Collaxa schema contain a domain_ref column to help deleting all
 * rows belonging to a particular domain.  We use a smallint rather than a
 * varchar( 50 ) in each table to cut down on the amount of information we
 * need to store.
 */
create table domain
(
    domain_id       varchar2( 50 )  not null,
    domain_ref      smallint        not null,
    deleted         smallint default 0 not null,
    constraint dom_pk primary key( domain_ref )
);

/**
 * id_range
 *
 * Stores id block ranges for all keys in the Collaxa system.
 */
create table id_range
(
    range_name      varchar2( 50 )  not null,
    next_range      integer         not null,
    dummy_col       varchar2( 1 )   null
);
insert into id_range( range_name, next_range ) values( 'cikey', 1 );
commit;

/**
 * All the distributed properties are stored in this table, these
 * properties are shared among clustered nodes.
 */
create table domain_properties
(
    domain_ref      smallint        not null,
    prop_id              varchar2(50)    not null,
    prop_value           varchar2(1024)   null,
	prop_name            varchar2(100)   null,
    prop_comment         varchar2(1000)  null,
    constraint dom_cfg_pk primary key( domain_ref, prop_id )
);
insert into domain_properties ( domain_ref, prop_id ) values( -1, '-1' );
commit;

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

@@workflow_oracle
Rem quit;
