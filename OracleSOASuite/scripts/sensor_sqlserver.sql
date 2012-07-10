/**
 *  $Header: /vob0/vobs/bpel/everest/src/modules/server/database/scripts/sensor_sqlserver.sql,v 1.4 2005/09/29 10:13:40 ralmuell Exp $
 * 
 *  sensor_sqlserver.sql
 * 
 *  Copyright (c) 2004, 2005, Oracle. All rights reserved.
 * 
 *     NAME
 *       sensor_sqlserver.sql - BPEL PM Reports schema
 * 
 *     DESCRIPTION
 *       MS SQL Server schema for BPEL PM reports.
 * 
 *     NOTES
 *       The schema is the source of ADF entity and view objects
 *       exposed in the BPEL PM Sensor Agency and Sensor Registry
 * 
 *     MODIFIED   (MM/DD/YY)
 *     ralmuell    08/22/05 - Created
 */

/**
 * Drop BPEL sensor public views
 */
if exists ( select name from sysobjects
            where name = 'bpel_all_processes' and type = 'V' )
begin
    drop view bpel_all_processes
    print "Dropping view bpel_all_processes"
end
if exists ( select name from sysobjects
            where name = 'bpel_sensor_process_instances' and type = 'V' )
begin
    drop view bpel_sensor_process_instances
    print "Dropping view bpel_sensor_process_instances"
end
if exists ( select name from sysobjects
            where name = 'bpel_process_analysis_report' and type = 'V' )
begin
    drop view bpel_process_analysis_report
    print "Dropping view bpel_process_analysis_report"
end
if exists ( select name from sysobjects
            where name = 'bpel_activity_sensor_values' and type = 'V' )
begin
    drop view bpel_activity_sensor_values
    print "Dropping view bpel_activity_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'bpel_variable_sensor_values' and type = 'V' )
begin
    drop view bpel_variable_sensor_values
    print "Dropping view bpel_variable_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'bpel_variable_analysis_report' and type = 'V' )
begin
    drop view bpel_variable_analysis_report
    print "Dropping view bpel_variable_analysis_report"
end
if exists ( select name from sysobjects
            where name = 'bpel_fault_sensor_values' and type = 'V' )
begin
    drop view bpel_fault_sensor_values
    print "Dropping view bpel_fault_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'bpel_errors' and type = 'V' )
begin
    drop view bpel_errors
    print "Dropping view bpel_errors"
end
if exists ( select name from sysobjects
            where name = 'bpel_notif_sensor_values' and type = 'V' )
begin
    drop view bpel_notif_sensor_values
    print "Dropping view bpel_notif_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'bpel_adapter_sensor_values' and type = 'V' )
begin
    drop view bpel_adapter_sensor_values
    print "Dropping view bpel_adapter_sensor_values"
end

/**
 * Drop BPEL sensor public views
 */
if exists ( select name from sysobjects
            where name = 'pc_data_publishers' and type = 'U' )
begin
    drop table pc_data_publishers
    print "Dropping table pc_data_publishers"
end
if exists ( select name from sysobjects
            where name = 'pc_errors' and type = 'U' )
begin
    drop table pc_errors
    print "Dropping table pc_errors"
end
if exists ( select name from sysobjects
            where name = 'pc_notification_sensor_values' and type = 'U' )
begin
    drop table pc_notification_sensor_values
    print "Dropping table pc_notification_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'pc_adapter_sensor_values' and type = 'U' )
begin
    drop table pc_adapter_sensor_values
    print "Dropping table pc_adapter_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'pc_fault_sensor_values' and type = 'U' )
begin
    drop table pc_fault_sensor_values
    print "Dropping table pc_fault_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'pc_variable_sensor_values' and type = 'U' )
begin
    drop table pc_variable_sensor_values
    print "Dropping table pc_variable_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'pc_activity_sensor_values' and type = 'U' )
begin
    drop table pc_activity_sensor_values
    print "Dropping table pc_activity_sensor_values"
end
if exists ( select name from sysobjects
            where name = 'bpel_process_instances' and type = 'U' )
begin
    drop table bpel_process_instances
    print "Dropping table bpel_process_instances"
end
if exists ( select name from sysobjects
            where name = 'bpel_process_slas' and type = 'U' )
