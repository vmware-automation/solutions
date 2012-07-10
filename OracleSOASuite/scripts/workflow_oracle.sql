Rem
Rem $Header: workflow_oracle.sql 16-mar-2006.16:44:25 rarangas Exp $
Rem
Rem workflow_oracle.sql
Rem
Rem Copyright (c) 2004, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      workflow_oracle.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rarangas    03/16/06 - 
Rem    seraiah     03/14/06 - Restoring 1012 tables for migration 
Rem                           compatibility 
Rem    seraiah     02/03/06 - Updating the SQL scripts for workflow in 10.1.3 
Rem    ykuntawa    10/10/05 - Adding notification table
Rem    kmreddy     02/25/05 - performance changes
Rem    ykuntawa    02/09/05 - Adding new columns
Rem    ykuntawa    01/07/05 - Adding pattern attribute
Rem    ykuntawa    09/03/04 - Adding column VersionChange
Rem    ykuntawa    08/02/04 - Adding more columns
Rem    mkamath     07/27/04 - Worklist Service Changes
Rem    ykuntawa    07/16/04 - Adding pc_taskassigneehistory table
Rem    ykuntawa    06/29/04 - ykuntawa_taskservice_phase1
Rem    ykuntawa    06/29/04 - Created
Rem

drop SEQUENCE pc_tasknumber_sq;

drop procedure pc_createAssigneeHistory;

drop procedure pc_insertAssignee;

drop INDEX PC_TaskState_I;

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
       Title                             NVARCHAR2(300),
       IsGroup               NVARCHAR2(2)  CONSTRAINT PC_TASK_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       AcquiredBy                      NVARCHAR2(300),
       Owner                           NVARCHAR2(300),
       Conclusion                        NVARCHAR2(100),
       State                             NVARCHAR2(100),
       SubState                          NVARCHAR2(200),
       ProcessId                         NVARCHAR2(100),
       ProcessName                       NVARCHAR2(100),
       TaskID                            NVARCHAR2(32) PRIMARY KEY,
       Version               INTEGER,
       NOTM                  INTEGER DEFAULT 1,
       TaskGroupId                     NVARCHAR2(32),
       TaskType                        NVARCHAR2(300),
       IdentificationKey           NVARCHAR2(128),
       ExpirationDuration          NVARCHAR2(64),
       ExpirationDate              DATE,
       Priority                   INTEGER ,
       Creator                         NVARCHAR2(64),
       CreatedDate                     DATE,
       UpdatedBy                         NVARCHAR2(64),
       ModifyDate                        DATE,
       FlexString1                     NVARCHAR2(256),
       FlexString2                     NVARCHAR2(256),
       FlexString3                     NVARCHAR2(256),
       FlexString4                     NVARCHAR2(256),
       FlexLong1                         NUMBER,
       FlexLong2                         NUMBER,
       FlexDouble1                     NUMBER,
       FlexDouble2                     NUMBER,
       FlexDate1                         DATE,
       FlexDate2                         DATE,
       FlexDate3                         DATE,
       ProcessVersion        NVARCHAR2(100),
       InstanceId            NVARCHAR2(200),
       DomainId              NVARCHAR2(100),
       Approvers             NVARCHAR2(2000),
       IsHasSubTask          NVARCHAR2(2),
       Comment1              NVARCHAR2(2000),
       Comment2              NVARCHAR2(2000),
       Comment3              NVARCHAR2(2000),
       Comment4              NVARCHAR2(2000),
       Comment5              NVARCHAR2(2000),
       VersionReason         NVARCHAR2(2000),
       ProcessOwner          NVARCHAR2(200),
       Pattern               NVARCHAR2(2000),
       SystemString1         NVARCHAR2(200),
       SystemString2         NVARCHAR2(200),
       SystemString3         NVARCHAR2(200),
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


CREATE TABLE PC_TASKASSIGNEE (
       TaskID   NVARCHAR2(32),
       Version  NUMBER,
       Assignee     NVARCHAR2(200),
       guid     NVARCHAR2(32),
       IsGroup      NVARCHAR2(2) CONSTRAINT PC_TASKASSN_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskID, Version,Assignee )
);

create index PC_TaskAssigneeAssignee_I on PC_TaskAssignee(Assignee);

CREATE TABLE PC_TASKASSIGNEEHISTORY (
       TaskID   NVARCHAR2(32),
       Version  NUMBER,
       MaxVersion Number,
       Assignee     NVARCHAR2(200),
       guid     NVARCHAR2(32),
       IsGroup      NVARCHAR2(2) CONSTRAINT PC_TASKASSNHIST_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskID, Version,Assignee )
);

create index PC_TaskAssigneeHAssignee_I on PC_TASKASSIGNEEHISTORY(Assignee);

/**
 * TaskHistory table contains all versions of all the tasks in the system.
 * Attachments and payload are stored in the TaskAttachment table.
 */
