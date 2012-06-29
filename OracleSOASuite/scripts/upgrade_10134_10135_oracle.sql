Rem Copyright (c) 2008, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     07/01/09 - Backport of ramisra_bug-8596431 (partitioning changes)
Rem    ramisra     05/11/09 - Backport ramisra_bug-8498498 from
Rem                           st_pcbpel_10.1.3.1
Rem    mchmiele    04/14/09 - Backport mchmiele_process_migration_10.1.3.5.0
Rem                           from st_pcbpel_10.1.3.1
Rem    mnanal      03/09/09 - Backport mnanal_bug-7286083 from
Rem                           st_pcbpel_10.1.3.1
Rem    mnanal      02/06/09 - Backport mnanal_bug-7022475 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     01/02/09 - Backport ramisra_bug-7577303 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     12/24/08 - Backport ramisra_bug-7656863 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     09/17/08 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100


/* fix for bug 6211557
 *
 */

DECLARE
 bCond     Number;
 sqlStatement     VARCHAR2(250);
BEGIN
  SELECT COUNT(*) INTO bCond FROM USER_TAB_COLUMNS WHERE  TABLE_NAME='ATTACHMENT' AND COLUMN_NAME='CONTENT_TYPE'; 
 
  IF bCond = 0 THEN
    sqlStatement := 'CREATE table temp_attachment ( key varchar2( 50 ), bin blob)';
    EXECUTE IMMEDIATE sqlStatement;
    sqlStatement := 'INSERT into temp_attachment (key,bin) SELECT key, bin FROM attachment';
    EXECUTE IMMEDIATE sqlStatement;
    sqlStatement := 'DROP table attachment';
    EXECUTE IMMEDIATE sqlStatement;
    sqlStatement := 'CREATE table attachment ( key varchar2( 50 ), content_type varchar2( 50 ), bin blob, constraint att_pk primary key( key ))';
    EXECUTE IMMEDIATE sqlStatement;
    sqlStatement := 'INSERT into attachment (key,bin) SELECT key, bin FROM temp_attachment';
    EXECUTE IMMEDIATE sqlStatement;
    sqlStatement := 'DROP table temp_attachment';
    EXECUTE IMMEDIATE sqlStatement;
  END IF;
END;
/ 

/**
* Add constraint in WFRoutingSlip table (Bug 6510734)
*/
DECLARE
 bCond     Number;
 sqlStatement     VARCHAR2(250);
BEGIN
  SELECT COUNT(*) INTO bCond FROM USER_CONSTRAINTS WHERE TABLE_NAME='WFROUTINGSLIP' AND CONSTRAINT_NAME='ROUTINGSLIPTASKCONSTRAINT';
 
  IF bCond = 0 THEN
    sqlStatement := 'DELETE FROM WFRoutingSlip rs WHERE NOT EXISTS (SELECT 1 FROM WFTask t WHERE t.taskid = rs.taskid)';
    EXECUTE IMMEDIATE sqlStatement;
    sqlStatement := 'ALTER TABLE WFRoutingSlip ADD CONSTRAINT RoutingSlipTaskConstraint FOREIGN KEY (taskId) REFERENCES WFTask (taskId) ON DELETE CASCADE';
    EXECUTE IMMEDIATE sqlStatement;
  END IF;
END;
/ 

/**
 * Bug 7321408
 */
DECLARE
 bCond     Number;
 sqlStatement     VARCHAR2(250);
BEGIN
  SELECT COUNT(*) INTO bCond FROM USER_TAB_COLUMNS WHERE  TABLE_NAME='PROCESS_DESCRIPTOR' AND COLUMN_NAME='LAST_CHANGE_TIME'; 
 
  IF bCond = 0 THEN
      sqlStatement := 'ALTER TABLE process_descriptor ADD (last_change_time NUMBER(38))';
      EXECUTE IMMEDIATE sqlStatement;
  END IF;
END;
/ 

UPDATE process_descriptor SET last_change_time=( SELECT days * (24*60*60*1000) + hours * (60*60*1000) - EXTRACT (timezone_hour FROM systimestamp) * (60*60*1000)  + minutes * (60*1000) - EXTRACT (timezone_minute FROM systimestamp) * (60*1000)  + seconds * 1000 + milliseconds FROM (SELECT TO_NUMBER(RTRIM(SUBSTR(diffTimeStamp, 2, INSTR(diffTimeStamp, ' ')-1))) days , TO_NUMBER(SUBSTR(diffTimeStamp, INSTR(diffTimeStamp, ' ')+1, 2)) hours, TO_NUMBER(SUBSTR(diffTimeStamp, instr(diffTimeStamp, ':')+1, 2)) minutes, TO_NUMBER(SUBSTR(diffTimeStamp, INSTR(diffTimeStamp, '.')-2, 2)) seconds, TO_NUMBER(RTRIM(SUBSTR(diffTimeStamp, INSTR(diffTimeStamp, '.')+1), 0)) milliseconds  FROM (SELECT ( SYSTIMESTAMP - TO_TIMESTAMP('01-JAN-1970','DD-MON-YYYY')) diffTimeStamp FROM DUAL)));

