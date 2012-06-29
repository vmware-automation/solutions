/**
 *  $Header: /vob0/vobs/bpel/everest/src/modules/server/database/scripts/sensor_sybase.sql,v 1.4 2005/09/29 10:13:48 ralmuell Exp $
 * 
 *  sensor_sybase.sql
 * 
 *  Copyright (c) 2004, 2005, Oracle. All rights reserved.
 * 
 *     NAME
 *       sensor_sybase.sql - BPEL PM Reports schema
 * 
 *     DESCRIPTION
 *       Sybase schema for BPEL PM reports.
 * 
 *     NOTES
 *       The schema is the source of ADF entity and view objects
 *       exposed in the BPEL PM Sensor Agency and Sensor Registry
 * 
 *     MODIFIED   (MM/DD/YY)
 *     ralmuell    08/29/05 - Created
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
go
if exists ( select name from sysobjects
            where name = 'bpel_sensor_process_instances' and type = 'V' )
begin
    drop view bpel_sensor_process_instances
    print "Dropping view bpel_sensor_process_instances"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_process_analysis_report' and type = 'V' )
begin
    drop view bpel_process_analysis_report
    print "Dropping view bpel_process_analysis_report"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_activity_sensor_values' and type = 'V' )
begin
    drop view bpel_activity_sensor_values
    print "Dropping view bpel_activity_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_variable_sensor_values' and type = 'V' )
begin
    drop view bpel_variable_sensor_values
    print "Dropping view bpel_variable_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_variable_analysis_report' and type = 'V' )
begin
    drop view bpel_variable_analysis_report
    print "Dropping view bpel_variable_analysis_report"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_fault_sensor_values' and type = 'V' )
begin
    drop view bpel_fault_sensor_values
    print "Dropping view bpel_fault_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_errors' and type = 'V' )
begin
    drop view bpel_errors
    print "Dropping view bpel_errors"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_notif_sensor_values' and type = 'V' )
begin
    drop view bpel_notif_sensor_values
    print "Dropping view bpel_notif_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'bpel_adapter_sensor_values' and type = 'V' )
begin
    drop view bpel_adapter_sensor_values
    print "Dropping view bpel_adapter_sensor_values"
end
go

/**
 * Drop BPEL sensor public views
 */
if exists ( select name from sysobjects
            where name = 'PC_DATA_PUBLISHERS' and type = 'U' )
begin
    drop table PC_DATA_PUBLISHERS
    print "Dropping table pc_data_publishers"
end
go
if exists ( select name from sysobjects
            where name = 'PC_ERRORS' and type = 'U' )
begin
    drop table PC_ERRORS
    print "Dropping table pc_errors"
end
go
if exists ( select name from sysobjects
            where name = 'PC_NOTIFICATION_SENSOR_VALUES' and type = 'U' )
begin
    drop table PC_NOTIFICATION_SENSOR_VALUES
    print "Dropping table pc_notification_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'PC_ADAPTER_SENSOR_VALUES' and type = 'U' )
begin
    drop table PC_ADAPTER_SENSOR_VALUES
    print "Dropping table pc_adapter_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'PC_FAULT_SENSOR_VALUES' and type = 'U' )
begin
    drop table PC_FAULT_SENSOR_VALUES
    print "Dropping table pc_fault_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'PC_VARIABLE_SENSOR_VALUES' and type = 'U' )
begin
    drop table PC_VARIABLE_SENSOR_VALUES
    print "Dropping table pc_variable_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'PC_ACTIVITY_SENSOR_VALUES' and type = 'U' )
begin
    drop table PC_ACTIVITY_SENSOR_VALUES
    print "Dropping table pc_activity_sensor_values"
end
go
if exists ( select name from sysobjects
            where name = 'BPEL_PROCESS_INSTANCES' and type = 'U' )
begin
    drop table BPEL_PROCESS_INSTANCES
    print "Dropping table bpel_process_instances"
end
go
if exists ( select name from sysobjects
            where name = 'BPEL_PROCESS_SLAS' and type = 'U' )
begin
    drop table BPEL_PROCESS_SLAS
    print "Dropping table bpel_process_slas"
end
go
if exists ( select name from sysobjects
            where name = 'PC_SENSOR_ACTION_PROPERTIES' and type = 'U' )
begin
    drop table PC_SENSOR_ACTION_PROPERTIES
    print "Dropping table pc_sensor_action_properties"