CREATE TABLE PC_TASKHISTORY (
       Title                             NVARCHAR2(300),
       IsGroup               NVARCHAR2(2) CONSTRAINT PC_TASKHI_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       AcquiredBy                      NVARCHAR2(300),
       Owner                           NVARCHAR2(300),
       Conclusion                        NVARCHAR2(100),
       State                             NVARCHAR2(100),
       SubState                          NVARCHAR2(100),
       ProcessId                         NVARCHAR2(200),
       ProcessName                       NVARCHAR2(100),
       TaskId                            NVARCHAR2(32),
       Version                 INTEGER,
       Notm                  INTEGER DEFAULT 1,
       TaskGroupId                     NVARCHAR2(32),
       TaskType                        NVARCHAR2(300),
       IdentificationKey           NVARCHAR2(128),
       ExpirationDuration          NVARCHAR2(64),
       ExpirationDate                DATE,
       Priority                        INTEGER,
       Creator                         NVARCHAR2(64),
       CreatedDate                     DATE,
       UpdatedBy                         NVARCHAR2(64),
       ModifyDate                        DATE,
       FlexString1                     NVARCHAR2(256),
       FlexString2                     NVARCHAR2(256),
       FlexString3                     NVARCHAR2(256),
       FlexString4                     NVARCHAR2(256),
       FlexLong1                         NUMBER,
       FlexLong2                         NUMBER,
       FlexDouble1                     NUMBER,
       FlexDouble2                     NUMBER,
       FlexDate1                         DATE,
       FlexDate2                         DATE,
       FlexDate3                         DATE,
       ProcessVersion        NVARCHAR2(100),
       InstanceId            NVARCHAR2(200),
       DomainId              NVARCHAR2(100),
       Approvers             NVARCHAR2(2000),
       IsHasSubTask          NVARCHAR2(2),
       Comment1              NVARCHAR2(2000),
       Comment2              NVARCHAR2(2000),
       Comment3              NVARCHAR2(2000),
       Comment4              NVARCHAR2(2000),
       Comment5              NVARCHAR2(2000),
       VersionReason         NVARCHAR2(2000),
       ProcessOwner          NVARCHAR2(200),
       Pattern               NVARCHAR2(2000),
       SystemString1         NVARCHAR2(200),
       SystemString2         NVARCHAR2(200),
       SystemString3         NVARCHAR2(200),
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


/**
 * TaskAttachment table contains all the attachments and payload of all
 * the task.
 */
CREATE TABLE PC_TASKATTACHMENT (
       TaskId                   NVARCHAR2(32),
       Version          INTEGER,
       MaxVersion INTEGER,
       URI                        NVARCHAR2(256),
       Content    BLOB,
       Name                       NVARCHAR2(128),
       PRIMARY KEY (TaskId,Version,Name)
);


create index PC_TASKATTACHMENTName_I  on PC_TASKATTACHMENT (name);

/**
 * TaskAttachment table contains all the attachments and payload of all
 * the task.
 */
CREATE TABLE PC_TASKPAYLOAD (
       TaskId                   NVARCHAR2(32),
       Version          INTEGER,
       MaxVersion INTEGER,
       PayloadType INTEGER,
       Payload    BLOB,
       PRIMARY KEY (TaskId,Version)
);



CREATE SEQUENCE pc_tasknumber_sq  START WITH 10000 INCREMENT BY 1;


CREATE OR REPLACE PROCEDURE PC_CreateAssigneeHistory(
                          v_taskId IN VARCHAR2,
                          v_maxVersion IN NUMBER,
                          v_assignee IN VARCHAR2)
IS
BEGIN
   IF v_assignee IS NOT NULL THEN
     UPDATE PC_TASKASSIGNEEHISTORY
        SET MaxVersion = v_maxVersion
        WHERE taskId = v_taskId
        AND assignee = v_assignee
        AND MaxVersion is NULL
        AND version <= v_maxVersion;

      DELETE FROM PC_TASKASSIGNEE
          WHERE taskId = v_taskId
                   AND assignee = v_assignee
                   AND version <= v_maxVersion;
    ELSE
      UPDATE PC_TASKASSIGNEEHISTORY
        SET MaxVersion = v_maxVersion
        WHERE taskId = v_taskId
              AND MaxVersion is NULL
              AND version <= v_maxVersion;

      DELETE FROM PC_TASKASSIGNEE
          WHERE taskId = v_taskId
            AND version <= v_maxVersion ;

    END IF;

EXCEPTION
  WHEN OTHERS THEN
     raise_application_error(-20001,
       'Exception while creating Assignee history ', true);
END;
/


CREATE OR REPLACE PROCEDURE PC_InsertAssignee(
                            v_taskId IN VARCHAR2,
                            v_version IN NUMBER,
                            v_assignee IN VARCHAR2,
                            v_guid IN VARCHAR2,
                            v_isGroup IN VARCHAR2)
IS
BEGIN
  INSERT INTO PC_TASKASSIGNEEHISTORY
        (taskId, version ,  Assignee,guid,isGroup)
        VALUES(v_taskId,v_version,v_assignee,v_guid,v_isGroup);
  INSERT INTO PC_TASKASSIGNEE
        (taskId, version ,  Assignee,guid,isGroup)
        VALUES(v_taskId,v_version,v_assignee,v_guid,v_isGroup);


EXCEPTION
  WHEN OTHERS THEN
     raise_application_error(-20001,
       'Exception while creating Assignee history ', true);
END;
/

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

CREATE TABLE  BPELNOTIFICATION
(
  ID NVARCHAR2(200) primary key,
  DESTINATIONADDRESS NVARCHAR2(2000),
  DESTINATIONTYPE NVARCHAR2(2000),
  WFTASKID NVARCHAR2(200),
  WFTASKVERSION INTEGER,
  WFTASKACTION NVARCHAR2(200),
  CREATEDTIME DATE,
  STATUS NVARCHAR2(200),
  ATTEMPTEDNUMBER INTEGER,
  TYPE NVARCHAR2(100),
  CALLER NVARCHAR2(100),
  OUTPUTMESSAGE NVARCHAR2(2000),
  MESSAGE BLOB
);

@@WFSchema_oracle.sql
@@WFPackage_oracle.sql
