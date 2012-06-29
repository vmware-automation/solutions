if exists ( select * from sysobjects
            where name = 'PC_Task' and type = 'U' )
begin
    drop table PC_Task
    print "Dropping table PC_Task"
end

if exists ( select * from sysobjects
            where name = 'PC_TaskAssignee' and type = 'U' )
begin
    drop table PC_TaskAssignee
    print "Dropping table PC_TaskAssignee"
end

if exists ( select * from sysobjects
            where upper(name) = upper('PC_TaskAssigneeHistory') and type = 'U' )
begin
    drop table PC_TaskAssigneeHistory
    print "Dropping table PC_TaskAssigneeHistory"
end

if exists ( select * from sysobjects
            where name = 'PC_TaskHistory' and type = 'U' )
begin
    drop table PC_TaskHistory
    print "Dropping table PC_TaskHistory"
end

if exists ( select * from sysobjects
            where name = 'PC_TaskAttachment' and type = 'U' )
begin
    drop table PC_TaskAttachment
    print "Dropping table PC_TaskAttachment"
end

if exists ( select * from sysobjects
            where name = 'PC_TaskPayload' and type = 'U' )
begin
    drop table PC_TaskPayload
    print "Dropping table PC_TaskPayload"
end


if exists ( select * from sysobjects
            where name = 'PC_OWF' and type = 'U' )
begin
    drop table PC_OWF
    print "Dropping table PC_OWF"
end

if exists ( select * from sysobjects
            where name = 'TaskSequence' and type = 'U' )
begin
    drop table TaskSequence
    print "Dropping table TaskSequence"
end

go

/**
 * Task table contains the latest version of all the tasks in the system.
 * Attachments and payload are stored in the TaskAttachment table.
 */
CREATE TABLE PC_Task (
       Title                 VARCHAR(300)  NULL,
       IsGroup               VARCHAR(2)  CONSTRAINT PC_TASK_ISGROUP_CK CHECK
                                          ( IsGroup IN('T','F')),
       AcquiredBy            TEXT          NULL,
       Owner                 VARCHAR(50)   NULL,
       Conclusion            VARCHAR(50)   NULL,
       State                 VARCHAR(50)   NULL,
       SubState              TEXT          NULL,
       ProcessId             VARCHAR(50)   NULL,
       ProcessName           VARCHAR(100)  NULL,
       TaskId                VARCHAR(100) PRIMARY KEY,
       Version               INT            NULL,
       Notm                  INT DEFAULT 1,
       TaskGroupId           VARCHAR(100)   NULL,
       TaskType              TEXT          NULL,
       IdentificationKey     VARCHAR(50)   NULL,
       ExpirationDuration    TEXT          NULL,
       ExpirationDate        datetime       NULL,
       Priority              INT            NULL,
       Creator               VARCHAR(64)   NULL,
       CreatedDate           DATETIME NOT   NULL,
       UpdatedBy             VARCHAR(64)   NULL,
       ModifyDate            DATETIME       NULL,
       FlexString1           TEXT          NULL,
       FlexString2           TEXT          NULL,
       FlexString3           TEXT          NULL,
       FlexString4           TEXT          NULL,
       FlexLong1             FLOAT          NULL,
       FlexLong2             FLOAT          NULL,
       FlexDouble1           FLOAT          NULL,
       FlexDouble2           FLOAT          NULL,
       FlexDate1             DATETIME       NULL,
       FlexDate2             DATETIME       NULL,
       FlexDate3             DATETIME       NULL,
       ProcessVersion        VARCHAR(100)  NULL,
       InstanceId            VARCHAR(200)           NULL,
       DomainId              VARCHAR(100)   NULL,
       Approvers             TEXT          NULL,
       isHasSubTask          VARCHAR(2)    NULL,
       Comment1              TEXT          NULL,
       Comment2              TEXT          NULL,
       Comment3              TEXT          NULL,
       Comment4              TEXT          NULL,
       Comment5              TEXT          NULL,
       VersionReason         TEXT          NULL,
       ProcessOwner          TEXT          NULL,
       Pattern               TEXT          NULL,
       SystemString1         TEXT          NULL,
       SystemString2         TEXT          NULL,
       SystemString3         TEXT          NULL,
       TaskNumber            INT
)