end
go
if exists ( select name from sysobjects
            where name = 'PC_PROBES_SENSORS' and type = 'U' )
begin
    drop table PC_PROBES_SENSORS
    print "Dropping table pc_probes_sensors"
end
go
if exists ( select name from sysobjects
            where name = 'PC_PROBES' and type = 'U' )
begin
    drop table PC_PROBES
    print "Dropping table pc_probes"
end
go
if exists ( select name from sysobjects
            where name = 'PC_SENSOR_CONFIGURATIONS' and type = 'U' )
begin
    drop table PC_SENSOR_CONFIGURATIONS
    print "Dropping table pc_sensor_configurations"
end
go
if exists ( select name from sysobjects
            where name = 'PC_SENSORS' and type = 'U' )
begin
    drop table PC_SENSORS
    print "Dropping table pc_sensors"
end
go
if exists ( select name from sysobjects
            where name = 'BPEL_PROCESSES' and type = 'U' )
begin
    drop table BPEL_PROCESSES
    print "Dropping table bpel_processes"
end
go
if exists ( select name from sysobjects
            where name = 'SENSOR_SEQUENCE' and type = 'U' )
begin
    drop table SENSOR_SEQUENCE
    print "Dropping table sensor_sequence"
end
go


/**
 * Create tables
 */

/**
 * Create sequence table
 */
create table SENSOR_SEQUENCE (
  SEQ_NAME  VARCHAR(100),
  SEQ_COUNT INTEGER
)
lock datarows
print "Creating table sensor_sequence"
go
print "Insert into sensor_sequence"
insert into SENSOR_SEQUENCE values ('SENSOR_SEQ', 1)
go

/** 
 * Create BPEL process table.
 * The BPEL process table stores design time data of a BPEL
 * process. This is for easy traversal of the BPEL process
 * structure from Reporting clients
 */ 
create table BPEL_PROCESSES (
  ID                   INTEGER PRIMARY KEY,
  NAME                 NVARCHAR(100) NOT NULL,
  VERSION              VARCHAR(50) NOT NULL,
  CX_DOMAIN_REF        SMALLINT, 
  CX_DOMAIN_ID         VARCHAR(50),
  BASE_URL             NVARCHAR(256) NULL,
  SENSOR_URL           NVARCHAR(256) NULL,
  SENSOR_ACTION_URL    NVARCHAR(256) NULL
)
lock datarows
print "Creating table bpel_processes"
go

create unique index bpel_processes_indx on BPEL_PROCESSES(NAME, VERSION, CX_DOMAIN_ID)
go

/**
 * Create BPEL process SLA table.
 */ 
CREATE TABLE BPEL_PROCESS_SLAS (
  ID                   INTEGER PRIMARY KEY,
  BPEL_PROCESS_ID      INTEGER NOT NULL REFERENCES BPEL_PROCESSES(ID),
  SLA_TYPE             NVARCHAR(256) NULL,
  VALUE                NVARCHAR(256) NULL
)
lock datarows
print "Creating table bpel_process_slas"
go

create unique index bpel_process_slas_indx on BPEL_PROCESS_SLAS(BPEL_PROCESS_ID)
go

/**
 * Create BPEL process instance table.
 */ 
CREATE TABLE BPEL_PROCESS_INSTANCES (
  ID                   INTEGER PRIMARY KEY,
  BPEL_PROCESS_ID      INTEGER NOT NULL REFERENCES BPEL_PROCESSES(ID),
  CX_CIKEY             INTEGER, 
  CREATION_DATE        DATETIME NOT NULL,
  MODIFY_DATE          DATETIME NULL,
  TS_HOUR              INTEGER NULL,
  EVAL_TIME            INTEGER NULL, 
  SLA_SATISFIED        VARCHAR(1) NULL
)
lock datarows
print "Creating table bpel_process_instances"
go

create index bpel_process_instances_indx1 on BPEL_PROCESS_INSTANCES(BPEL_PROCESS_ID)
go

create index bpel_process_instances_indx2 on BPEL_PROCESS_INSTANCES(CX_CIKEY)
go

/**
 * Create PC Sensors table.
 */
create table PC_SENSORS (
  ID                   INTEGER PRIMARY KEY,
  BPEL_PROCESS_ID      INTEGER NOT NULL REFERENCES BPEL_PROCESSES(ID),
  NAME                 NVARCHAR(100) NOT NULL,
  KIND                 NVARCHAR(16) NOT NULL CHECK (KIND IN ('activity', 'fault', 'variable',
                                                              'notification', 'adapter')),
  CLASSNAME            NVARCHAR(256) NOT NULL,
  TARGET               VARCHAR(256) NULL
)
lock datarows
print "Creating table pc_sensors"
go

