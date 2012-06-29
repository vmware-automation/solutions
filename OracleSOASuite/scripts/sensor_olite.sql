/**
 *  $Header: sensor_olite.sql 31-aug-2006.23:47:02 ralmuell Exp $
 *
 *  sensor_olite.sql
 *
 * Copyright (c) 2004, 2006, Oracle. All rights reserved.  
 *
 *     NAME
 *       sensor_olite.sql - BPEL PM reports schema for Oracle Lite
 *
 *     DESCRIPTION
 *       Installs the BPEL PM reports schema
 *
 *     NOTES
 *       N/A
 *
 *     MODIFIED   (MM/DD/YY)
 *     ralmuell    08/31/06 - Fix for bug 5503162
 *     pnandy      06/29/06 - revert the change for bug 5343923.
 *     vijagarw    06/27/06 -
 *     ralmuell    04/11/06 - Fix for bug 5143519 
 *     rarangas    04/10/06 - 
 *     ralmuell    04/06/06 - Add SLA support 
 *     ralmuell    02/01/06 - Adjust schema to Toplink publihser 
 *     pnandy      02/01/06 - comment out compute_week function for 10gR2 
 *                            Olite uptake. 
 *     kmreddy     02/10/05 - re-compile collaxa views after altering
 *                            cube_instance - bug 4176178
 *     ralmuell    02/07/05 - Prepare for BETA3 schema
 *     ralmuell    12/15/04 - Add CRITERIA_SATISFIED for all sensor values
 *     ralmuell    11/15/04 - Fix for bug 3975514
 *     adhulesh    11/06/04 - Adding computeWeek function
 *     ralmuell    10/28/04 - ralmuell_reports_olite
 *     ralmuell    10/27/04 - Modify SLA
 *     ralmuell    10/25/04 - Add activity_name for fault sensor values
 *     ralmuell    10/21/04 - Created
 */

/**
 * Drop BPEL PM 10.1.2 leftovers
 */
drop table bpel_process_instances cascade constraints;

/**
 * Drop instance data first
 * The instance data tables are populated during runtime with data from
 * BPEL processes sensor values. This are the only tables supposed to grow
 * during runtime.
 */
drop table bpelpm_errors cascade constraints;
drop table fault_sensor_values cascade constraints;
drop table variable_sensor_values cascade constraints;
drop table activity_sensor_values cascade constraints;

drop table sensor_sequence;

/**
 * Create Toplink sequence table
 */
