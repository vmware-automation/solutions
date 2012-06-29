
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
if exists ( select * from sysobjects
            where name = 'version_server' and type = 'U' )
begin
    drop table version_server
    print "Dropping table version_server"
end
if exists ( select * from sysobjects
            where name = 'domain' and type = 'U' )
begin
    drop table domain
    print "Dropping table domain"
end
if exists ( select * from sysobjects
            where name = 'id_range' and type = 'U' )
begin
    drop table id_range
    print "Dropping table id_range"
end
if exists ( select * from sysobjects
            where name = 'namespace' and type = 'U' )
begin
    drop table namespace
    print "Dropping table namespace"
end

go


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
)
lock datarows
print "Creating table version_server"
go

print "Inserting value '2.0.3' into version_server"
insert into version_server values( '2.0.3', 'sybase' )
go


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
    domain_ref      smallint        constraint dom_pk primary key
)
lock datarows
print "Creating table domain"
go

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
)
lock datarows
print "Creating table id_range"
go
print "Inserting value 'cikey', 1 into id_range"
insert into id_range( range_name, next_range ) values( 'cikey', 1 )
go
print "Inserting value 'namespace', 1 into id_range"
insert into id_range( range_name, next_range ) values( 'namespace', 1 )
go

/**
 * namespace
 *
 * Namespace uris are mapped to an internal integer (index). All the xml
 * components could make use of the namespace index to reduce the space in
 * memory or in db. This is a global namespace repository per server, these
 * namespace id is unique across multiple domains.
 */
create table namespace
(
    namespace_id    integer        constraint namespace_pk primary key,
    namespace_uri   varchar( 1000 )           not null
)
lock datarows
print "Creating table namespace"
go
print "Inserting value '-1' into namespace"
insert into namespace values( -1, 'mutex' )
go
