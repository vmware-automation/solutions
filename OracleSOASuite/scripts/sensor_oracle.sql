Rem
Rem $Header: sensor_oracle.sql 31-aug-2006.23:46:54 ralmuell Exp $
Rem
Rem sensor_oracle.sql
Rem
Rem Copyright (c) 2004, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sensor_oracle.sql - BPEL PM sensor schema
Rem
Rem    DESCRIPTION
Rem      Schema for BPEL PM reports.
Rem
Rem    NOTES
Rem      The schema will be populated by the BpelReportsSchema publisher.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ralmuell    08/31/06 - Fix for bug 5503162
Rem    ralmuell    04/25/06 - SLA added 
Rem    ralmuell    04/06/06 - Add SLA support 
Rem    ralmuell    02/01/06 - Adjust schema to Toplink publihser 
Rem    kmreddy     02/25/05 - modify triggers to check for null before
Rem                           populating PK column. necessary for jboss/
Rem                           weblogic compatibility
Rem    kmreddy     02/10/05 - re-compile collaxa objects after altering
Rem                           cube_instance bug 4176178
Rem    ralmuell    02/07/05 - Prepare for BETA3 schema
Rem    ralmuell    12/15/04 - Add CRITERIA_SATISFIED for all sensor values
Rem    ralmuell    11/15/04 - Fix for bug 3975514
Rem    ralmuell    10/20/04 - Adjust process instance view
Rem    ralmuell    10/11/04 - Create a generic sequence to workaround bug
Rem                           3938809
Rem    ralmuell    09/22/04 - Remove RAW
Rem    kmreddy     09/13/04 - modify bpel_process_slas table
Rem    kmreddy     09/02/04 - add pc_sensor_action_properties
Rem    ralmuell    08/31/04 - Adjust notification sensor values
Rem    ralmuell    08/30/04 - Add activity type for faults
Rem    ralmuell    08/25/04 - Create PC Reports package
Rem    ralmuell    08/23/04 - Adjust monitoring views
Rem    ralmuell    08/12/04 - Adjust attributes
Rem    ralmuell    08/11/04 - Add hourly analysis reports support
Rem    ralmuell    08/10/04 - Add more attributes
Rem    ralmuell    08/09/04 - Include domain in BpelProcesses
Rem    ralmuell    08/06/04 - Remove staging tables
Rem    ralmuell    08/05/04 - Define more views
Rem    ralmuell    08/04/04 - Add publisher_name to pc_probe
Rem    ralmuell    08/03/04 - Add data publisher table for Sensor Registry
Rem    ralmuell    08/02/04 - Add error table
Rem    kmreddy     07/31/04 - update ns sensor values table
Rem    ralmuell    07/29/04 - Add more attributes
Rem    ralmuell    07/28/04 - ralmuell_rt_0628
Rem    ralmuell    07/20/04 - Add additional tables
Rem    ralmuell    07/01/04 - Initial version of Reports schema
Rem    ralmuell    06/30/04 - Created
Rem


Rem
Rem Drop BPEL PM 10.1.2 leftovers
Rem 
drop table bpel_process_instances cascade constraints;

Rem
Rem Drop instance data first
Rem The instance data tables are populated during runtime with data from
Rem BPEL processes sensor values. This are the only tables supposed to grow
Rem during runtime.
Rem
drop table bpelpm_errors cascade constraints;
drop table fault_sensor_values cascade constraints;
drop table variable_sensor_values cascade constraints;
drop table activity_sensor_values cascade constraints;

drop table sensor_sequence;