create table sensor_sequence (
  seq_name  varchar2(100),
  seq_count number
);
insert into sensor_sequence (seq_name, seq_count) values ('GLOBAL_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('BPELPM_ERRORS_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('ACTIVITY_SENSOR_VALUES_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('FAULT_SENSOR_VALUES_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('VARIABLE_SENSOR_VALUES_SEQ', 0);


/**
 * Create Activity Sensor values table
 */
create table activity_sensor_values (
  id                   number primary key,
  domain_ref           smallint,
  process_id           varchar2(100),
  revision_tag         varchar2(50),
  process_instance_id  number not null,
  sensor_name          varchar2(100),
  sensor_target        varchar2(256),
  action_name          varchar2(100),
  action_filter        varchar2(256),
  creation_date        timestamp not null,
  modify_date          timestamp,
  ts_hour              number,
  criteria_satisfied   varchar2(1),
  activity_name        varchar2(100),
  activity_type        varchar2(30),
  activity_state       varchar2(30),
  eval_point           varchar2(30),
  error_message        varchar2(2000),
  retry_count          number,
  eval_time            number
);
create index activity_sensor_values_indx on activity_sensor_values(process_instance_id, sensor_name, action_name);

/**
 * Create Variable Sensor values table
 */
create table variable_sensor_values (
  id                   number primary key,
  domain_ref           smallint,
  process_id           varchar2(100),
  revision_tag         varchar2(50),
  process_instance_id  number not null,
  sensor_name          varchar2(100),
  sensor_target        varchar2(256),
  action_name          varchar2(100),
  action_filter        varchar2(256),
  activity_sensor_id   number references activity_sensor_values(id),
  creation_date        timestamp not null,
  modify_date          timestamp,
  ts_hour              number,
  variable_name        varchar2(256),
  eval_point           varchar2(30),
  criteria_satisfied   varchar2(1),
  target               varchar2(256),
  schema_namespace     varchar2(256),
  schema_datatype      varchar2(256),
  updater_name         varchar2(100),
  updater_type         varchar2(100),
  value_type           smallint,
  varchar2_value       varchar2(2000),
  number_value         number,
  date_value           timestamp,
  date_value_tz        varchar2(10),
  blob_value           blob,
  clob_value           clob
);
create index variable_sensor_values_indx on variable_sensor_values(process_instance_id, sensor_name, action_name);

/**
 * Create Fault Sensor values table
 */
create table fault_sensor_values (
  id                   number primary key,
  domain_ref           smallint,
  process_id           varchar2(100),
  revision_tag         varchar2(50),
  process_instance_id  number not null,
  sensor_name          varchar2(100),
  sensor_target        varchar2(256),
  action_name          varchar2(100),
  action_filter        varchar2(256),
  creation_date        timestamp not null,
  modify_date          timestamp,
  ts_hour              number,
  criteria_satisfied   varchar2(1),
  activity_name        varchar2(100),
  activity_type        varchar2(30),
  message              varchar2(4000)
);
create index fault_sensor_values_indx on fault_sensor_values(process_instance_id, sensor_name, action_name);


/**
 * Create the BPEL PM error table
 */
create table bpelpm_errors (
  id                   number primary key,
  domain_id            varchar2(50),
  process_id           varchar2(100),
  revision_tag         varchar2(50),
  creation_date        timestamp,
  ts_hour              number,
  error_code           number,
  exception_type       number,
  exception_severity   number,
  exception_name       varchar2(200),
  exception_desc       varchar2(2000),
  exception_fix        varchar2(2000),
  exception_context    varchar2(4000),
  component            number,
  thread_id            varchar2(200),
  stacktrace           varchar2(4000)
);


/*
 * Create public BPEL views
 */


/**
 * Create view for process analysis reports
 */
create or replace view BPEL_Process_Instances
as
select cxci.cikey               as instance_key,
       cxci.process_id          as bpel_process_name,
       cxci.revision_tag        as bpel_process_revision,
       cxdo.domain_id           as domain_id,
       cxci.title               as title,
       cxci.state               as state,
       case cxci.state
         when 0 then 'initiated'
         when 1 then 'open.running'
         when 2 then 'open.suspended'
         when 3 then 'open.faulted'
         when 4 then 'closed.pending_cancel'
         when 5 then 'closed.completed'
         when 6 then 'closed.faulted'
         when 7 then 'closed.cancelled'
         when 8 then 'closed.aborted'
         when 9 then 'closed.stale'
         else 'unknown'
       end                      as state_text,
       cxci.priority            as priority,
       cxci.status              as status,
       cxci.stage               as stage,
       cxci.conversation_id     as conversation_id,
       cxci.creation_date       as creation_date,
       cxci.modify_date         as modify_date,
       to_date(to_char(cxci.modify_date, 'MM/DD/YY'), 'MM/DD/YY') as ts_date,
       extract(hour from (cxci.modify_date))                      as ts_hour,
       case
         when cxci.modify_date is not null then 
           ((to_date(to_char(cxci.modify_date, 'MM/dd/yy HH24:mi'),'MM/dd/yy HH24:mi') - 
             to_date(to_char(cxci.creation_date, 'MM/dd/yy HH24:mi'),'MM/dd/yy HH24:mi'))*86400 +
             (to_number(substr(to_char(cxci.modify_date),instr(to_char(cxci.modify_date),' ')+7,6)) - 
             to_number(substr(to_char(cxci.creation_date),instr(to_char(cxci.creation_date),' ')+7,6))))*1000
         else NULL
       end                      as eval_time,
       proc.sla_completion_time    as sla_completion_time,
       case
         when proc.sla_completion_time is NULL then NULL
         when (proc.sla_completion_time -
               ((to_date(to_char(cxci.modify_date, 'MM/dd/yy HH24:mi'),'MM/dd/yy HH24:mi') - 
                 to_date(to_char(cxci.creation_date, 'MM/dd/yy HH24:mi'),'MM/dd/yy HH24:mi'))*86400 +
                (to_number(substr(to_char(cxci.modify_date),instr(to_char(cxci.modify_date),' ')+7,6)) - 
                 to_number(substr(to_char(cxci.creation_date),instr(to_char(cxci.creation_date),' ')+7,6))))*1000) > 0 then 'Y'
         else 'N'
         end                    as sla_satisfied
  from domain cxdo,
       process proc,
       cube_instance cxci
 where cxci.domain_ref = cxdo.domain_ref
   and cxci.domain_ref = proc.domain_ref
   and cxci.process_id = proc.process_id
   and cxci.revision_tag = proc.revision_tag;



/**
 * Create view for Activity sensor values
 */
create or replace view BPEL_Activity_Sensor_Values
as
select acts.id                  as id,
       acts.process_instance_id as instance_key,
       acts.process_id          as bpel_process_name,
       acts.revision_tag        as bpel_process_revision,
       cxdo.domain_id           as domain_id,
       acts.sensor_name         as sensor_name,
       acts.sensor_target       as sensor_target,
       acts.action_name         as action_name,
       acts.action_filter       as action_filter,
       acts.creation_date       as creation_date,
       acts.modify_date         as modify_date,
       to_date(to_char(acts.modify_date, 'MM/DD/YY'), 'MM/DD/YY') as ts_date,
       acts.ts_hour             as ts_hour,
       acts.criteria_satisfied  as criteria_satisfied,
       acts.activity_name       as activity_name,
       acts.activity_type       as activity_type,
       acts.activity_state      as activity_state,
       acts.eval_point          as eval_point,
       acts.error_message       as error_message,
       acts.retry_count         as retry_count,
       acts.eval_time           as eval_time
  from activity_sensor_values acts,
       domain cxdo
 where cxdo.domain_ref = acts.domain_ref;


/**
 * Create view for Variable sensor values
 */
create or replace view BPEL_Variable_Sensor_Values
as
select vars.id                  as id,
       vars.process_instance_id as instance_key,
       vars.process_id          as bpel_process_name,
       vars.revision_tag        as bpel_process_revision,
       cxdo.domain_id           as domain_id,
       vars.sensor_name         as sensor_name,
       vars.sensor_target       as sensor_target,
       vars.action_name         as action_name,
       vars.action_filter       as action_filter,
       vars.activity_sensor_id  as activity_sensor,
       vars.creation_date       as creation_date,
       to_date(to_char(vars.creation_date, 'MM/DD/YY'), 'MM/DD/YY') as ts_date,
       vars.ts_hour             as ts_hour,
       vars.variable_name       as variable_name,
       vars.eval_point          as eval_point,
       vars.criteria_satisfied  as criteria_satisfied,
       vars.target              as target,
       vars.updater_name        as updater_name,
       vars.updater_type        as updater_type,
       vars.schema_namespace    as schema_namespace,
       vars.schema_datatype     as schema_datatype,
       vars.value_type          as value_type,
       vars.varchar2_value      as varchar2_value,
       vars.number_value        as number_value,
       vars.date_value          as date_value,
       vars.date_value_tz       as date_value_tz,
       vars.blob_value          as blob_value,
       vars.clob_value          as clob_value
  from variable_sensor_values vars,
       domain cxdo
 where cxdo.domain_ref = vars.domain_ref;


/**
 * Create view for Variable analysis report
 */
create or replace view BPEL_Variable_Analysis_Report
as
select bpmv.id                     as id,
       bpmv.instance_key           as instance_key,
       bpmv.bpel_process_name      as bpel_process_name,
       bpmv.bpel_process_revision  as bpel_process_revision,
       bpmv.domain_id              as domain_id,
       bpmv.sensor_name            as sensor_name,
       bpmv.sensor_target          as sensor_target,
       bpmv.action_name            as action_name,
       bpmv.action_filter          as action_filter,
       bpmv.activity_sensor        as activity_sensor,
       bpmv.creation_date          as creation_date,
       bpmv.ts_date                as ts_date,
       bpmv.ts_hour                as ts_hour,
       bpmv.variable_name          as variable_name,
       bpmv.eval_point             as eval_point,
       bpmv.criteria_satisfied     as criteria_satisfied,
       bpmv.target                 as target,
       bpmv.updater_name           as updater_name,
       bpmv.updater_type           as updater_type,
       bpmv.schema_namespace       as schema_namespace,
       bpmv.schema_datatype        as schema_datatype,
       bpmv.value_type             as value_type,
       bpmv.varchar2_value         as varchar2_value,
       bpmv.number_value           as number_value,
       bpmv.date_value             as date_value,
       bpmv.date_value_tz          as date_value_tz,
       bpmv.blob_value             as blob_value,
       bpmv.clob_value             as clob_value
  from
       (select max(creation_date),
               max(id) id
          from BPEL_Variable_Sensor_Values
      group by variable_name, instance_key) bpmvmax,
       BPEL_Variable_Sensor_Values bpmv
 where bpmvmax.id = bpmv.id;

/**
 * Create view for Fault sensor values
 */
create or replace view BPEL_Fault_Sensor_Values
as
select fs.id                    as id,
       fs.process_instance_id   as instance_key,
       fs.process_id            as bpel_process_name,
       fs.revision_tag          as bpel_process_revision,
       cxdo.domain_id           as domain_id,
       fs.sensor_name           as sensor_name,
       fs.sensor_target         as sensor_target,
       fs.action_name           as action_name,
       fs.action_filter         as action_filter,
       fs.creation_date         as creation_date,
       fs.modify_date           as modify_date,
       to_date(to_char(fs.modify_date, 'MM/DD/YY'), 'MM/DD/YY') as ts_date,
       fs.ts_hour               as ts_hour,
       fs.criteria_satisfied    as criteria_satisfied,
       fs.activity_name         as activity_name,
       fs.activity_type         as activity_type,
       fs.message               as message
  from fault_sensor_values    fs,
       domain cxdo
 where cxdo.domain_ref = fs.domain_ref;

/**
 * Create view for errors
 */
create or replace view BPEL_Errors
as
select e.id                     as id,
       e.process_id             as bpel_process_name,
       e.revision_tag           as bpel_process_revision,
       e.domain_id              as domain_id,
       e.creation_date          as creation_date,
       to_date(to_char(e.creation_date, 'MM/DD/YY'), 'MM/DD/YY') as ts_date,
       e.ts_hour                as ts_hour,
       e.error_code             as error_code,
       case e.exception_type
         when 0 then 'Information'
         when 1 then 'Error'
         when 2 then 'System'
         when 3 then 'Warning'
         when 4 then 'Security'
         else 'Unknown'
       end                      as exception_type,
       e.exception_severity     as exception_severity,
       e.exception_name         as exception_name,
       e.exception_desc         as exception_description,
       e.exception_fix          as exception_fix,
       e.exception_context      as exception_context,
       case e.component
         when -1 then 'BPEL engine'
         when 0 then 'Component'
         when 1 then 'Infrastructure'
         when 2 then 'Services'
         when 3 then 'HumanWorkFLow'
         when 4 then 'Notification'
         when 5 then 'Reports'
         when 6 then 'OracleWorkFlow'
         when 7 then 'AdapterFramework'
         when 8 then 'Adapter'
         else 'unknown'
       end                      as component,
       e.thread_id              as thread_id,
       e.stacktrace             as stacktrace
  from bpelpm_errors e;



commit;