lock datarows
print "Creating table PC_Task"
go


create index PC_TaskState_I on PC_Task(State)
create index pc_TaskTaskNumber_I on PC_Task(TaskNumber)
create index pc_TaskOwner_I on PC_Task(Owner)
create index pc_TaskProcessName_I on PC_Task(ProcessName)
create index pc_TaskExpirationDate_I on PC_Task(ExpirationDate)
create index pc_TaskPriority_I on PC_Task(Priority)
create index pc_TaskCreator_I on PC_Task(Creator)
create index pc_TaskCreatedDate_I on PC_Task(CreatedDate)
create index pc_TaskUpdatedBy_I on PC_Task(UpdatedBy)
create index pc_TaskModifyDate_I on PC_Task(ModifyDate)


CREATE TABLE PC_TaskAssignee (
       TaskId     VARCHAR(100) NOT NULL,
       Version    INT           NOT NULL,
       Assignee   VARCHAR(200) NOT NULL,
       Guid       VARCHAR(32)  NULL,
       IsGroup    VARCHAR(2) CONSTRAINT PC_TASKASSN_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskId, Version,Assignee )
)

lock datarows
print "Creating table PC_TaskAssignee"
go


create index PC_TaskAssigneeAssignee_I on PC_TaskAssignee(Assignee)

CREATE TABLE PC_TaskAssigneeHistory (
       TaskId      VARCHAR(100) NOT NULL,
       Version     INT            NOT NULL,
       MaxVersion  INT            NULL,
       Assignee    VARCHAR(200)  NOT NULL,
       Guid        VARCHAR(32)   NULL,
       IsGroup     VARCHAR(2) CONSTRAINT PC_TASKASSNHIST_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
       PRIMARY KEY (TaskId, Version,Assignee )
)

lock datarows
print "Creating table PC_TaskAssigneeHistory"
go

create index PC_TaskAssigneeHAssignee_I on PC_TaskAssigneeHistory(Assignee)

/**
 * TaskHistory table contains all versions of all the tasks in the system.
 * Attachments and payload are stored in the TaskAttachment table.
 */
CREATE TABLE PC_TaskHistory (
       Title                 VARCHAR(300)  NULL,
       IsGroup               VARCHAR(2)  CONSTRAINT PC_TASKHI_ISGROUP_CK CHECK
                                          ( IsGroup IN('T','F')),
       AcquiredBy            TEXT          NULL,
       Owner                 VARCHAR(50)   NULL,
       Conclusion            VARCHAR(50)   NULL,
       State                 VARCHAR(50)   NULL,
       SubState              TEXT          NULL,
       ProcessId             VARCHAR(50)   NULL,
       ProcessName           VARCHAR(100)  NULL,
       TaskId                VARCHAR(100) ,
       Version               INT            ,
       Notm                  INT DEFAULT 1,
       TaskGroupId           VARCHAR(100)   NULL,
       TaskType              TEXT          NULL,
       IdentificationKey     VARCHAR(50)   NULL,
       ExpirationDuration    TEXT          NULL,
       ExpirationDate        datetime       NULL,
       Priority              INT            NULL,
       Creator               VARCHAR(64)   NULL,
       CreatedDate           DATETIME NOT   NULL,
       UpdatedBy             VARCHAR(64)   NULL,
       ModifyDate            DATETIME       NULL,
       FlexString1           TEXT          NULL,
       FlexString2           TEXT          NULL,
       FlexString3           TEXT          NULL,
       FlexString4           TEXT          NULL,
       FlexLong1             FLOAT          NULL,
       FlexLong2             FLOAT          NULL,
       FlexDouble1           FLOAT          NULL,
       FlexDouble2           FLOAT          NULL,
       FlexDate1             DATETIME       NULL,
       FlexDate2             DATETIME       NULL,
       FlexDate3             DATETIME       NULL,
       ProcessVersion        VARCHAR(100)  NULL,
       InstanceId            VARCHAR(200)           NULL,
       DomainId              VARCHAR(100)   NULL,
       Approvers             TEXT          NULL,
       isHasSubTask          VARCHAR(2)    NULL,
       Comment1              TEXT          NULL,
       Comment2              TEXT          NULL,
       Comment3              TEXT          NULL,
       Comment4              TEXT          NULL,
       Comment5              TEXT          NULL,
       VersionReason         TEXT          NULL,
       ProcessOwner          TEXT          NULL,
       Pattern               TEXT          NULL,
       SystemString1         TEXT          NULL,
       SystemString2         TEXT          NULL,
       SystemString3         TEXT          NULL,
       TaskNumber            INT,
       PRIMARY KEY (TaskId, Version)
)