begin
    drop table bpel_process_slas
    print "Dropping table bpel_process_slas"
end
if exists ( select name from sysobjects
            where name = 'pc_sensor_action_properties' and type = 'U' )
begin
    drop table pc_sensor_action_properties
    print "Dropping table pc_sensor_action_properties"
end
if exists ( select name from sysobjects
            where name = 'pc_probes_sensors' and type = 'U' )
begin
    drop table pc_probes_sensors
    print "Dropping table pc_probes_sensors"
end
if exists ( select name from sysobjects
            where name = 'pc_probes' and type = 'U' )
begin
    drop table pc_probes
    print "Dropping table pc_probes"
end
if exists ( select name from sysobjects
            where name = 'pc_sensor_configurations' and type = 'U' )
begin
    drop table pc_sensor_configurations
    print "Dropping table pc_sensor_configurations"
end
if exists ( select name from sysobjects
            where name = 'pc_sensors' and type = 'U' )
begin
    drop table pc_sensors
    print "Dropping table pc_sensors"
end
if exists ( select name from sysobjects
            where name = 'bpel_processes' and type = 'U' )
begin
    drop table bpel_processes
    print "Dropping table bpel_processes"
end
if exists ( select name from sysobjects
            where name = 'sensor_sequence' and type = 'U' )
begin
    drop table sensor_sequence
    print "Dropping table sensor_sequence"
end


/**
 * Create tables
 */

/**
 * Create sequence table
 */
create table sensor_sequence (
  seq_name  varchar(100),
  seq_count integer
)
print "Creating table sensor_sequence"
go
print "Insert into sensor_sequence"
insert into sensor_sequence values ('SENSOR_SEQ', 1)
go

/** 
 * Create BPEL process table.
 * The BPEL process table stores design time data of a BPEL
 * process. This is for easy traversal of the BPEL process
 * structure from Reporting clients
 */ 
create table bpel_processes (
  id                   integer primary key,
  name                 nvarchar(100) not null,
  version              varchar(50) not null,
  cx_domain_ref        smallint, 
  cx_domain_id         varchar(50),
  base_url             nvarchar(256) null,
  sensor_url           nvarchar(256) null,
  sensor_action_url    nvarchar(256) null
)
print "Creating table bpel_processes"
go

create unique index bpel_processes_indx on bpel_processes(name, version, cx_domain_id)
go

/**
 * Create BPEL process SLA table.
 */ 
create table bpel_process_slas (
  id                   integer primary key,
  bpel_process_id      integer not null references bpel_processes(id),
  sla_type             nvarchar(256) null,
  value                nvarchar(256) null
)
print "Creating table bpel_process_slas"
go

create unique index bpel_process_slas_indx on bpel_process_slas(bpel_process_id)
go

/**
 * Create BPEL process instance table.
 */ 
create table bpel_process_instances (
  id                   integer primary key,
  bpel_process_id      integer not null references bpel_processes(id),
  cx_cikey             integer, 
  creation_date        datetime not null,
  modify_date          datetime null,
  ts_hour              integer null,
  eval_time            integer null, 
  sla_satisfied        varchar(1) null
)
print "Creating table bpel_process_instances"
go

create index bpel_process_instances_indx1 on bpel_process_instances(bpel_process_id)
go

create index bpel_process_instances_indx2 on bpel_process_instances(cx_cikey)
go

/**
 * Create PC Sensors table.
 */
create table pc_sensors (
  id                   integer primary key,
  bpel_process_id      integer not null references bpel_processes(id),
  name                 nvarchar(100) not null,
  kind                 nvarchar(16) not null check (kind in ('activity', 'fault', 'variable',
                                                              'notification', 'adapter')),
  classname            nvarchar(256) not null,
  target               varchar(256) null
)
print "Creating table pc_sensors"
go

create unique index pc_sensors_indx on pc_sensors(bpel_process_id, name)
go

/**
 * Create PC Sensor configurations table.
 */
create table pc_sensor_configurations (
  id                   integer primary key,
  sensor_id            integer not null references pc_sensors(id),
  var_output_dty       nvarchar(100) null,
  var_output_ns        nvarchar(256) null,
  var_query_name       nvarchar(100) null,
  act_eval_time        varchar(30) null,
  adp_header_variable  nvarchar(256) null,
  adp_operation        nvarchar(256) null,
  adp_partner_link     nvarchar(256) null,
  adp_port_type        nvarchar(256) null,
  ns_input_variable    nvarchar(256) null,
  ns_output_variable   nvarchar(256) null,
  ns_operation         nvarchar(256) null
)
print "Creating table pc_sensor_configurations"
go

