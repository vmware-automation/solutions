drop table PC_TASK;
drop table PC_TASKASSIGNEE;
drop table PC_TASKASSIGNEEHISTORY;
drop table PC_TASKHISTORY;
drop table PC_TASKATTACHMENT;
drop table PC_TASKPAYLOAD;
drop table PC_OWF;
drop table TASKSEQUENCE;

/**
 * Task table contains the latest version of all the tasks in the system.
 * Attachments and payload are stored in the TaskAttachment table.
 */
CREATE TABLE PC_TASK (
       Title                 NVARCHAR(300)  NULL,
       IsGroup               NVARCHAR(2)  CONSTRAINT PC_TASK_ISGROUP_CK CHECK
                                          ( IsGroup IN('T','F')),
       AcquiredBy            NTEXT          NULL,
       Owner                 NVARCHAR(50)   NULL,
       Conclusion            NVARCHAR(50)   NULL,
       State                 NVARCHAR(50)   NULL,
       SubState              NTEXT          NULL,
       ProcessId             NVARCHAR(50)   NULL,
       ProcessName           NVARCHAR(100)  NULL,
       TaskID                NVARCHAR(100) PRIMARY KEY,
       Version               INT            NULL,
       NOTM                  INT DEFAULT 1,
       TaskGroupId           NVARCHAR(100)   NULL,
       TaskType              NTEXT          NULL,
       IdentificationKey     NVARCHAR(50)   NULL,
       ExpirationDuration    NTEXT          NULL,
       ExpirationDate        datetime       NULL,
       Priority              INT            NULL,
       Creator               NVARCHAR(64)   NULL,
       CreatedDate           DATETIME NOT   NULL,
       UpdatedBy             NVARCHAR(64)   NULL,
       ModifyDate            DATETIME       NULL,
       FlexString1           NTEXT          NULL,
       FlexString2           NTEXT          NULL,
       FlexString3           NTEXT          NULL,
       FlexString4           NTEXT          NULL,
       FlexLong1             FLOAT          NULL,
       FlexLong2             FLOAT          NULL,
       FlexDouble1           FLOAT          NULL,
       FlexDouble2           FLOAT          NULL,
       FlexDate1             DATETIME       NULL,
       FlexDate2             DATETIME       NULL,
       FlexDate3             DATETIME       NULL,
       ProcessVersion        NVARCHAR(100)  NULL,
       InstanceId            NVARCHAR(200)           NULL,
       DomainId              NVARCHAR(100)   NULL,
       Approvers             NTEXT          NULL,
       IsHasSubTask          NVARCHAR(2)    NULL,
       Comment1              NTEXT          NULL,
       Comment2              NTEXT          NULL,
       Comment3              NTEXT          NULL,
       Comment4              NTEXT          NULL,
       Comment5              NTEXT          NULL,
       VersionReason         NTEXT          NULL,
       ProcessOwner          NTEXT          NULL,
       Pattern               NTEXT          NULL,
       SystemString1         NTEXT          NULL,
       SystemString2         NTEXT          NULL,
       SystemString3         NTEXT          NULL,
       TaskNumber            INT
);
go

create index PC_TaskState_I on PC_TASK(State);
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
       TaskID     NVARCHAR(100) NOT NULL,
       Version    INT           NOT NULL,
       Assignee   NVARCHAR(200) NOT NULL,
       guid       NVARCHAR(32)  NULL,
       IsGroup    NVARCHAR(2) CONSTRAINT PC_TASKASSN_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskID, Version,Assignee )
);
go

create index PC_TaskAssigneeAssignee_I on PC_TASKASSIGNEE(Assignee);

CREATE TABLE PC_TASKASSIGNEEHISTORY (
       TaskID      NVARCHAR(100) NOT NULL,
       Version     INT            NOT NULL,
       MaxVersion  INT            NULL,
       Assignee    NVARCHAR(200)  NOT NULL,
       guid        NVARCHAR(32)   NULL,
       IsGroup     NVARCHAR(2) CONSTRAINT PC_TASKASSNHIST_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskID, Version,Assignee )
);

create index PC_TaskAssigneeHAssignee_I on PC_TASKASSIGNEEHISTORY(Assignee);

/**
 * TaskHistory table contains all versions of all the tasks in the system.
 * Attachments and payload are stored in the TaskAttachment table.
 */