lock datarows
print "Creating table PC_TaskHistory"
go

create index PC_TaskHState_I on PC_TaskHistory(State)
create index pc_TaskHTaskNumber_I on PC_TaskHistory(TaskNumber)
create index pc_TaskHOwner_I on PC_TaskHistory(Owner)
create index pc_TaskHProcessName_I on PC_TaskHistory(ProcessName)
create index pc_TaskHExpirationDate_I on PC_TaskHistory(ExpirationDate)
create index pc_TaskHPriority_I on PC_TaskHistory(Priority)
create index pc_TaskHCreator_I on PC_TaskHistory(Creator)
create index pc_TaskHCreatedDate_I on PC_TaskHistory(CreatedDate)
create index pc_TaskHUpdatedBy_I on PC_TaskHistory(UpdatedBy)
create index pc_TaskHModifyDate_I on PC_TaskHistory(ModifyDate)


/**
 * TaskAttachment table contains all the attachments and payload of all
 * the task.
 */
CREATE TABLE PC_TaskAttachment (
       TaskId                   VARCHAR(100)  NOT NULL,
       Version                  INT            NOT NULL,
       MaxVersion               INT            NULL,
       URI                      VARCHAR(256)  NULL,
       Content                  IMAGE,
       Name                     VARCHAR(128) NOT NULL,
       PRIMARY KEY (TaskId,Version,Name)
)

lock datarows
print "Creating table PC_TaskAttachment"
go


create index PC_TASKATTACHMENTName_I  on PC_TaskAttachment (Name)

/**
 * TaskAttachment table contains all the attachments and payload of all
 * the task.
 */
CREATE TABLE PC_TaskPayload (
       TaskId                   VARCHAR(100) NOT NULL,
       Version                  INT           NOT NULL,
       MaxVersion               INT           NULL,
       PayloadType              INT           NULL,
       Payload                  IMAGE,
       PRIMARY KEY (TaskId,Version)
)

lock datarows
print "Creating table PC_TaskPayload"
go

CREATE TABLE PC_OWF 
(
 OWF_DATASOURCE      VARCHAR(120) NOT NULL,
 OWF_ITEM_TYPE       VARCHAR(8)   NOT NULL,
 OWF_ITEM_KEY        VARCHAR(80)  NOT NULL,
 BPEL_DOMAIN         VARCHAR(40)  NOT NULL,
 BPEL_PROCESS_ID     VARCHAR(60)  NOT NULL,
 BPEL_REVISION_TAG   VARCHAR(60),
 BPEL_PARTNER_LINK   VARCHAR(60),
 BPEL_INSTANCE_ID    VARCHAR(80) NOT NULL,
 CONSTRAINT PC_OWF_PK PRIMARY KEY (OWF_DATASOURCE, OWF_ITEM_TYPE, OWF_ITEM_KEY) 
)

lock datarows
print "Creating table PC_OWF"
go


create table TaskSequence (seqnumber INT)

lock datarows
print "Creating table TaskSequence"
go

insert into TaskSequence values(10000)
commit