create unique index pc_sensors_indx on PC_SENSORS(BPEL_PROCESS_ID, NAME)
go

/**
 * Create PC Sensor configurations table.
 */
create table PC_SENSOR_CONFIGURATIONS (
  ID                   INTEGER PRIMARY KEY,
  SENSOR_ID            INTEGER NOT NULL REFERENCES PC_SENSORS(ID),
  VAR_OUTPUT_DTY       NVARCHAR(100) NULL,
  VAR_OUTPUT_NS        NVARCHAR(256) NULL,
  VAR_QUERY_NAME       NVARCHAR(100) NULL,
  ACT_EVAL_TIME        VARCHAR(30) NULL,
  ADP_HEADER_VARIABLE  NVARCHAR(256) NULL,
  ADP_OPERATION        NVARCHAR(256) NULL,
  ADP_PARTNER_LINK     NVARCHAR(256) NULL,
  ADP_PORT_TYPE        NVARCHAR(256) NULL,
  NS_INPUT_VARIABLE    NVARCHAR(256) NULL,
  NS_OUTPUT_VARIABLE   NVARCHAR(256) NULL,
  NS_OPERATION         NVARCHAR(256) NULL
)
lock datarows
print "Creating table pc_sensor_configurations"
go

/**
 * Create PC Sensor Actions table.
 */
create table PC_PROBES (
  ID                   INTEGER PRIMARY KEY,
  BPEL_PROCESS_ID      INTEGER NOT NULL REFERENCES BPEL_PROCESSES(ID),
  NAME                 NVARCHAR(100) NOT NULL,
  IS_ENABLED           VARCHAR(1) DEFAULT 'N',
  FILTER               NVARCHAR(256) NULL,
  PUBLISH_NAME         NVARCHAR(100) NULL,
  PUBLISH_TYPE         VARCHAR(30) NULL,
  PUBLISH_TARGET       VARCHAR(100) NULL
)
lock datarows
print "Creating table pc_probes"
go

create unique index pc_sensoractions_indx on PC_PROBES(BPEL_PROCESS_ID, NAME)
go

/**
 * Create PC Sensor Actions table.
 */
create table PC_SENSOR_ACTION_PROPERTIES (
  ID                   INTEGER PRIMARY KEY,
  ACTION_ID            INTEGER NOT NULL REFERENCES PC_PROBES(ID),
  NAME                 NVARCHAR(100) NOT NULL,
  VALUE                NVARCHAR(100) NULL
)
lock datarows
print "Creating table pc_sensor_action_properties"
go

create unique index pc_sensoractionproperties_indx on PC_SENSOR_ACTION_PROPERTIES(ACTION_ID, NAME)
go

/**
 * Create intersection table for PC Sensors & Probes
 */
create table PC_PROBES_SENSORS (
  PROBE_ID             INTEGER NOT NULL REFERENCES PC_PROBES(ID),
  SENSOR_ID            INTEGER NOT NULL REFERENCES PC_SENSORS(ID),
  CONSTRAINT PC_PROBES_SENSORS_C1 PRIMARY KEY(PROBE_ID, SENSOR_ID)
)
lock datarows
print "Creating table pc_probes_sensors"
go

/**
 * Create table for data publishers
 */
create table PC_DATA_PUBLISHERS (
  ID                   INTEGER PRIMARY KEY,
  NAME                 NVARCHAR(100) NULL,
  TYPE                 VARCHAR(30) NULL,
  DESCRIPTION          NVARCHAR(2000) NULL,
  CREATION_DATE        DATETIME NULL,
  MODIFY_DATE          DATETIME NULL,
  CLASSNAME            VARCHAR(200) NULL
)
lock datarows
print "Creating table pc_data_publishers"
go

create unique index pc_data_publishers_indx on PC_DATA_PUBLISHERS(NAME, TYPE)
go

/**
 * Create PC Activity Sensor values table
 */