/**
 * Create PC Sensor Actions table.
 */
create table pc_probes (
  id                   integer primary key,
  bpel_process_id      integer not null references bpel_processes(id),
  name                 nvarchar(100) not null,
  is_enabled           varchar(1) default 'N',
  filter               nvarchar(256) null,
  publish_name         nvarchar(100) null,
  publish_type         varchar(30) null,
  publish_target       varchar(100) null
)
print "Creating table pc_probes"
go

create unique index pc_sensoractions_indx on pc_probes(bpel_process_id, name)
go

/**
 * Create PC Sensor Actions table.
 */
create table pc_sensor_action_properties (
  id                   integer primary key,
  action_id            integer not null references pc_probes(id),
  name                 nvarchar(100) not null,
  value                nvarchar(100) null
)
print "Creating table pc_sensor_action_properties"
go

create unique index pc_sensoractionproperties_indx on pc_sensor_action_properties(action_id, name)
go

/**
 * Create intersection table for PC Sensors & Probes
 */
create table pc_probes_sensors (
  probe_id             integer not null references pc_probes(id),
  sensor_id            integer not null references pc_sensors(id),
  constraint pc_probes_sensors_c1 primary key(probe_id, sensor_id)
)
print "Creating table pc_probes_sensors"
go

/**
 * Create table for data publishers
 */
create table pc_data_publishers (
  id                   integer primary key,
  name                 nvarchar(100) null,
  type                 varchar(30) null,
  description          nvarchar(2000) null,
  creation_date        datetime null,
  modify_date          datetime null,
  classname            varchar(200) null
)
print "Creating table pc_data_publishers"
go

create unique index pc_data_publishers_indx on pc_data_publishers(name, type)
go

/**
 * Create PC Activity Sensor values table
 */
create table pc_activity_sensor_values (
  id                   integer primary key,
  process_instance_id  integer not null references bpel_process_instances(id),
  sensor_name          nvarchar(100),
  sensor_target        nvarchar(256),
  action_name          nvarchar(100),
  action_filter        nvarchar(256) null,
  creation_date        datetime not null,
  modify_date          datetime null,
  ts_hour              integer,
  criteria_satisfied   varchar(1) null, 
  activity_name        nvarchar(100),
  activity_type        varchar(30),
  activity_state       varchar(30) null,
  eval_point           varchar(30),
  error_message        nvarchar(2000) null,
  retry_count          integer null,
  eval_time            integer null 
)
print "Creating table pc_activity_sensor_values"
go

create index pc_activity_sensor_values_indx on pc_activity_sensor_values(process_instance_id, sensor_name, action_name)
go

/**
 * Create PC Variable Sensor values table
 */
create table pc_variable_sensor_values (
  id                   integer primary key,
  process_instance_id  integer not null references bpel_process_instances(id),
  sensor_name          nvarchar(100),
  sensor_target        nvarchar(256),
  action_name          nvarchar(100),
  action_filter        nvarchar(256) null,
  activity_sensor_id   integer null references pc_activity_sensor_values(id),
  creation_date        datetime not null,
  modify_date          datetime null,
  ts_hour              integer,
  variable_name        nvarchar(256),
  criteria_satisfied   varchar(1) null,
  target               nvarchar(256),
  updater_name         nvarchar(100),
  updater_type         nvarchar(100),
  value_type           smallint,
  varchar2_value       nvarchar(2000) null,
  number_value         decimal null,
  date_value           datetime null,
  date_value_tz        varchar(10) null,
  blob_value           image null,
  clob_value           ntext null
)
print "Creating table pc_variable_sensor_values"
go

create index pc_variable_sensor_values_indx on pc_variable_sensor_values(process_instance_id, sensor_name, action_name)
go

/**
 * Create PC Fault Sensor values table
 */