Rem 
Rem Create Toplink sequence table
Rem
create table sensor_sequence (
  seq_name  varchar2(100),
  seq_count number
);
insert into sensor_sequence (seq_name, seq_count) values ('GLOBAL_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('BPELPM_ERRORS_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('ACTIVITY_SENSOR_VALUES_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('FAULT_SENSOR_VALUES_SEQ', 0);
insert into sensor_sequence (seq_name, seq_count) values ('VARIABLE_SENSOR_VALUES_SEQ', 0);


Rem
Rem Create Activity Sensor values table
Rem
create table activity_sensor_values (
  id                   number primary key,
  domain_ref           smallint,
  process_id           varchar2(100),
  revision_tag         varchar2(50),
  process_instance_id  number not null,
  sensor_name          nvarchar2(100),
  sensor_target        nvarchar2(256),
  action_name          nvarchar2(100),
  action_filter        nvarchar2(256),
  creation_date        timestamp not null,
  modify_date          timestamp,
  ts_hour              number,
  criteria_satisfied   varchar2(1), -- is null, 'Y', 'N'
  activity_name        nvarchar2(100),
  activity_type        varchar2(30),
  activity_state       varchar2(30),
  eval_point           varchar2(30),
  error_message        nvarchar2(2000),
  retry_count          number,
  eval_time            number -- eval time in msecs
);
create index activity_sensor_values_indx on activity_sensor_values(process_instance_id, sensor_name, action_name);

Rem
Rem Create Variable Sensor values table
Rem
create table variable_sensor_values (
  id                   number primary key,
  domain_ref           smallint,
  process_id           varchar2(100),
  revision_tag         varchar2(50),
  process_instance_id  number not null,
  sensor_name          nvarchar2(100),
  sensor_target        nvarchar2(256),
  action_name          nvarchar2(100),
  action_filter        nvarchar2(256),
  activity_sensor_id   number references activity_sensor_values(id),
  creation_date        timestamp not null,
  modify_date          timestamp,
  ts_hour              number,
  variable_name        nvarchar2(256),
  eval_point           varchar2(30),
  criteria_satisfied   varchar2(1), -- is null, 'Y', 'N'
  target               nvarchar2(256),
  schema_namespace     nvarchar2(256),
  schema_datatype      nvarchar2(256),
  updater_name         nvarchar2(100),
  updater_type         nvarchar2(100),
  value_type           smallint,
  varchar2_value       nvarchar2(2000),
  number_value         number,
  date_value           timestamp,
  date_value_tz        varchar2(10),
  blob_value           blob,
  clob_value           clob
);
create index variable_sensor_values_indx on variable_sensor_values(process_instance_id, sensor_name, action_name);

Rem
Rem Create Fault Sensor values table
Rem
create table fault_sensor_values (
  id                   number primary key,
  domain_ref           smallint,
  process_id           varchar2(100),
  revision_tag         varchar2(50),
  process_instance_id  number not null,
  sensor_name          nvarchar2(100),
  sensor_target        nvarchar2(256),
  action_name          nvarchar2(100),
  action_filter        nvarchar2(256),
  creation_date        timestamp not null,
  modify_date          timestamp,
  ts_hour              number,
  criteria_satisfied   varchar2(1), -- is null, 'Y', 'N'
  activity_name        nvarchar2(100),
  activity_type        varchar2(30),
  message              clob
);
create index fault_sensor_values_indx on fault_sensor_values(process_instance_id, sensor_name, action_name);

Rem
Rem Create the BPEL PM error table
Rem
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
  exception_name       nvarchar2(200),
  exception_desc       nvarchar2(2000),
  exception_fix        nvarchar2(2000),
  exception_context    varchar2(4000),
  component            number,
  thread_id            varchar2(200),
  stacktrace           clob
);


Rem
Rem Create public BPEL views
Rem

Rem
Rem Create view for process analysis reports
Rem
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
              (extract(day from (cxci.modify_date - cxci.creation_date)) * 24 * 60 * 60 +
               extract(hour from (cxci.modify_date - cxci.creation_date)) * 60 * 60 +
               extract(minute from (cxci.modify_date - cxci.creation_date)) * 60 +
               extract(second from (cxci.modify_date - cxci.creation_date))) * 1000
         else NULL
         end                    as eval_time,
       proc.sla_completion_time    as sla_completion_time,
       case
         when proc.sla_completion_time is NULL then NULL
         when (proc.sla_completion_time -
              ((extract(day from (cxci.modify_date - cxci.creation_date)) * 24 * 60 * 60 +
                extract(hour from (cxci.modify_date - cxci.creation_date)) * 60 * 60 +
                extract(minute from (cxci.modify_date - cxci.creation_date)) * 60 +
                extract(second from (cxci.modify_date - cxci.creation_date))) * 1000)) > 0 then 'Y'
         else 'N'
         end                    as sla_satisfied
  from domain cxdo,
       process proc,
       cube_instance cxci
 where cxci.domain_ref = cxdo.domain_ref
   and cxci.domain_ref = proc.domain_ref
   and cxci.process_id = proc.process_id
   and cxci.revision_tag = proc.revision_tag;


Rem
Rem Create view for Activity sensor values
Rem
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



Rem
Rem Create view for Variable sensor values
Rem
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


Rem
Rem Create view for Variable sensor values
Rem
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

Rem
Rem Create view for Fault sensor values
Rem
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

Rem
Rem Create view for errors
Rem
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



Rem
Rem Create package for BPEL Reports Infrastructure
Rem
create or replace package bpm_reports
as
  /**
   * @procedure BPM_REPORTS#logError
   * Log an error to a database table.
   * @param process_name IN VARCHAR2 The BPEL process name that caused the error (optional)
   * @param process_revision IN VARCHAR2 The BPEL process revision tag (optional)
   * @param domain_id IN VARCHAR2 The process manager domain (optional)
   * @param error_code IN NUMBER The error code number
   * @param exception_type IN NUMBER The type of the exception
   * @param exception_severity IN NUMBER The severity of the error
   * @param exception_name IN VARCHAR2 The name of the exception
   * @param exception_desc IN VARCHAR2 The description of the exception
   * @param exception_fix IN VARCHAR2 The suggested fix for the exception
   * @param exception_context IN VARCHAR2 The context of the exception
   * @param component IN NUMBER The component that caused the error
   * @param thread_id IN VARCHAR2 The thread id where the error occurred
   * @param stacktrace IN CLOB The Java stack trace of the exception
   */
  procedure logError(process_name IN VARCHAR2,
                     process_revision IN VARCHAR2,
                     domain_id IN VARCHAR2,
                     error_code IN NUMBER,
                     exception_type IN NUMBER,
                     exception_severity IN NUMBER,
                     exception_name IN VARCHAR2,
                     exception_desc IN VARCHAR2,
                     exception_fix IN VARCHAR2,
                     exception_context IN VARCHAR2,
                     component IN NUMBER,
                     thread_id IN VARCHAR2,
                     stacktrace IN CLOB);

  /**
   * @function BPM_REPORTS#computeWeek
   * Get the day of a date that appears in the same week as a given
   * date.
   * @param d IN DATE The start date
   * @param ed IN VARCHAR2 The end date as a string
   * @return DATE The week date
   */
  function computeWeek(d IN DATE, ed IN VARCHAR2) return date;
end bpm_reports;
/

Rem
Rem Create package body for BPM Reports Infrastructure
Rem
create or replace package body bpm_reports
as
  procedure logError(process_name IN VARCHAR2,
                     process_revision IN VARCHAR2,
                     domain_id IN VARCHAR2,
                     error_code IN NUMBER,
                     exception_type IN NUMBER,
                     exception_severity IN NUMBER,
                     exception_name IN VARCHAR2,
                     exception_desc IN VARCHAR2,
                     exception_fix IN VARCHAR2,
                     exception_context IN VARCHAR2,
                     component IN NUMBER,
                     thread_id IN VARCHAR2,
                     stacktrace IN CLOB)
  is
  PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    insert
      into bpelpm_errors(process_id, revision_tag, domain_id, creation_date, error_code,
                     exception_type, exception_severity, exception_name, exception_desc, exception_fix,
                     exception_context, component, thread_id, stacktrace)
    values (process_name, process_revision, domain_id, systimestamp, error_code,
            exception_type, exception_severity, exception_name, exception_desc, exception_fix,
            exception_context, component, thread_id, stacktrace);
    commit;
  exception
    when others then
      raise;
  end logError;

  function computeWeek(d IN DATE, ed IN VARCHAR2) return date is
  i integer := 0;
  wk integer := 0;
  res date := NULL;
  end_date date := NULL;
  begin
    end_date := TO_DATE(ed, 'MM/DD/YY');
    i := end_date - d ;
    wk := floor(i/7);
    if (wk > i) then
      wk := wk -1;
    end if;
    res := end_date - 7*wk;
    return res;
  end;

end bpm_reports;
/