create table PC_ACTIVITY_SENSOR_VALUES (
  ID                   INTEGER PRIMARY KEY,
  PROCESS_INSTANCE_ID  INTEGER NOT NULL REFERENCES BPEL_PROCESS_INSTANCES(ID),
  SENSOR_NAME          NVARCHAR(100),
  SENSOR_TARGET        NVARCHAR(256),
  ACTION_NAME          NVARCHAR(100),
  ACTION_FILTER        NVARCHAR(256) NULL,
  CREATION_DATE        DATETIME NOT NULL,
  MODIFY_DATE          DATETIME NULL,
  TS_HOUR              INTEGER,
  CRITERIA_SATISFIED   VARCHAR(1) NULL, 
  ACTIVITY_NAME        NVARCHAR(100),
  ACTIVITY_TYPE        VARCHAR(30),
  ACTIVITY_STATE       VARCHAR(30) NULL,
  EVAL_POINT           VARCHAR(30) NULL,
  ERROR_MESSAGE        NVARCHAR(2000) NULL,
  RETRY_COUNT          INTEGER NULL,
  EVAL_TIME            INTEGER  NULL
)
lock datarows
print "Creating table pc_activity_sensor_values"
go

create index pc_activity_sensor_values_indx on PC_ACTIVITY_SENSOR_VALUES(PROCESS_INSTANCE_ID, SENSOR_NAME, ACTION_NAME)
go

/**
 * Create PC Variable Sensor values table
 */
create table PC_VARIABLE_SENSOR_VALUES (
  ID                   INTEGER PRIMARY KEY,
  PROCESS_INSTANCE_ID  INTEGER NOT NULL REFERENCES BPEL_PROCESS_INSTANCES(ID),
  SENSOR_NAME          NVARCHAR(100),
  SENSOR_TARGET        NVARCHAR(256),
  ACTION_NAME          NVARCHAR(100),
  ACTION_FILTER        NVARCHAR(256) NULL,
  ACTIVITY_SENSOR_ID   INTEGER NULL REFERENCES PC_ACTIVITY_SENSOR_VALUES(ID) NULL,
  CREATION_DATE        DATETIME NOT NULL,
  MODIFY_DATE          DATETIME NULL,
  TS_HOUR              INTEGER,
  VARIABLE_NAME        NVARCHAR(256),
  CRITERIA_SATISFIED   VARCHAR(1) NULL,
  TARGET               NVARCHAR(256),
  UPDATER_NAME         NVARCHAR(100),
  UPDATER_TYPE         NVARCHAR(100),
  VALUE_TYPE           SMALLINT,
  VARCHAR2_VALUE       NVARCHAR(2000) NULL,
  NUMBER_VALUE         DECIMAL NULL,
  DATE_VALUE           DATETIME NULL,
  DATE_VALUE_TZ        VARCHAR(10) NULL,
  BLOB_VALUE           IMAGE NULL,
  CLOB_VALUE           TEXT NULL
)
lock datarows
print "Creating table pc_variable_sensor_values"
go

create index pc_variable_sensor_values_indx on PC_VARIABLE_SENSOR_VALUES(PROCESS_INSTANCE_ID, SENSOR_NAME, ACTION_NAME)
go

/**
 * Create PC Fault Sensor values table
 */
create table PC_FAULT_SENSOR_VALUES (
  ID                   INTEGER PRIMARY KEY,
  PROCESS_INSTANCE_ID  INTEGER NOT NULL REFERENCES BPEL_PROCESS_INSTANCES(ID),
  SENSOR_NAME          NVARCHAR(100),
  SENSOR_TARGET        NVARCHAR(256),
  ACTION_NAME          NVARCHAR(100),
  ACTION_FILTER        NVARCHAR(256) NULL,
  CREATION_DATE        DATETIME NOT NULL,
  MODIFY_DATE          DATETIME NULL,
  TS_HOUR              INTEGER,
  CRITERIA_SATISFIED   VARCHAR(1) NULL,
  ACTIVITY_NAME        NVARCHAR(100),
  ACTIVITY_TYPE        VARCHAR(30),
  MESSAGE              TEXT NULL
)
lock datarows
print "Creating table pc_fault_sensor_values"
go

create index pc_fault_sensor_values_indx on PC_FAULT_SENSOR_VALUES(PROCESS_INSTANCE_ID, SENSOR_NAME, ACTION_NAME)
go

/**
 * Create the adapter sensor values table
 */