create table pc_fault_sensor_values (
  id                   integer primary key,
  process_instance_id  integer not null references bpel_process_instances(id),
  sensor_name          nvarchar(100),
  sensor_target        nvarchar(256),
  action_name          nvarchar(100),
  action_filter        nvarchar(256) null,
  creation_date        datetime not null,
  modify_date          datetime null,
  ts_hour              integer,
  criteria_satisfied   varchar(1) null,
  activity_name        nvarchar(100),
  activity_type        varchar(30),
  message              ntext null
)
print "Creating table pc_fault_sensor_values"
go

create index pc_fault_sensor_values_indx on pc_fault_sensor_values(process_instance_id, sensor_name, action_name)
go

/**
 * Create the adapter sensor values table
 */
create table pc_adapter_sensor_values (
  id                   integer primary key,
  process_instance_id  integer not null references bpel_process_instances(id),
  activity_sensor_id   integer not null references pc_activity_sensor_values(id),
  endpoint             varchar(200) not null,
  adapter_type         varchar(30) not null check(adapter_type in ('file', 'AQ')),
  priority             integer null,
  msg_size             integer null,
  direction            varchar(10) not null check(direction in ('inbound', 'outbound'))
)
print "Creating table pc_adapter_sensor_values"
go

create index pc_adapter_sensor_values_indx on pc_adapter_sensor_values(activity_sensor_id, process_instance_id)
go

/**
 * Create Notification sensor values table
 */
create table pc_notification_sensor_values (
  id                   integer primary key,
  process_instance_id  integer not null references bpel_process_instances(id),
  activity_sensor_id   integer not null references pc_activity_sensor_values(id),
  message_id           nvarchar(2000) null,
  mime_type            varchar(30) null,
  from_address         varchar(200) null,
  to_address           varchar(200) null,
  notification_type    varchar(30) not null check
                                      (notification_type in ('email', 'fax', 'IM',
                                                             'SMS', 'voice', 'pager',
                                                             'user', 'group'))
)
print "Creating table pc_notification_sensor_values"
go

create index pc_ns_sensor_values_indx on pc_notification_sensor_values( activity_sensor_id, process_instance_id)
go

/**
 * Create the ProcessConnect error table
 */
create table pc_errors (
  id                   integer primary key,
  process_name         nvarchar(100) null,
  process_revision     varchar(50) null,
  cx_domain_id         varchar(50) null,
  creation_date        datetime null,
  ts_hour              integer null,
  error_code           integer null,
  exception_type       integer null,
  exception_severity   integer null,
  exception_name       nvarchar(200) null,
  exception_desc       nvarchar(2000) null,
  exception_fix        nvarchar(2000) null,
  exception_context    varchar(4000) null,
  component            integer null,
  thread_id            varchar(200) null,
  stacktrace           text null
)
print "Creating table pc_errors"
go

/**
 * Create views
 */

/**
 * Create view for BPEL design time data
 */
create view bpel_all_processes
as
select pcbp.name               as name,
       pcbp.version            as revision,
       cxdo.domain_id          as domain_id,
       pcbp.base_url           as base_url,
       pcbp.sensor_url         as sensor_url,
       pcbp.sensor_action_url  as sensor_action_url
  from bpel_processes pcbp,
       domain cxdo
 where pcbp.cx_domain_ref = cxdo.domain_ref
go
print "Creating view bpel_all_processes"
go

/**
 * Create view for BPEL process instances
 */
create view bpel_sensor_process_instances
as
select pcbpi.id                 as id,
       cxci.cikey               as instance_key,
       pcbp.name                as bpel_process_name,
       pcbp.version             as bpel_process_revision,
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
       pcbpi.creation_date      as creation_date,
       pcbpi.modify_date        as modify_date,
       cast(pcbpi.modify_date as smalldatetime) as ts_date,
       pcbpi.ts_hour            as ts_hour,
       pcbpi.eval_time          as eval_time,
       cast(pcbpsla.value as decimal) as sla_completion_time,
       case
         when pcbpsla.value is NULL then NULL
         when (cast(pcbpsla.value as decimal) -
              ((datepart(day, (cxci.modify_date - cxci.creation_date)) * 24 * 60 * 60 +
                datepart(hour, (cxci.modify_date - cxci.creation_date)) * 60 * 60 +
                datepart(minute, (cxci.modify_date - cxci.creation_date)) * 60 +
                datepart(second, (cxci.modify_date - cxci.creation_date))) * 1000)) > 0 then 'Y'
         else 'N'
         end                    as sla_satisfied
  from bpel_processes pcbp
       left outer join bpel_process_slas pcbpsla
    on pcbp.id = pcbpsla.bpel_process_id
   and 'SLACompletionTime' = pcbpsla.sla_type
       inner join bpel_process_instances pcbpi
    on pcbp.id = pcbpi.bpel_process_id
       left outer join cube_instance cxci
    on pcbpi.cx_cikey=cxci.cikey
       inner join domain cxdo
    on pcbp.cx_domain_ref = cxdo.domain_ref
