Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/upgrade_10135_10135mlr_oracle.sql /st_pcbpel_10.1.3.1/2 2010/05/20 11:27:07 wstallar Exp $
Rem
Rem upgrade_10135_10135mlr_oracle.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      upgrade_10135_10135mlr_oracle.sql - schema upgrade script
Rem
Rem    DESCRIPTION
Rem    This script will upgrade 10.1.3.5.0 schema to 10.1.3.5.0 MLR level.
Rem    Running of this script is indempotent which means if schema was upgraded
Rem    in past by running this script, rerunning this script again will be no-op
Rem    
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wstallar    05/05/10 - Backport wstallar_bug-8648362 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     11/03/09 - creation of script to upgrade 10.1.3.5.0 schema
Rem                           to 10.1.3.5.0 MLR level
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
 * Database tables for DB-based cluster support.
 */

DECLARE
 numberOfRows     Number;
 sqlStatement     VARCHAR2(300);
BEGIN
    SELECT COUNT(*) INTO numberOfRows FROM USER_TAB_COLUMNS WHERE  TABLE_NAME='CLUSTER_MESSAGE';
    IF numberOfRows = 0 THEN
        /**
         * Cluster messages used to synchronize deployment and configuration
         * changes across BPEL cluster nodes.
         */
        sqlStatement := 'create table cluster_message ( domain_id       varchar2( 50 )    not null, node_id         integer           not null, msg_type        integer           not null, msg_text        varchar2( 1000 ), msg_date        date              not null)'; 
        EXECUTE IMMEDIATE sqlStatement;
    END IF;

    SELECT COUNT(*) INTO numberOfRows FROM USER_TAB_COLUMNS WHERE  TABLE_NAME='CLUSTER_MASTER';
    IF numberOfRows = 0 THEN
        sqlStatement := 'create table cluster_master ( node_id         integer           not null, dummy_col       varchar2( 1 )     null)'; 
        EXECUTE IMMEDIATE sqlStatement;
 
        sqlStatement :=  'insert into cluster_master( node_id ) values( -1 )'; 
        EXECUTE IMMEDIATE sqlStatement;
    END IF;

    SELECT COUNT(*) INTO numberOfRows FROM USER_TAB_COLUMNS WHERE  TABLE_NAME='CLUSTER_NODE';
    IF numberOfRows = 0 THEN
        sqlStatement :=  'create table cluster_node ( node_id         integer           not null, ip_address      varchar2( 100 )   null, last_update     date              not null)'; 
        EXECUTE IMMEDIATE sqlStatement;
    END IF;

    SELECT COUNT(*) INTO numberOfRows FROM USER_TAB_COLUMNS WHERE  TABLE_NAME='DOMAIN' AND COLUMN_NAME='DELETED'; 
    IF numberOfRows = 0 THEN
        /**
         * Add deleted column to domain.  Needed for edge case where domain
         * is not present in the DB but found locally, but the domain really
         * has been removed from the cluster.
         */
        sqlStatement := 'alter table domain add ( deleted smallint default 0 not null)'; 
        EXECUTE IMMEDIATE sqlStatement;
    END IF;

    SELECT COUNT(*) INTO numberOfRows FROM USER_TAB_COLUMNS WHERE  TABLE_NAME='WFRULEDICTIONARYNOTM'; 
    IF numberOfRows = 0 THEN
        /*
         * Bug 8648362
         */
        sqlStatement := 'CREATE TABLE WFRuleDictionaryNOTM ( dictionaryName VARCHAR2(200), dictionaryVersion VARCHAR2(200), numberOfTimesModified NUMBER, primary key (dictionaryName, dictionaryVersion) )';
        EXECUTE IMMEDIATE sqlStatement;
    END IF;
END;
/

/**
 * Update the DB version tables
 */
UPDATE VERSION SET GUID = '10.1.3.5.0';
UPDATE VERSION_SERVER SET GUID = '10.1.3.5.0';
COMMIT;