create table PC_ADAPTER_SENSOR_VALUES (
  ID                   INTEGER PRIMARY KEY,
  PROCESS_INSTANCE_ID  INTEGER NOT NULL REFERENCES BPEL_PROCESS_INSTANCES(ID),
  ACTIVITY_SENSOR_ID   INTEGER NOT NULL REFERENCES PC_ACTIVITY_SENSOR_VALUES(ID),
  ENDPOINT             VARCHAR(200) NOT NULL,
  ADAPTER_TYPE         VARCHAR(30) NOT NULL CHECK(ADAPTER_TYPE IN ('file', 'AQ')),
  PRIORITY             INTEGER NULL,
  MSG_SIZE             INTEGER NULL,
  DIRECTION            VARCHAR(10) NOT NULL CHECK(DIRECTION IN ('Inbound', 'Outbound'))
)
lock datarows
print "Creating table pc_adapter_sensor_values"
go

create index pc_adapter_sensor_values_indx on PC_ADAPTER_SENSOR_VALUES(ACTIVITY_SENSOR_ID, PROCESS_INSTANCE_ID)
go

/**
 * Create Notification sensor values table
 */
create table PC_NOTIFICATION_SENSOR_VALUES (
  ID                   INTEGER PRIMARY KEY,
  PROCESS_INSTANCE_ID  INTEGER NOT NULL REFERENCES BPEL_PROCESS_INSTANCES(ID),
  ACTIVITY_SENSOR_ID   INTEGER NOT NULL REFERENCES PC_ACTIVITY_SENSOR_VALUES(ID),
  MESSAGE_ID           NVARCHAR(2000) NULL,
  MIME_TYPE            VARCHAR(30) NULL,
  FROM_ADDRESS         VARCHAR(200) NULL,
  TO_ADDRESS           VARCHAR(200) NULL,
  NOTIFICATION_TYPE    VARCHAR(30) NOT NULL CHECK
                                      (NOTIFICATION_TYPE in ('email', 'fax', 'IM',
                                                             'SMS', 'voice', 'pager',
                                                             'user', 'group'))
)
lock datarows
print "Creating table pc_notification_sensor_values"
go

create index pc_ns_sensor_values_indx on PC_NOTIFICATION_SENSOR_VALUES( ACTIVITY_SENSOR_ID, PROCESS_INSTANCE_ID)
go

/**
 * Create the ProcessConnect error table
 */
create table PC_ERRORS (
  ID                   INTEGER PRIMARY KEY,
  PROCESS_NAME         NVARCHAR(100) NULL,
  PROCESS_REVISION     VARCHAR(50) NULL,
  CX_DOMAIN_ID         VARCHAR(50) NULL,
  CREATION_DATE        DATETIME NULL,
  TS_HOUR              INTEGER NULL,
  ERROR_CODE           INTEGER NULL,
  EXCEPTION_TYPE       INTEGER NULL,
  EXCEPTION_SEVERITY   INTEGER NULL,
  EXCEPTION_NAME       NVARCHAR(200) NULL,
  EXCEPTION_DESC       NVARCHAR(2000) NULL,
  EXCEPTION_FIX        NVARCHAR(2000) NULL,
  EXCEPTION_CONTEXT    VARCHAR(4000) NULL,
  COMPONENT            INTEGER NULL,
  THREAD_ID            VARCHAR(200) NULL,
  STACKTRACE           TEXT NULL
)
lock datarows
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
select pcbp.NAME               as name,
       pcbp.VERSION            as revision,
       cxdo.domain_id          as domain_id,
       pcbp.BASE_URL           as base_url,
       pcbp.SENSOR_URL         as sensor_url,
       pcbp.SENSOR_ACTION_URL  as sensor_action_url
  from BPEL_PROCESSES pcbp,
       domain cxdo
 where pcbp.CX_DOMAIN_REF = cxdo.domain_ref
go
print "Creating view bpel_all_processes"
go

/**
 * Create view for BPEL process instances
 */