/**
 * package body collaxa
 *
 * PL/SQL package implementation for stored procedures used in collaxa system.
 */
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
                         r_retry_count out integer,
                         p_ci_partition_date in timestamp );

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
                                      r_success out integer,
                                      p_ci_partition_date in timestamp);

end collaxa;
/

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
                         r_retry_count out integer,
                         p_ci_partition_date in timestamp)
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

        if r_wi_exception.retry_count is not null
        then
            v_retry_count := r_wi_exception.retry_count + 1;
        end if;

        close c_wi_exception;

        insert into wi_exception( cikey, node_id, scope_id, count_id,
                                  domain_ref, retry_count, retry_date, ci_partition_date)
        values( p_cikey, p_node_id, p_scope_id, p_count_id,
                p_domain_ref, v_retry_count, p_retry_date, p_ci_partition_date);

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
                                      r_success out integer,
                                      p_ci_partition_date in timestamp)
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
             insert into document_ci_ref( cikey, domain_ref, dockey, ci_partition_date )
              values( p_cikey, p_domain_ref, p_dockey, p_ci_partition_date);
             r_success := 1;
         else
             r_success := 0;
         end if;
    end insert_document_ci_ref;
    
end collaxa;
/

alter package collaxa compile body;
/

/**
* Bug 6955137 
*/
DECLARE
 bCond1     Number;
 bCond2     Number;
 sqlStatement     VARCHAR2(250);
BEGIN
  SELECT COUNT(*) INTO bCond1 FROM USER_INDEXES WHERE TABLE_NAME='WFTASK' AND INDEX_NAME='WFTASKTASKGROUPID_I';
  SELECT COUNT(*) INTO bCond2 FROM USER_INDEXES WHERE TABLE_NAME='WFTASK' AND INDEX_NAME='WFTASKWORKFLOWPATTERN_I';
 
  IF bCond1 = 0 THEN
    sqlStatement := 'create index WFTaskTaskGroupId_I on WFTask(taskGroupId)';
    EXECUTE IMMEDIATE sqlStatement;
  END IF;

  IF bCond2 = 0 THEN
    sqlStatement := 'create index WFTaskWorkflowPattern_I on WFTask(workflowPattern)';
    EXECUTE IMMEDIATE sqlStatement;
  END IF;
END;
/ 

/**
 * Bug 7577303, remove old properties and replace it by new properties
 */

SET SERVEROUTPUT ON;
 DECLARE
  bCount1     number;
  bCount2     number;
  domainid     number;
  dspMaxThreads     number;
  dspInvokeAllocFactor     number;
  dspInvokeThreads     number;
  dspEngineThreads     number;
  propcomment     VARCHAR2(1000);
  CURSOR domainref_cur IS
    SELECT domain_ref FROM
        DOMAIN;
 BEGIN
   FOR domainref_r in domainref_cur
   LOOP
    DBMS_OUTPUT.PUT_LINE('Processing domain_ref ' || domainref_r.domain_ref);

    SELECT count(*) INTO bCount1 FROM domain_properties WHERE prop_id='dspMaxThreads' AND domain_ref=domainref_r.domain_ref;

    IF bCount1 > 0 THEN
	SELECT prop_value INTO dspMaxThreads FROM domain_properties WHERE prop_id='dspMaxThreads' AND domain_ref=domainref_r.domain_ref;
	DBMS_OUTPUT.PUT_LINE('The dspMaxThreads  is: ' || dspMaxThreads);

	SELECT count(*) INTO bCount2 FROM domain_properties WHERE prop_id='dspInvokeAllocFactor' AND domain_ref=domainref_r.domain_ref;

        IF bCount2 > 0 THEN
	    SELECT prop_value INTO dspInvokeAllocFactor FROM domain_properties WHERE prop_id='dspInvokeAllocFactor' AND domain_ref=domainref_r.domain_ref;
	    DBMS_OUTPUT.PUT_LINE('The dspInvokeAllocFactor is: ' || dspInvokeAllocFactor);

	    dspInvokeThreads := CEIL(dspMaxThreads *  dspInvokeAllocFactor);
	    DBMS_OUTPUT.PUT_LINE('The dspInvokeThreads is: ' || dspInvokeThreads);

	    dspEngineThreads := dspMaxThreads - dspInvokeThreads;
	    DBMS_OUTPUT.PUT_LINE('The dspEngineThreads is: ' || dspEngineThreads);
	  
	    propcomment := 'The total number of threads that will be allocated to process invocation dispatcher messages.  Invocation dispatch messages are generated for each payload that is received by the BPEL engine and meant to instantiate a new instance.  <p/> If the majority of requests processed by the engine are instance invocations (as opposed to instance callbacks), greater performance may be achieved by increasing the number of invocation threads.  Note that higher threads counts may cause greater cpu utilization due to higher context switching costs.  <p/> The default value is 20 threads.  Any value less than 1 thread will be changed to the default.';

           INSERT into domain_properties (DOMAIN_REF,PROP_ID,PROP_VALUE,PROP_NAME,PROP_COMMENT) values (domainref_r.domain_ref,'dspInvokeThreads',dspInvokeThreads,'Invoke thread pool size',propcomment);

	   propcomment := 'The total number of threads that will be allocated to process engine dispatcher messages.  Engine dispatch messages are generated whenever an activity must be processed asynchronously by the BPEL engine.  <p/> If the majority of processed deployed on the BPEL server are durable with a large number of dehydration points (mid-process receive, onMessage, onAlarm, wait), greater performance may be achieved by increasing the number of engine threads.  Note that higher threads counts may cause greater cpu utilization due to higher context switching costs.  <p/> The default value is 30 threads.  Any value less than 1 thread will be changed to the default. ';
	   
	   INSERT into domain_properties (DOMAIN_REF,PROP_ID,PROP_VALUE,PROP_NAME,PROP_COMMENT) values (domainref_r.domain_ref,'dspEngineThreads',dspEngineThreads,'Engine thread pool size',propcomment);

	   DELETE FROM domain_properties WHERE prop_id IN  ( 'dspMinThreads' , 'dspMaxThreads', 'dspInvokeAllocFactor' ); 
        END IF;
     END IF;
   END LOOP;
 END;
