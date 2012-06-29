
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

call cx_drop_object( 'version_server', 1 );
call cx_drop_object( 'domain', 1 );
call cx_drop_object( 'id_range', 1 );
call cx_drop_object( 'namespace', 1 );


/**
 * version
 *
 * Version information; allows run-time engine to check if correct database
 * schema has been installed.
 */
create table version_server
(
    guid            varchar( 50 ),
    dbtype          varchar( 50 )
);
insert into version_server values( '2.0.2', 'pointbase' );
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
    domain_id       varchar( 50 )   not null,
    domain_ref      smallint        not null,
    constraint dom_pk primary key( domain_ref )
);

/**
 * id_range
 *
 * Stores id block ranges for all keys in the Collaxa system.
 */
create table id_range
(
    range_name      varchar( 50 )   not null,
    next_range      integer         not null,
    dummy_col       varchar( 1 )    null
);
insert into id_range( range_name, next_range ) values( 'cikey', 1 );
insert into id_range( range_name, next_range ) values( 'namespace', 1 );
commit;

/**
 * namespace
 *
 * Namespace uris are mapped to an internal integer (index). All the xml components
 * could make use of the namespace index to reduce the space in memory or in db.
 * This is a global namespace repository per server, these namespace id is unique
 * across multiple domains.
 */
create table namespace
(
    namespace_id              smallint        not null,
    namespace_uri             varchar( 1000 )  not null,
    constraint namespace_pk primary key( namespace_id )
);
insert into namespace values( -1, 'mutex' );

commit;