create view bpel_sensor_process_instances
as
select pcbpi.ID                 as id,
       cxci.cikey               as instance_key,
       pcbp.NAME                as bpel_process_name,
       pcbp.VERSION             as bpel_process_revision,
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
       pcbpi.CREATION_DATE      as creation_date,
       pcbpi.MODIFY_DATE        as modify_date,
       cast(pcbpi.MODIFY_DATE as smalldatetime) as ts_date,
       pcbpi.TS_HOUR            as ts_hour,
       pcbpi.EVAL_TIME          as eval_time,
       cast(pcbpsla.VALUE as decimal) as sla_completion_time,
       case
         when pcbpsla.VALUE is NULL then NULL
         when (cast(pcbpsla.VALUE as decimal) -
              ((datepart(day, (cxci.modify_date - cxci.creation_date)) * 24 * 60 * 60 +
                datepart(hour, (cxci.modify_date - cxci.creation_date)) * 60 * 60 +
                datepart(minute, (cxci.modify_date - cxci.creation_date)) * 60 +
                datepart(second, (cxci.modify_date - cxci.creation_date))) * 1000)) > 0 then 'Y'
         else 'N'
         end                    as sla_satisfied
  from BPEL_PROCESSES pcbp
       left outer join BPEL_PROCESS_SLAS pcbpsla
    on pcbp.ID = pcbpsla.BPEL_PROCESS_ID
   and 'SLACompletionTime' = pcbpsla.SLA_TYPE
       inner join BPEL_PROCESS_INSTANCES pcbpi
    on pcbp.ID = pcbpi.BPEL_PROCESS_ID
       left outer join cube_instance cxci
    on pcbpi.CX_CIKEY=cxci.cikey
       inner join domain cxdo
    on pcbp.CX_DOMAIN_REF = cxdo.domain_ref
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
       cast(pcbpsla.VALUE as decimal) as sla_completion_time,
       case
         when pcbpsla.VALUE is NULL then NULL
         when (cast(pcbpsla.VALUE as decimal) -
              ((datepart(day, (cxci.modify_date - cxci.creation_date)) * 24 * 60 * 60 +
                datepart(hour, (cxci.modify_date - cxci.creation_date)) * 60 * 60 +
                datepart(minute, (cxci.modify_date - cxci.creation_date)) * 60 +
                datepart(second, (cxci.modify_date - cxci.creation_date))) * 1000)) > 0 then 'Y'
         else 'N'
         end                    as sla_satisfied
  from BPEL_PROCESSES pcbp
       left outer join BPEL_PROCESS_SLAS pcbpsla
    on pcbp.ID = pcbpsla.BPEL_PROCESS_ID
   and 'SLACompletionTime' = pcbpsla.SLA_TYPE
       right outer join cube_instance sensorci
    on sensorci.domain_ref = pcbp.CX_DOMAIN_REF
   and sensorci.process_id = pcbp.NAME
   and sensorci.revision_tag = pcbp.VERSION
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
select pcas.ID                  as id,
       pcas.PROCESS_INSTANCE_ID as process_instance,
       pcbpi.CX_CIKEY           as instance_key,
       pcbp.NAME                as bpel_process_name,
       pcbp.VERSION             as bpel_process_revision,
       pcbp.CX_DOMAIN_ID        as domain_id,
       pcas.SENSOR_NAME         as sensor_name,
       pcas.SENSOR_TARGET       as sensor_target,
       pcas.ACTION_NAME         as action_name,
       pcas.ACTION_FILTER       as action_filter,
       pcas.CREATION_DATE       as creation_date,
       pcas.MODIFY_DATE         as modify_date,
       cast(pcas.MODIFY_DATE as smalldatetime) as ts_date,
       pcas.TS_HOUR             as ts_hour,
       pcas.CRITERIA_SATISFIED  as criteria_satisfied,
       pcas.ACTIVITY_NAME       as activity_name,
       pcas.ACTIVITY_TYPE       as activity_type,
       pcas.ACTIVITY_STATE      as activity_state,
       pcas.EVAL_POINT          as eval_point,
       pcas.ERROR_MESSAGE       as error_message,
       pcas.RETRY_COUNT         as retry_count,
       pcas.EVAL_TIME           as eval_time
  from PC_ACTIVITY_SENSOR_VALUES pcas,
       BPEL_PROCESS_INSTANCES    pcbpi,
       BPEL_PROCESSES            pcbp
 where pcbpi.BPEL_PROCESS_ID    = pcbp.ID
   and pcas.PROCESS_INSTANCE_ID = pcbpi.ID
go
print "Creating view bpel_activity_sensor_values"
go

/**
 * Create view for Variable sensor values
 */