go
print "Creating view bpel_sensor_process_instances"
go

/**
 * Create view for process analysis reports
 */ 
create view bpel_process_analysis_report
as
select cxci.cikey               as id,
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
       cast(cxci.modify_date as smalldatetime) as ts_date,
       datepart(hour, (cxci.modify_date))   as ts_hour,
       case
         when cxci.modify_date is not null then
              (datepart(day, (cxci.modify_date - cxci.creation_date)) * 24 * 60 * 60 +
               datepart(hour, (cxci.modify_date - cxci.creation_date)) * 60 * 60 +
               datepart(minute, (cxci.modify_date - cxci.creation_date)) * 60 +
               datepart(second, (cxci.modify_date - cxci.creation_date))) * 1000
         else NULL
         end                    as eval_time,
       cast(pcbpsla.value as decimal) as sla_completion_time,
       case
         when pcbpsla.value is NULL then NULL
         when (cast(pcbpsla.value as decimal) -
              ((datepart(day, (cxci.modify_date - cxci.creation_date)) * 24 * 60 * 60 +
                datepart(hour, (cxci.modify_date - cxci.creation_date)) * 60 * 60 +
                datepart(minute, (cxci.modify_date - cxci.creation_date)) * 60 +
                datepart(second, (cxci.modify_date - cxci.creation_date))) * 1000)) > 0 then 'Y'
         else 'N'
         end                    as sla_satisfied
  from bpel_processes pcbp
       left outer join bpel_process_slas pcbpsla
    on pcbp.id = pcbpsla.bpel_process_id
   and 'SLACompletionTime' = pcbpsla.sla_type
       right outer join cube_instance sensorci
    on sensorci.domain_ref = pcbp.cx_domain_ref
   and sensorci.process_id = pcbp.name
   and sensorci.revision_tag = pcbp.version
       inner join cube_instance cxci
    on cxci.cikey = sensorci.cikey
       inner join domain cxdo
    on cxci.domain_ref = cxdo.domain_ref
go
print "Creating view bpel_process_analysis_report"
go

/**
 * Create view for Activity sensor values
 */
create view bpel_activity_sensor_values
as
select pcas.id                  as id,
       pcas.process_instance_id as process_instance,
       pcbpi.cx_cikey           as instance_key,
       pcbp.name                as bpel_process_name,
       pcbp.version             as bpel_process_revision,
       pcbp.cx_domain_id        as domain_id,
       pcas.sensor_name         as sensor_name,
       pcas.sensor_target       as sensor_target,
       pcas.action_name         as action_name,
       pcas.action_filter       as action_filter,
       pcas.creation_date       as creation_date,
       pcas.modify_date         as modify_date,
       cast(pcas.modify_date as smalldatetime) as ts_date,
       pcas.ts_hour             as ts_hour,
       pcas.criteria_satisfied  as criteria_satisfied,
       pcas.activity_name       as activity_name,
       pcas.activity_type       as activity_type,
       pcas.activity_state      as activity_state,
       pcas.eval_point          as eval_point,
       pcas.error_message       as error_message,
       pcas.retry_count         as retry_count,
       pcas.eval_time           as eval_time
  from pc_activity_sensor_values pcas,
       bpel_process_instances    pcbpi,
       bpel_processes            pcbp
 where pcbpi.bpel_process_id    = pcbp.id
   and pcas.process_instance_id = pcbpi.id
go
print "Creating view bpel_activity_sensor_values"
go

/**
 * Create view for Variable sensor values
 */
