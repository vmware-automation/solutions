/*
 $Header: workflow_olite.sql 16-mar-2006.16:44:25 rarangas Exp $

 pcttask.sql

 Copyright (c) 2004, 2005, Oracle. All rights reserved.

    NAME
      workflow_olite.sql - schema for 10.1.3 Workflow services

    DESCRIPTION
      <short description of component this file declares/defines>

    NOTES
      In 10.1.3 human workflow shares the same schema with Oracle
      database, except the commit in th end required by Olite.

    MODIFIED   (MM/DD/YY)
    rarangas    03/16/06 - 
    seraiah     03/14/06 - Restoring 1012 tables for migration compatibility 
    seraiah     02/18/06 - On delete cascade issue resolved. Now using 
                           WFSchema_oracle.sql for both Oracleand Oracle Lite 
                           databases. 
    seraiah     02/06/06 - Olite script separated 
    seraiah     02/03/06 - Updating for 10.1.3 workflow schema 
*/

drop SEQUENCE pc_tasknumber_sq;


drop TABLE PC_TASKATTACHMENT;

drop TABLE PC_TASKPAYLOAD;

drop TABLE PC_TASKHISTORY;

drop TABLE PC_TASKASSIGNEEHISTORY;

drop TABLE PC_TASKASSIGNEE;

drop table PC_TASK;

drop table PC_OWF;

drop table BPELNOTIFICATION;

/**
 * Task table contains the latest version of all the tasks in the system.
 * Attachments and payload are stored in the TaskAttachment table.
 */
CREATE TABLE PC_TASK (
       Title                             VARCHAR2(300),
       IsGroup               VARCHAR2(2)  CONSTRAINT PC_TASK_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       AcquiredBy                      VARCHAR2(300),
       Owner                           VARCHAR2(300),
       Conclusion                        VARCHAR2(100),
       State                             VARCHAR2(100),
       SubState                          VARCHAR2(200),
       ProcessId                         VARCHAR2(100),
       ProcessName                       VARCHAR2(100),
       TaskID                            VARCHAR2(100) PRIMARY KEY,
       Version               INTEGER,
       NOTM                  INTEGER DEFAULT 1,
       TaskGroupId                     VARCHAR2(100),
       TaskType                        VARCHAR2(300),
       IdentificationKey           VARCHAR2(128),
       ExpirationDuration          VARCHAR2(64),
       ExpirationDate              DATE,
       Priority                   INTEGER ,
       Creator                         VARCHAR2(64),
       CreatedDate                     DATE,
       UpdatedBy                         VARCHAR2(64),
       ModifyDate                        DATE,
       FlexString1                     VARCHAR2(256),
       FlexString2                     VARCHAR2(256),
       FlexString3                     VARCHAR2(256),
       FlexString4                     VARCHAR2(256),
       FlexLong1                         NUMBER,
       FlexLong2                         NUMBER,
       FlexDouble1                     NUMBER,
       FlexDouble2                     NUMBER,
       FlexDate1                         DATE,
       FlexDate2                         DATE,
       FlexDate3                         DATE,
       ProcessVersion        VARCHAR2(100),
       InstanceId            VARCHAR2(200),
       DomainId              VARCHAR2(100),
       Approvers             VARCHAR2(2000),
       IsHasSubTask          VARCHAR2(2),
       Comment1              VARCHAR2(2000),
       Comment2              VARCHAR2(2000),
       Comment3              VARCHAR2(2000),
       Comment4              VARCHAR2(2000),
       Comment5              VARCHAR2(2000),
       VersionReason         VARCHAR2(2000),
       ProcessOwner          VARCHAR2(200),
       Pattern               VARCHAR2(2000),
       SystemString1         VARCHAR2(100),
       SystemString2         VARCHAR2(100),
       SystemString3         VARCHAR2(100),
       TaskNumber            NUMBER
);

create index PC_TaskState_I on PC_Task(state);
create index pc_TaskTaskNumber_I on PC_TASK(TaskNumber);
create index pc_TaskOwner_I on PC_TASK(Owner);
create index pc_TaskProcessName_I on PC_TASK(ProcessName);
create index pc_TaskExpirationDate_I on PC_TASK(ExpirationDate);
create index pc_TaskPriority_I on PC_TASK(Priority);
create index pc_TaskCreator_I on PC_TASK(Creator);
create index pc_TaskCreatedDate_I on PC_TASK(CreatedDate);
create index pc_TaskUpdatedBy_I on PC_TASK(UpdatedBy);
create index pc_TaskModifyDate_I on PC_TASK(ModifyDate);


commit;

CREATE TABLE PC_TASKASSIGNEE (
       TaskID   VARCHAR2(100),
       Version  NUMBER,
       Assignee     VARCHAR2(200),
       guid     VARCHAR2(32),
       IsGroup      VARCHAR2(2) CONSTRAINT PC_TASKASSN_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskID, Version,Assignee )
);

create index PC_TaskAssigneeAssignee_I on PC_TaskAssignee(Assignee);


commit;

CREATE TABLE PC_TASKASSIGNEEHISTORY (
       TaskID   VARCHAR2(100),
       Version  NUMBER,
       MaxVersion Number,
       Assignee     VARCHAR2(200),
       guid     VARCHAR2(32),
       IsGroup      VARCHAR2(2) CONSTRAINT PC_TASKASSNHIST_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskID, Version,Assignee )
);

create index PC_TaskAssigneeHAssignee_I on PC_TASKASSIGNEEHISTORY(Assignee);

/**
 * TaskHistory table contains all versions of all the tasks in the system.
 * Attachments and payload are stored in the TaskAttachment table.
 */