create view bpel_variable_sensor_values
as
select pcvs.ID                  as id,
       pcvs.PROCESS_INSTANCE_ID as process_instance,
       pcbpi.CX_CIKEY           as instance_key,
       pcbp.NAME                as bpel_process_name,
       pcbp.VERSION             as bpel_process_revision,
       pcbp.CX_DOMAIN_ID        as domain_id,
       pcvs.SENSOR_NAME         as sensor_name,
       pcvs.SENSOR_TARGET       as sensor_target,
       pcvs.ACTION_NAME         as action_name,
       pcvs.ACTION_FILTER       as action_filter,
       pcvs.ACTIVITY_SENSOR_ID  as activity_sensor,
       pcvs.CREATION_DATE       as creation_date,
       cast(pcvs.CREATION_DATE as smalldatetime) as ts_date,
       pcvs.TS_HOUR             as ts_hour,
       pcvs.VARIABLE_NAME       as variable_name,
       pcvs.CRITERIA_SATISFIED  as criteria_satisfied,
       pcvs.TARGET              as target,
       pcvs.UPDATER_NAME        as updater_name,
       pcvs.UPDATER_TYPE        as updater_type,
       pcvs.VALUE_TYPE          as value_type,
       pcvs.VARCHAR2_VALUE      as varchar2_value,
       pcvs.NUMBER_VALUE        as number_value,
       pcvs.DATE_VALUE          as date_value,
       pcvs.DATE_VALUE_TZ       as date_value_tz,
       pcvs.BLOB_VALUE          as blob_value,
       pcvs.CLOB_VALUE          as clob_value
  from PC_VARIABLE_SENSOR_VALUES pcvs,
       BPEL_PROCESS_INSTANCES    pcbpi,
       BPEL_PROCESSES            pcbp
 where pcbpi.BPEL_PROCESS_ID    = pcbp.ID
   and pcvs.PROCESS_INSTANCE_ID = pcbpi.ID
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
          from bpel_variable_sensor_values
      group by variable_name, process_instance) bpmvmax,
       bpel_variable_sensor_values bpmv
 where bpmvmax.id = bpmv.id
go
print "Creating view bpel_variable_analysis_report"
go


/**
 * Create view for Fault sensor values
 */
create view bpel_fault_sensor_values
as
select pcfs.ID                  as id,
       pcfs.PROCESS_INSTANCE_ID as process_instance,
       pcbpi.CX_CIKEY           as instance_key,
       pcbp.NAME                as bpel_process_name,
       pcbp.VERSION             as bpel_process_revision,
       pcbp.CX_DOMAIN_ID        as domain_id,
       pcfs.SENSOR_NAME         as sensor_name,
       pcfs.SENSOR_TARGET       as sensor_target,
       pcfs.ACTION_NAME         as action_name,
       pcfs.ACTION_FILTER       as action_filter,
       pcfs.CREATION_DATE       as creation_date,
       pcfs.MODIFY_DATE         as modify_date,
       cast(pcfs.MODIFY_DATE as smalldatetime) as ts_date,
       pcfs.TS_HOUR             as ts_hour,
       pcfs.CRITERIA_SATISFIED  as criteria_satisfied,
       pcfs.ACTIVITY_NAME       as activity_name,
       pcfs.ACTIVITY_TYPE       as activity_type,
       pcfs.MESSAGE             as message
  from PC_FAULT_SENSOR_VALUES    pcfs,
       BPEL_PROCESS_INSTANCES    pcbpi,
       BPEL_PROCESSES            pcbp
 where pcbpi.BPEL_PROCESS_ID    = pcbp.ID
   and pcfs.PROCESS_INSTANCE_ID = pcbpi.ID
go
print "Creating view bpel_fault_sensor_values"
go


/**
 * Create view for errors
 */
create view bpel_errors
as
select pce.ID                   as id,
       pce.PROCESS_NAME         as bpel_process_name,
       pce.PROCESS_REVISION     as bpel_process_revision,
       pce.CX_DOMAIN_ID         as domain_id,
       pce.CREATION_DATE        as creation_date,
       cast(pce.CREATION_DATE as smalldatetime) as ts_date,
       pce.TS_HOUR              as ts_hour,
       pce.ERROR_CODE           as error_code,
       case pce.EXCEPTION_TYPE
         when 0 then 'Information'
         when 1 then 'Error'
         when 2 then 'System'
         when 3 then 'Warning'
         when 4 then 'Security'
         else 'Unknown'
       end                      as exception_type,
       pce.EXCEPTION_SEVERITY   as exception_severity,
       pce.EXCEPTION_NAME       as exception_name,
       pce.EXCEPTION_DESC       as exception_description,
       pce.EXCEPTION_FIX        as exception_fix,
       pce.EXCEPTION_CONTEXT    as exception_context,
       case pce.COMPONENT
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
       pce.THREAD_ID            as thread_id,
       pce.STACKTRACE           as stacktrace
  from PC_ERRORS pce