create view bpel_variable_sensor_values
as
select pcvs.id                  as id,
       pcvs.process_instance_id as process_instance,
       pcbpi.cx_cikey           as instance_key,
       pcbp.name                as bpel_process_name,
       pcbp.version             as bpel_process_revision,
       pcbp.cx_domain_id        as domain_id,
       pcvs.sensor_name         as sensor_name,
       pcvs.sensor_target       as sensor_target,
       pcvs.action_name         as action_name,
       pcvs.action_filter       as action_filter,
       pcvs.activity_sensor_id  as activity_sensor,
       pcvs.creation_date       as creation_date,
       cast(pcvs.creation_date as smalldatetime) as ts_date,
       pcvs.ts_hour             as ts_hour,
       pcvs.variable_name       as variable_name,
       pcvs.criteria_satisfied  as criteria_satisfied,
       pcvs.target              as target,
       pcvs.updater_name        as updater_name,
       pcvs.updater_type        as updater_type,
       pcvs.value_type          as value_type,
       pcvs.varchar2_value      as varchar2_value,
       pcvs.number_value        as number_value,
       pcvs.date_value          as date_value,
       pcvs.date_value_tz       as date_value_tz,
       pcvs.blob_value          as blob_value,
       pcvs.clob_value          as clob_value
  from pc_variable_sensor_values pcvs,
       bpel_process_instances    pcbpi,
       bpel_processes            pcbp
 where pcbpi.bpel_process_id    = pcbp.id
   and pcvs.process_instance_id = pcbpi.id
go
print "Creating view bpel_variable_sensor_values"
go

/**
 * Create view for Variable sensor values
 */
create view bpel_variable_analysis_report
as
select bpmv.id                     as id,
       bpmv.process_instance       as process_instance,
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
       bpmv.criteria_satisfied     as criteria_satisfied,
       bpmv.target                 as target,
       bpmv.updater_name           as updater_name,
       bpmv.updater_type           as updater_type,
       bpmv.value_type             as value_type,
       bpmv.varchar2_value         as varchar2_value,
       bpmv.number_value           as number_value,
       bpmv.date_value             as date_value,
       bpmv.date_value_tz          as date_value_tz,
       bpmv.blob_value             as blob_value,
       bpmv.clob_value             as clob_value
  from
       (select max(creation_date) cd,
               max(id) id
          from BPEL_Variable_Sensor_Values
      group by variable_name, process_instance) bpmvmax,
       BPEL_Variable_Sensor_Values bpmv
 where bpmvmax.id = bpmv.id
go
print "Creating view bpel_variable_analysis_report"
go


/**
 * Create view for Fault sensor values
 */
create view bpel_fault_sensor_values
as
select pcfs.id                  as id,
       pcfs.process_instance_id as process_instance,
       pcbpi.cx_cikey           as instance_key,
       pcbp.name                as bpel_process_name,
       pcbp.version             as bpel_process_revision,
       pcbp.cx_domain_id        as domain_id,
       pcfs.sensor_name         as sensor_name,
       pcfs.sensor_target       as sensor_target,
       pcfs.action_name         as action_name,
       pcfs.action_filter       as action_filter,
       pcfs.creation_date       as creation_date,
       pcfs.modify_date         as modify_date,
       cast(pcfs.modify_date as smalldatetime) as ts_date,
       pcfs.ts_hour             as ts_hour,
       pcfs.criteria_satisfied  as criteria_satisfied,
       pcfs.activity_name       as activity_name,
       pcfs.activity_type       as activity_type,
       pcfs.message             as message
  from pc_fault_sensor_values    pcfs,
       bpel_process_instances    pcbpi,
       bpel_processes            pcbp
 where pcbpi.bpel_process_id    = pcbp.id
   and pcfs.process_instance_id = pcbpi.id
go
print "Creating view bpel_fault_sensor_values"
go


/**
 * Create view for errors
 */