CREATE TABLE PC_TASKHISTORY (
       Title                 NVARCHAR(300)  NULL,
       IsGroup               NVARCHAR(2)  CONSTRAINT PC_TASKHI_ISGROUP_CK CHECK
                                          ( IsGroup IN('T','F')),
       AcquiredBy            NTEXT          NULL,
       Owner                 NVARCHAR(50)   NULL,
       Conclusion            NVARCHAR(50)   NULL,
       State                 NVARCHAR(50)   NULL,
       SubState              NTEXT          NULL,
       ProcessId             NVARCHAR(50)   NULL,
       ProcessName           NVARCHAR(100)  NULL,
       TaskId                NVARCHAR(100) ,
       Version               INT            ,
       NOTM                  INT DEFAULT 1,
       TaskGroupId           NVARCHAR(100)   NULL,
       TaskType              NTEXT          NULL,
       IdentificationKey     NVARCHAR(50)   NULL,
       ExpirationDuration    NTEXT          NULL,
       ExpirationDate        datetime       NULL,
       Priority              INT            NULL,
       Creator               NVARCHAR(64)   NULL,
       CreatedDate           DATETIME NOT   NULL,
       UpdatedBy             NVARCHAR(64)   NULL,
       ModifyDate            DATETIME       NULL,
       FlexString1           NTEXT          NULL,
       FlexString2           NTEXT          NULL,
       FlexString3           NTEXT          NULL,
       FlexString4           NTEXT          NULL,
       FlexLong1             FLOAT          NULL,
       FlexLong2             FLOAT          NULL,
       FlexDouble1           FLOAT          NULL,
       FlexDouble2           FLOAT          NULL,
       FlexDate1             DATETIME       NULL,
       FlexDate2             DATETIME       NULL,
       FlexDate3             DATETIME       NULL,
       ProcessVersion        NVARCHAR(100)  NULL,
       InstanceId            NVARCHAR(200)           NULL,
       DomainId              NVARCHAR(100)   NULL,
       Approvers             NTEXT          NULL,
       IsHasSubTask          NVARCHAR(2)    NULL,
       Comment1              NTEXT          NULL,
       Comment2              NTEXT          NULL,
       Comment3              NTEXT          NULL,
       Comment4              NTEXT          NULL,
       Comment5              NTEXT          NULL,
       VersionReason         NTEXT          NULL,
       ProcessOwner          NTEXT          NULL,
       Pattern               NTEXT          NULL,
       SystemString1         NTEXT          NULL,
       SystemString2         NTEXT          NULL,
       SystemString3         NTEXT          NULL,
       TaskNumber            INT,
       PRIMARY KEY (TaskId, Version)
);

create index PC_TaskHState_I on PC_TASKHISTORY(State);
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
       TaskId                   NVARCHAR(100)  NOT NULL,
       Version                  INT            NOT NULL,
       MaxVersion               INT            NULL,
       URI                      NVARCHAR(256)  NULL,
       Content                  IMAGE,
       Name                     NVARCHAR(128) NOT NULL,
       PRIMARY KEY (TaskId,Version,Name)
);


create index PC_TASKATTACHMENTName_I  on PC_TASKATTACHMENT (Name);

/**
 * TaskAttachment table contains all the attachments and payload of all
 * the task.
 */
CREATE TABLE PC_TASKPAYLOAD (
       TaskId                   NVARCHAR(100) NOT NULL,
       Version                  INT           NOT NULL,
       MaxVersion               INT           NULL,
       PayloadType              INT           NULL,
       Payload                  IMAGE,
       PRIMARY KEY (TaskId,Version)
);



CREATE TABLE PC_OWF 
(
 OWF_DATASOURCE      NVARCHAR(120) NOT NULL,
 OWF_ITEM_TYPE       NVARCHAR(8)   NOT NULL,
 OWF_ITEM_KEY        NVARCHAR(80)  NOT NULL,
 BPEL_DOMAIN         NVARCHAR(40)  NOT NULL,
 BPEL_PROCESS_ID     NVARCHAR(60)  NOT NULL,
 BPEL_REVISION_TAG   NVARCHAR(60),
 BPEL_PARTNER_LINK   NVARCHAR(60),
 BPEL_INSTANCE_ID    NVARCHAR(80) NOT NULL,
 CONSTRAINT PC_OWF_PK PRIMARY KEY (OWF_DATASOURCE, OWF_ITEM_TYPE, OWF_ITEM_KEY) 
);

create table TASKSEQUENCE (seqnumber INT);
insert into TASKSEQUENCE values(10000);