go
print "Creating view bpel_errors"
go

/**
 * Create view for Notification sensor values
 */
create view bpel_notif_sensor_values
as
select pcns.ID                  as id,
       pcns.PROCESS_INSTANCE_ID as process_instance,
       pcbpi.CX_CIKEY           as instance_key,
       pcns.ACTIVITY_SENSOR_ID  as activity_sensor,
       pcbp.NAME                as bpel_process_name,
       pcbp.VERSION             as bpel_process_revision,
       pcbp.CX_DOMAIN_ID        as domain_id,
       pcas.SENSOR_NAME         as sensor_name,
       pcas.SENSOR_TARGET       as sensor_target,
       pcas.ACTION_NAME         as action_name,
       pcas.ACTION_FILTER       as action_filter,
       pcas.CREATION_DATE       as creation_date,
       pcas.MODIFY_DATE         as modify_date,
       cast(pcas.MODIFY_DATE as smalldatetime) as ts_date,
       pcas.TS_HOUR             as ts_hour,
       pcas.CRITERIA_SATISFIED  as criteria_satisfied,
       pcas.EVAL_TIME           as eval_time,
       pcas.EVAL_POINT          as eval_point,
       pcas.ERROR_MESSAGE       as error_message,
       pcns.MESSAGE_ID          as message_id,
       pcns.MIME_TYPE           as mime_type,
       pcns.FROM_ADDRESS        as from_address,
       pcns.TO_ADDRESS          as to_address,
       pcns.NOTIFICATION_TYPE   as notification_type
  from PC_NOTIFICATION_SENSOR_VALUES pcns,
       PC_ACTIVITY_SENSOR_VALUES     pcas,
       BPEL_PROCESS_INSTANCES        pcbpi,
       BPEL_PROCESSES                pcbp
 where pcbpi.BPEL_PROCESS_ID    = pcbp.ID
   and pcas.PROCESS_INSTANCE_ID = pcbpi.ID
   and pcns.ACTIVITY_SENSOR_ID  = pcas.ID
   and pcns.PROCESS_INSTANCE_ID = pcas.PROCESS_INSTANCE_ID
go
print "Creating view bpel_notif_sensor_values"
go

/**
 * Create view for Adapter sensor values
 */
create view bpel_adapter_sensor_values
as
select pcadps.ID                as id,
       pcas.PROCESS_INSTANCE_ID as process_instance,
       pcbpi.CX_CIKEY           as instance_key,
       pcadps.ACTIVITY_SENSOR_ID as activity_sensor,
       pcbp.NAME                as bpel_process_name,
       pcbp.VERSION             as bpel_process_revision,
       pcbp.CX_DOMAIN_ID        as domain_id,
       pcas.SENSOR_NAME         as sensor_name,
       pcas.SENSOR_TARGET       as sensor_target,
       pcas.ACTION_NAME         as action_name,
       pcas.ACTION_FILTER       as action_filter,
       pcas.CREATION_DATE       as creation_date,
       pcas.MODIFY_DATE         as modify_date,
       cast(pcas.MODIFY_DATE as smalldatetime) as ts_date,
       pcas.TS_HOUR             as ts_hour,
       pcas.CRITERIA_SATISFIED  as criteria_satisfied,
       pcas.EVAL_TIME           as eval_time,
       pcas.EVAL_POINT          as eval_point,
       pcas.ERROR_MESSAGE       as error_message,
       pcadps.ENDPOINT          as endpoint,
       pcadps.ADAPTER_TYPE      as adapter_type,
       pcadps.PRIORITY          as priority,
       pcadps.MSG_SIZE          as msg_size,
       pcadps.DIRECTION         as direction
  from PC_ADAPTER_SENSOR_VALUES  pcadps,
       PC_ACTIVITY_SENSOR_VALUES pcas,
       BPEL_PROCESS_INSTANCES    pcbpi,
       BPEL_PROCESSES            pcbp
 where pcbpi.BPEL_PROCESS_ID      = pcbp.ID
   and pcas.PROCESS_INSTANCE_ID   = pcbpi.ID
   and pcadps.ACTIVITY_SENSOR_ID  = pcas.ID
   and pcadps.PROCESS_INSTANCE_ID = pcas.PROCESS_INSTANCE_ID
go
print "Creating view bpel_adapter_sensor_values"
go