/

/**
 * For bug 7154301
 */
ALTER TABLE dlv_subscription ADD ( partner_link VARCHAR2(256) );

UPDATE VERSION SET guid = '10.1.3.5.0';

/* Fix for bug #7116677 */
alter table WFTaskTimer add key varchar(100);

/* 
 * Bug 7286083 
 */
alter table WFAttachment modify encoding varchar(100);

/** Bug 8429746 */

drop table cx_resource;

/**
 * A resource table is used to access hierarchically organized data. 
 * This primary reason is to allow configuration items that are domain wide to be stored
 * int the db and accessible by any node. The API that handles them is com.oracle.resource.* 
 * Only leaf nodes that are of type "f" (file) will have cx_content table entry.  
 */

create table cx_resource 
(
    id    integer,
    pid   integer,
   name   varchar(64),
   kind   char(1),
   modify_date timestamp default sysdate,
   constraint cx_resource_pk primary key( id ),
   constraint cx_resource_no_dups_pk unique (pid,name)
);

create index cx_resource_name_idx on cx_resource (name); 
create index cx_resource_pid_idx on cx_resource (pid);

/** Here is the 2nd one, call it "cx_content"*/

drop table cx_content;
create table cx_content 
(
	id       integer,       /* id of the resource content, pointing to Resource.id */
	content  blob,             /* the content as a blob */
    constraint cx_content_pk primary key( id )
) 
storage
(
    freelists 6
)
lob( content )
store as
(
    storage( initial 4k next 4k )
    chunk 2k
    cache
    pctversion 0
)
pctfree 0
pctused 1;

-- Add debugger tables
--
@@debugger_oracle.ddl

/*
 * Bug 8596431
 * Add partitioning key columns in tables
 */
ALTER TABLE work_item ADD (ci_partition_date TIMESTAMP);
ALTER TABLE dlv_subscription  ADD (ci_partition_date TIMESTAMP);
ALTER TABLE ci_indexes ADD (ci_partition_date TIMESTAMP);
ALTER TABLE wi_exception ADD (ci_partition_date TIMESTAMP);
ALTER TABLE wi_fault ADD (ci_partition_date TIMESTAMP);
ALTER TABLE document_ci_ref ADD (ci_partition_date TIMESTAMP);
ALTER TABLE audit_trail ADD (ci_partition_date TIMESTAMP);
ALTER TABLE audit_details ADD (ci_partition_date TIMESTAMP);
ALTER TABLE cube_scope ADD (ci_partition_date TIMESTAMP);
ALTER TABLE attachment ADD (ci_partition_date TIMESTAMP);
ALTER TABLE attachment_ref ADD (ci_partition_date TIMESTAMP);

ALTER TABLE document_dlv_msg_ref ADD (dlv_partition_date TIMESTAMP);

ALTER TABLE xml_document ADD (doc_partition_date TIMESTAMP);


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
 * Add deleted column to domain.  Needed for edge case where domain
 * is not present in the DB but found locally, but the domain really
 * has been removed from the cluster.
 */
alter table domain add
(
    deleted smallint default 0 not null
);

/**
 * Update the DB version tables
 */
update version set guid = '10.1.3.5.0';
update version_server set guid = '10.1.3.5.0';
commit;

