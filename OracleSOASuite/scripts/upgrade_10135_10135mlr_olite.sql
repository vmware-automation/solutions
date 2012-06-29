Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/upgrade_10135_10135mlr_olite.sql /st_pcbpel_10.1.3.1/4 2010/07/26 12:23:38 karbalas Exp $
Rem
Rem upgrade_10135_10135mlr_olite.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      upgrade_10135_10135mlr_olite.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wstallar    05/05/10 - Backport wstallar_bug-8648362 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     11/03/09 - schema upgrade script for upgrading 10.1.3.5.0 to
Rem                           10.1.3.5.0 mlr level
Rem    ramisra     11/03/09 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

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

delete cluster_master;
commit;

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

/*
 * Bug 8648362
 */
CREATE TABLE WFRuleDictionaryNOTM
(
  dictionaryName VARCHAR2(200),
  dictionaryVersion VARCHAR2(200),
  numberOfTimesModified NUMBER,
  primary key (dictionaryName, dictionaryVersion)
);


/**
 * Update the DB version tables
 */
update version set guid = '10.1.3.5.0';
update version_server set guid = '10.1.3.5.0';
commit;