create view bpel_errors
as
select pce.id                   as id,
       pce.process_name         as bpel_process_name,
       pce.process_revision     as bpel_process_revision,
       pce.cx_domain_id         as domain_id,
       pce.creation_date        as creation_date,
       cast(pce.creation_date as smalldatetime) as ts_date,
       pce.ts_hour              as ts_hour,
       pce.error_code           as error_code,
       case pce.exception_type
         when 0 then 'Information'
         when 1 then 'Error'
         when 2 then 'System'
         when 3 then 'Warning'
         when 4 then 'Security'
         else 'Unknown'
       end                      as exception_type,
       pce.exception_severity   as exception_severity,
       pce.exception_name       as exception_name,
       pce.exception_desc       as exception_description,
       pce.exception_fix        as exception_fix,
       pce.exception_context    as exception_context,
       case pce.component
         when -1 then 'BPEL engine'
         when 0 then 'PCComponent'
         when 1 then 'PC-Infrastructure'
         when 2 then 'PC-Services'
         when 3 then 'PC-HumanWorkFLow'
         when 4 then 'PC-Notification'
         when 5 then 'PC-Reports'
         when 6 then 'PC-OracleWorkFlow'
         when 7 then 'PC-AdapterFramework'
         when 8 then 'PC-Adapter'
         else 'unknown'
       end                      as component,
       pce.thread_id            as thread_id,
       pce.stacktrace           as stacktrace
  from pc_errors pce
go
print "Creating view bpel_errors"
go

/**
 * Create view for Notification sensor values
 */
create view bpel_notif_sensor_values
as
select pcns.id                  as id,
       pcns.process_instance_id as process_instance,
       pcbpi.cx_cikey           as instance_key,
       pcns.activity_sensor_id  as activity_sensor,
       pcbp.name                as bpel_process_name,
       pcbp.version             as bpel_process_revision,
       pcbp.cx_domain_id        as domain_id,
       pcas.sensor_name         as sensor_name,
       pcas.sensor_target       as sensor_target,
       pcas.action_name         as action_name,
       pcas.action_filter       as action_filter,
       pcas.creation_date       as creation_date,
       pcas.modify_date         as modify_date,
       cast(pcas.modify_date as smalldatetime) as ts_date,
       pcas.ts_hour             as ts_hour,
       pcas.criteria_satisfied  as criteria_satisfied,
       pcas.eval_time           as eval_time,
       pcas.eval_point          as eval_point,
       pcas.error_message       as error_message,
       pcns.message_id          as message_id,
       pcns.mime_type           as mime_type,
       pcns.from_address        as from_address,
       pcns.to_address          as to_address,
       pcns.notification_type   as notification_type
  from pc_notification_sensor_values pcns,
       pc_activity_sensor_values     pcas,
       bpel_process_instances        pcbpi,
       bpel_processes                pcbp
 where pcbpi.bpel_process_id    = pcbp.id
   and pcas.process_instance_id = pcbpi.id
   and pcns.activity_sensor_id  = pcas.id
   and pcns.process_instance_id = pcas.process_instance_id
go
print "Creating view bpel_notif_sensor_values"
go

/**
 * Create view for Adapter sensor values
 */
create view bpel_adapter_sensor_values
as
select pcadps.id                as id,
       pcas.process_instance_id as process_instance,
       pcbpi.cx_cikey           as instance_key,
       pcadps.activity_sensor_id as activity_sensor,
       pcbp.name                as bpel_process_name,
       pcbp.version             as bpel_process_revision,
       pcbp.cx_domain_id        as domain_id,
       pcas.sensor_name         as sensor_name,
       pcas.sensor_target       as sensor_target,
       pcas.action_name         as action_name,
       pcas.action_filter       as action_filter,
       pcas.creation_date       as creation_date,
       pcas.modify_date         as modify_date,
       cast(pcas.modify_date as smalldatetime) as ts_date,
       pcas.ts_hour             as ts_hour,
       pcas.criteria_satisfied  as criteria_satisfied,
       pcas.eval_time           as eval_time,
       pcas.eval_point          as eval_point,
       pcas.error_message       as error_message,
       pcadps.endpoint          as endpoint,
       pcadps.adapter_type      as adapter_type,
       pcadps.priority          as priority,
       pcadps.msg_size          as msg_size,
       pcadps.direction         as direction
  from pc_adapter_sensor_values  pcadps,
       pc_activity_sensor_values pcas,
       bpel_process_instances    pcbpi,
       bpel_processes            pcbp
 where pcbpi.bpel_process_id      = pcbp.id
   and pcas.process_instance_id   = pcbpi.id
   and pcadps.activity_sensor_id  = pcas.id
   and pcadps.process_instance_id = pcas.process_instance_id
go
print "Creating view bpel_adapter_sensor_values"
go