CREATE TABLE PC_TASKHISTORY (
       Title                             VARCHAR2(300),
       IsGroup               VARCHAR2(2) CONSTRAINT PC_TASKHI_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       AcquiredBy                      VARCHAR2(300),
       Owner                           VARCHAR2(300),
       Conclusion                        VARCHAR2(100),
       State                             VARCHAR2(100),
       SubState                          VARCHAR2(100),
       ProcessId                         VARCHAR2(200),
       ProcessName                       VARCHAR2(100),
       TaskId                            VARCHAR2(100),
       Version                 INTEGER,
       Notm                  INTEGER DEFAULT 1,
       TaskGroupId                     VARCHAR2(100),
       TaskType                        VARCHAR2(300),
       IdentificationKey           VARCHAR2(128),
       ExpirationDuration          VARCHAR2(64),
       ExpirationDate                DATE,
       Priority                        INTEGER,
       Creator                         VARCHAR2(64),
       CreatedDate                     DATE,
       UpdatedBy                         VARCHAR2(64),
       ModifyDate                        DATE,
       FlexString1                     VARCHAR2(256),
       FlexString2                     VARCHAR2(256),
       FlexString3                     VARCHAR2(256),
       FlexString4                     VARCHAR2(256),
       FlexLong1                         NUMBER,
       FlexLong2                         NUMBER,
       FlexDouble1                     NUMBER,
       FlexDouble2                     NUMBER,
       FlexDate1                         DATE,
       FlexDate2                         DATE,
       FlexDate3                         DATE,
       ProcessVersion        VARCHAR2(100),
       InstanceId            VARCHAR2(200),
       DomainId              VARCHAR2(100),
       Approvers             VARCHAR2(2000),
       IsHasSubTask          VARCHAR2(2),
       Comment1              VARCHAR2(2000),
       Comment2              VARCHAR2(2000),
       Comment3              VARCHAR2(2000),
       Comment4              VARCHAR2(2000),
       Comment5              VARCHAR2(2000),
       VersionReason         VARCHAR2(2000),
       ProcessOwner          VARCHAR2(200),
       Pattern               VARCHAR2(2000),
       SystemString1         VARCHAR2(100),
       SystemString2         VARCHAR2(100),
       SystemString3         VARCHAR2(100),
       TaskNumber            NUMBER,
       PRIMARY KEY (TaskId, Version)
);

create index PC_TaskHState_I on PC_TASKHISTORY(state);
create index pc_TaskHTaskNumber_I on PC_TASKHISTORY(TaskNumber);
create index pc_TaskHOwner_I on PC_TASKHISTORY(Owner);
create index pc_TaskHProcessName_I on PC_TASKHISTORY(ProcessName);
create index pc_TaskHExpirationDate_I on PC_TASKHISTORY(ExpirationDate);
create index pc_TaskHPriority_I on PC_TASKHISTORY(Priority);
create index pc_TaskHCreator_I on PC_TASKHISTORY(Creator);
create index pc_TaskHCreatedDate_I on PC_TASKHISTORY(CreatedDate);
create index pc_TaskHUpdatedBy_I on PC_TASKHISTORY(UpdatedBy);
create index pc_TaskHModifyDate_I on PC_TASKHISTORY(ModifyDate);


commit;
/**
 * TaskAttachment table contains all the attachments and payload of all
 * the task.
 */
CREATE TABLE PC_TASKATTACHMENT (
       TaskId                   VARCHAR2(100),
       Version          INTEGER,
       MaxVersion INTEGER,
       URI                        VARCHAR2(256),
       Content    BLOB,
       Name                       VARCHAR2(128),
       PRIMARY KEY (TaskId,Version,Name)
);

create index PC_TASKATTACHMENTName_I  on PC_TASKATTACHMENT (name);

commit;

/**
 * TaskAttachment table contains all the attachments and payload of all
 * the task.
 */
CREATE TABLE PC_TASKPAYLOAD (
       TaskId                   VARCHAR2(100),
       Version          INTEGER,
       MaxVersion INTEGER,
       PayloadType INTEGER,
       Payload    BLOB,
       PRIMARY KEY (TaskId,Version)
);

commit;


CREATE SEQUENCE pc_tasknumber_sq  START WITH 10000 INCREMENT BY 1;

CREATE TABLE PC_OWF 
(
 OWF_DATASOURCE      VARCHAR2(120) NOT NULL,
 OWF_ITEM_TYPE       VARCHAR2(8) NOT NULL,
 OWF_ITEM_KEY        VARCHAR2(80) NOT NULL,
 BPEL_DOMAIN         VARCHAR2(40) NOT NULL,
 BPEL_PROCESS_ID     VARCHAR2(60) NOT NULL,
 BPEL_REVISION_TAG   VARCHAR2(60),
 BPEL_PARTNER_LINK   VARCHAR2(60),
 BPEL_INSTANCE_ID    VARCHAR2(80) NOT NULL,
 CONSTRAINT PC_OWF_PK PRIMARY KEY (OWF_DATASOURCE, OWF_ITEM_TYPE, OWF_ITEM_KEY) 
);

commit;

CREATE TABLE  BPELNOTIFICATION
(
  ID VARCHAR2(200) primary key, 
  DESTINATIONADDRESS VARCHAR2(2000),
  DESTINATIONTYPE VARCHAR2(2000),
  WFTASKID VARCHAR2(200),
  WFTASKVERSION INTEGER,
  WFTASKACTION VARCHAR2(200),
  CREATEDTIME DATE,
  STATUS VARCHAR2(200), 
  ATTEMPTEDNUMBER INTEGER,
  TYPE VARCHAR2(100), 
  CALLER VARCHAR2(100),  
  OUTPUTMESSAGE VARCHAR2(2000),
  MESSAGE BLOB
);

commit;




@@WFSchema_oracle.sql
commit;


