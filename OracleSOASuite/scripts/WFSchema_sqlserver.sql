/**
Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/WFSchema_sqlserver.sql /st_pcbpel_10.1.3.1/9 2010/05/20 11:27:07 wstallar Exp $
Rem
Rem WFSchema_oracle.sql
Rem
Rem Copyright (c) 2005, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      WFSchema_oracle.sql - Workflow database schema
Rem
Rem    DESCRIPTION
Rem      Set of tables used by Human workflow services
Rem
Rem    NOTES
Rem      This file was developed in a separate directory under
Rem      workflow and I moved it here (the final place). So, 
Rem      the history is retained
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wstallar    05/05/10 - Backport wstallar_bug-8648362 from
Rem                           st_pcbpel_10.1.3.1
Rem    wstallar    10/30/09 - Bug 8648362: adding table WFRuleDictionaryNOTM
Rem    mnanal      03/09/09 - Backport mnanal_bug-7286083 from
Rem                           st_pcbpel_10.1.3.1
Rem    mnanal      02/06/09 - Backport mnanal_bug-7022475 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     12/29/08 - Backport ramisra_bug-6955137 from
Rem                           st_pcbpel_10.1.3.1
Rem    ramisra     03/17/08 - Backport ramisra_bug-6845586 from
Rem                           st_pcbpel_10.1.3.1
Rem    sraghura    01/07/08 - SQLServer porting new class
Rem    ykuntawa    08/03/06 - Remove indexes
Rem    ykuntawa    07/20/06 - XbranchMerge ykuntawa_bug-5395008 from main 
Rem    ykuntawa    07/19/06 - Adding index 
Rem    ykuntawa    06/15/06 - Create indexes on foreign keys to avoid deadlock 
Rem    ykuntawa    06/09/06 - 
Rem    seraiah     05/30/06 - 
Rem    seraiah     06/01/06 - 
Rem    rarangas    05/23/06 - 
Rem    ykuntawa    05/16/06 - Adding indexex 
Rem    ykuntawa    05/11/06 - Adding identificationKey 
Rem    rarangas    03/21/06 - 
Rem    seraiah     03/14/06 - Restoring 1012 tables for migration 
Rem                           compatibility 
Rem    ykuntawa    03/06/06 - add version support
Rem    rarangas    02/22/06 - 
Rem    seraiah     02/09/06 - move REM and SET statements  inside comments. The install
                              scripts execute JDBC calls based on contents of this file 
                              and REM and SET are not recognized by JDBC
Rem    seraiah     02/08/06 - Restore the BPELNOTIFICATION table used by the 
Rem                           notification service which is still using the 
Rem                           old perssitancy api 
Rem    seraiah     02/06/06 - Retain the PC_OWF table from 1012 
Rem    seraiah     01/17/06 - Coding for Olite persistancy. 
Rem    ykuntawa    01/22/06 - Adding taskDefinitionURI 
Rem    rarangas    12/23/05 - 
Rem    ykuntawa    12/19/05 - Change column names 
Rem    ykuntawa    12/12/05 - Add tables for WFTask metadata
Rem    wgstalla    11/01/05 - Add tables for user metadata 
Rem    ykuntawa    10/27/05 - Modifying schema 
Rem    ykuntawa    08/08/05 - Adding UserVacationSchema
Rem    ykuntawa    08/04/05 - ykuntawa_workflow_persistency_as11_1
Rem    ykuntawa    07/29/05 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
*/

DROP VIEW WFProductivity_view;
DROP VIEW WFTaskpriority_view;
DROP VIEW WFUnattendedtasks_view;
DROP VIEW WFTaskcycletime_view;


DROP TABLE WFTaskHistory;
DROP TABLE WFComments;

DROP TABLE WFMessageAttribute;
DROP TABLE WFAttachment;
DROP TABLE WFAssignee;
DROP TABLE WFRoutingSlip;
DROP TABLE WFNotification;
DROP TABLE WFNotificationStatus;


/*DROP SEQUENCE WFTaskSeq; This was used in oracle*/

DROP TABLE WF_TASKSEQUENCE;

drop procedure get_WF_TaskSequence_NextVal;

DROP TABLE WFUserVacation;

DROP TABLE WFUserTaskViewGrant;
DROP TABLE WFUserTaskView;
DROP TABLE WFUserPreference;

DROP TABLE WFTaskDisplay;
DROP TABLE WFTaskMetadata;
DROP TABLE WFTaskTimer;

DROP TABLE WFAttributeLabelUsage;
DROP TABLE WFAttributeLabelMap;
DROP TABLE WFTask;

DROP TABLE WFNotificationMessages;

DROP TABLE WFRuleDictionaryNOTM;

CREATE TABLE WFTask ( acquiredBy     VARCHAR(300),
   assigneeGroups                    VARCHAR(2000),
   assigneeGroupsDisplayName         VARCHAR(2000),
   assigneeUsers                     VARCHAR(2000),
   assigneeUsersDisplayName          VARCHAR(2000),
   callbackContext                   VARCHAR(2000),
   callbackId                        VARCHAR(2000),
   callbackType                      VARCHAR(20),
   creator                           VARCHAR(300),
   digitalSignatureRequired          VARCHAR(1),
   expirationDate                    DATETIME,
   expirationDuration                VARCHAR(64),
   identityContext                   VARCHAR(200),
   ownerUser                         VARCHAR(300),
   ownerGroup                        VARCHAR(300),
   passwordRequiredOnUpdate          VARCHAR(1),
   priority                          INT,
   domainId                          VARCHAR(100),
   instanceId                        VARCHAR(200),
   processId                         VARCHAR(100),
   processName                       VARCHAR(100),
   processType                       VARCHAR(10),
   processVersion                    VARCHAR(100),
   secureNotifications               VARCHAR(1),
   accessKey                         VARCHAR(80),
   approvalDuration                  INT,
   approvers                         VARCHAR(2000),
   assignedDate                      DATETIME,
   createdDate                       DATETIME,
   elapsedTime                       INT,
   endDate                           DATETIME,
   fromUser                          VARCHAR(100),
   fromUserDisplayName               VARCHAR(200),
   hasSubtask                        VARCHAR(1),
   inShortHistory                    VARCHAR(1),
   isGroup                           VARCHAR(1),
   language                          VARCHAR(4),
   mailStatus                        VARCHAR(8),
   numberOfTimesModified             INT,
   originalAssigneeUser              VARCHAR(100),
   outcome                           VARCHAR(100),
   parallelOutcomeCount              VARCHAR(300),
   pushbackSequence                  VARCHAR(200),
   State                             VARCHAR(100),
   SubState                          VARCHAR(200),
   systemString1                     VARCHAR(200),
   systemString2                     VARCHAR(200),
   SystemString3                     VARCHAR(200),
   taskGroupId                       VARCHAR(64),
   taskId                            VARCHAR(64) PRIMARY KEY,
   taskNumber                        INT,
   updatedBy                         VARCHAR(64),
   updatedByDisplayName              VARCHAR(200),
   updatedDate                       DATETIME,
   version                           INT,
   versionReason                     VARCHAR(2000),
   workflowPattern                   VARCHAR(2000),
   textAttribute1                    VARCHAR(2000),
   textAttribute2                    VARCHAR(2000),
   textAttribute3                    VARCHAR(2000),
   textAttribute4                    VARCHAR(2000),
   textAttribute5                    VARCHAR(2000),
   textAttribute6                    VARCHAR(2000),
   textAttribute7                    VARCHAR(2000),
   textAttribute8                    VARCHAR(2000),
   textAttribute9                    VARCHAR(2000),
   textAttribute10                   VARCHAR(2000),
   formAttribute1                    VARCHAR(2000),
   formAttribute2                    VARCHAR(2000),
   formAttribute3                    VARCHAR(2000),
   formAttribute4                    VARCHAR(2000),
   formAttribute5                    VARCHAR(2000),
   urlAttribute1                     VARCHAR(200),
   urlAttribute2                     VARCHAR(200),
   urlAttribute3                     VARCHAR(200),
   urlAttribute4                     VARCHAR(200),
   urlAttribute5                     VARCHAR(200),
   dateAttribute1                    DATETIME,
   dateAttribute2                    DATETIME,
   dateAttribute3                    DATETIME,
   dateAttribute4                    DATETIME,
   dateAttribute5                    DATETIME,
   numberAttribute1                  INT,
   numberAttribute2                  INT,
   numberAttribute3                  INT,
   numberAttribute4                  INT,
   numberAttribute5                  INT,
   protectedTextAttribute1           VARCHAR(2000),
   protectedTextAttribute2           VARCHAR(2000),
   protectedTextAttribute3           VARCHAR(2000),
   protectedTextAttribute4           VARCHAR(2000),
   protectedTextAttribute5           VARCHAR(2000),
   protectedTextAttribute6           VARCHAR(2000),
   protectedTextAttribute7           VARCHAR(2000),
   protectedTextAttribute8           VARCHAR(2000),
   protectedTextAttribute9           VARCHAR(2000),
   protectedTextAttribute10          VARCHAR(2000),
   protectedFormAttribute1           VARCHAR(2000),
   protectedFormAttribute2           VARCHAR(2000),
   protectedFormAttribute3           VARCHAR(2000),
   protectedFormAttribute4           VARCHAR(2000),
   protectedFormAttribute5           VARCHAR(2000),
   protectedUrlAttribute1            VARCHAR(200),
   protectedUrlAttribute2            VARCHAR(200),
   protectedUrlAttribute3            VARCHAR(200),
   protectedUrlAttribute4            VARCHAR(200),
   protectedUrlAttribute5            VARCHAR(200),
   protectedDateAttribute1           DATETIME,
   protectedDateAttribute2           DATETIME,
   protectedDateAttribute3           DATETIME,
   protectedDateAttribute4           DATETIME,
   protectedDateAttribute5           DATETIME,
   protectedNumberAttribute1         INT,
   protectedNumberAttribute2         INT,
   protectedNumberAttribute3         INT,
   protectedNumberAttribute4         INT,
   protectedNumberAttribute5         INT,
   title                             VARCHAR(500),
   titleResourceKey                  VARCHAR(100),
   identificationKey                 VARCHAR(100),
   userComment                       VARCHAR(2000),
   workflowDescriptorURI             VARCHAR(200),
   taskDefinitionId                  VARCHAR(100),
   taskDefinitionName                VARCHAR(100)
);

create index WFTaskAcquiredBy_I on WFTask(acquiredBy);
create index WFTaskCreator_I on WFTask(creator);
create index WFTaskOwnerUser_I on WFTask(ownerUser);
create index WFTaskOwnerGroup_I on WFTask(ownerGroup);
create index WFTaskDomainId_I on WFTask(domainId);
create index WFTaskInstanceId_I on WFTask(instanceId);
create index WFTaskNumber_I on WFTask(taskNumber);
create index WFTaskUpdatedBy_I on WFTask(updatedBy);
create index WFTaskState_I on WFTask(state);
create index WFTaskIdentificationKey_I on WFTask(identificationKey);
create index WFTaskOAssigneeUser_I on WFTask(originalAssigneeUser);
create index WFTaskTaskGroupId_I on WFTask(taskGroupId);
create index WFTaskWorkflowPattern_I on WFTask(workflowPattern);



CREATE TABLE WFTaskHistory ( acquiredBy     VARCHAR(300),
   assigneeGroups                    VARCHAR(2000),
   assigneeGroupsDisplayName         VARCHAR(2000),
   assigneeUsers                     VARCHAR(2000),
   assigneeUsersDisplayName          VARCHAR(2000),
   callbackContext                   VARCHAR(2000),
   callbackId                        VARCHAR(2000),
   callbackType                      VARCHAR(20),
   creator                           VARCHAR(300),
   digitalSignatureRequired          VARCHAR(1),
   expirationDate                    DATETIME,
   expirationDuration                VARCHAR(64),
   identityContext                   VARCHAR(200),
   ownerUser                         VARCHAR(300),
   ownerGroup                        VARCHAR(300),
   passwordRequiredOnUpdate          VARCHAR(1),
   priority                          INT,
   domainId                          VARCHAR(100),
   instanceId                        VARCHAR(200),
   processId                         VARCHAR(100),
   processName                       VARCHAR(100),
   processType                       VARCHAR(10),
   processVersion                    VARCHAR(100),
   secureNotifications               VARCHAR(1),
   accessKey                         VARCHAR(80),
   approvalDuration                  INT,
   approvers                         VARCHAR(2000),
   assignedDate                      DATETIME,
   createdDate                       DATETIME,
   elapsedTime                       INT,
   endDate                           DATETIME,
   fromUser                          VARCHAR(100),
   fromUserDisplayName               VARCHAR(200),
   hasSubtask                        VARCHAR(1),
   inShortHistory                    VARCHAR(1),
   isGroup                           VARCHAR(1),
   language                          VARCHAR(4),
   mailStatus                        VARCHAR(8),
   numberOfTimesModified             INT,
   originalAssigneeUser              VARCHAR(100),
   outcome                           VARCHAR(100),
   parallelOutcomeCount              VARCHAR(300),
   pushbackSequence                  VARCHAR(200),
   State                             VARCHAR(100),
   SubState                          VARCHAR(200),
   systemString1                     VARCHAR(200),
   systemString2                     VARCHAR(200),
   SystemString3                     VARCHAR(200),
   taskGroupId                       VARCHAR(64),
   taskId                            VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   taskNumber                        INT,
   updatedBy                         VARCHAR(64),
   updatedByDisplayName              VARCHAR(200),
   updatedDate                       DATETIME,
   version                           INT,
   versionReason                     VARCHAR(2000),
   workflowPattern                   VARCHAR(2000),
   textAttribute1                    VARCHAR(2000),
   textAttribute2                    VARCHAR(2000),
   textAttribute3                    VARCHAR(2000),
   textAttribute4                    VARCHAR(2000),
   textAttribute5                    VARCHAR(2000),
   textAttribute6                    VARCHAR(2000),
   textAttribute7                    VARCHAR(2000),
   textAttribute8                    VARCHAR(2000),
   textAttribute9                    VARCHAR(2000),
   textAttribute10                   VARCHAR(2000),
   formAttribute1                    VARCHAR(2000),
   formAttribute2                    VARCHAR(2000),
   formAttribute3                    VARCHAR(2000),
   formAttribute4                    VARCHAR(2000),
   formAttribute5                    VARCHAR(2000),
   urlAttribute1                     VARCHAR(200),
   urlAttribute2                     VARCHAR(200),
   urlAttribute3                     VARCHAR(200),
   urlAttribute4                     VARCHAR(200),
   urlAttribute5                     VARCHAR(200),
   dateAttribute1                    DATETIME,
   dateAttribute2                    DATETIME,
   dateAttribute3                    DATETIME,
   dateAttribute4                    DATETIME,
   dateAttribute5                    DATETIME,
   numberAttribute1                  INT,
   numberAttribute2                  INT,
   numberAttribute3                  INT,
   numberAttribute4                  INT,
   numberAttribute5                  INT,
   protectedTextAttribute1           VARCHAR(2000),
   protectedTextAttribute2           VARCHAR(2000),
   protectedTextAttribute3           VARCHAR(2000),
   protectedTextAttribute4           VARCHAR(2000),
   protectedTextAttribute5           VARCHAR(2000),
   protectedTextAttribute6           VARCHAR(2000),
   protectedTextAttribute7           VARCHAR(2000),
   protectedTextAttribute8           VARCHAR(2000),
   protectedTextAttribute9           VARCHAR(2000),
   protectedTextAttribute10          VARCHAR(2000),
   protectedFormAttribute1           VARCHAR(2000),
   protectedFormAttribute2           VARCHAR(2000),
   protectedFormAttribute3           VARCHAR(2000),
   protectedFormAttribute4           VARCHAR(2000),
   protectedFormAttribute5           VARCHAR(2000),
   protectedUrlAttribute1            VARCHAR(200),
   protectedUrlAttribute2            VARCHAR(200),
   protectedUrlAttribute3            VARCHAR(200),
   protectedUrlAttribute4            VARCHAR(200),
   protectedUrlAttribute5            VARCHAR(200),
   protectedDateAttribute1           DATETIME,
   protectedDateAttribute2           DATETIME,
   protectedDateAttribute3           DATETIME,
   protectedDateAttribute4           DATETIME,
   protectedDateAttribute5           DATETIME,
   protectedNumberAttribute1         INT,
   protectedNumberAttribute2         INT,
   protectedNumberAttribute3         INT,
   protectedNumberAttribute4         INT,
   protectedNumberAttribute5         INT,
   title                             VARCHAR(500),
   titleResourceKey                  VARCHAR(100),
   identificationKey                 VARCHAR(100),
   userComment                       VARCHAR(2000),
   workflowDescriptorURI             VARCHAR(200),
   taskDefinitionId                  VARCHAR(100),
   taskDefinitionName                VARCHAR(100),
   PRIMARY KEY (taskId, version)
);

create index WFTaskHAcquiredBy_I on WFTaskHistory(acquiredBy);
create index WFTaskHCreator_I on WFTaskHistory(creator);
create index WFTaskHOwnerUser_I on WFTaskHistory(ownerUser);
create index WFTaskHOwnerGroup_I on WFTaskHistory(ownerGroup);
create index WFTaskHInstanceId_I on WFTaskHistory(instanceId);
create index WFTaskHNumber_I on WFTaskHistory(taskNumber);
create index WFTaskHUpdatedBy_I on WFTaskHistory(updatedBy);
create index WFTaskHOAssigneeUser_I on WFTaskHistory(originalAssigneeUser);
create index WFTaskHIdentificationKey_I on WFTaskHistory(identificationKey);



CREATE TABLE WFComments
(
  taskId                            VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
  version                           INT,
  updatedBy                         VARCHAR(64),
  updatedByDisplayName              VARCHAR(200),
  commentDate                       DATETIME,
  action                            VARCHAR(30),
  wfcomment                         VARCHAR(2000),
  displayNameLanguage               VARCHAR(4)
);


create index WFCommentsUpdatedBy_I on WFComments(updatedBy);
create index WFCommentsTaskId_I on WFComments(taskId,version);

/**
   Stores message attribute of the payload
 */
CREATE TABLE WFMessageAttribute
(  
  taskId                           VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
  name                             VARCHAR(100),
  version                          INT,
  maxVersion                       INT,
  storageType                      INTEGER,
  encoding                         VARCHAR(50),
  stringValue                      VARCHAR(2000),
  numberValue                      INT,
  dateValue                        DATETIME,
  blobValue                        IMAGE,  
  elementSeq                       INT
);

create index WFMessageAttributeTaskId_I on WFMessageAttribute(taskId,version);
create index WFMessageAttributeTaskName_I on WFMessageAttribute(taskId,name);


/**
 * TaskAttachment table contains all the attachments.
 */
CREATE TABLE WFAttachment 
(
   taskId                            VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   version                           INT,
   maxVersion                        INT,
   updatedBy                         VARCHAR(64),
   updatedByDisplayName              VARCHAR(200),
   updatedDate                       DATETIME,
   encoding                          VARCHAR(100),
   uri                               VARCHAR(256),
   content                           IMAGE,
   name                              VARCHAR(128),
   PRIMARY KEY (TaskId,Version,Name,UpdatedBy)
);

create index WFAttachmentTaskId_I on WFAttachment(taskId,version);
create index WFAttachmentTaskIdName_I on WFAttachment(taskId,version,name);


CREATE TABLE WFAssignee 
(
   taskID                     VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   version                    INT,
   assignee                   VARCHAR(200),
   guid                       VARCHAR(64),
   isGroup                    VARCHAR(2) CONSTRAINT WFASSIGNEE_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
   PRIMARY KEY (TaskID, Version,Assignee)
);

create index WFAssigneeAssignee_I on WFAssignee(assignee);
create index WFAssigneeTaskId_I on WFAssignee(taskID);
create index WFAssigneeCompositeId_I on WFAssignee(taskID,isGroup,assignee);


/*
CREATE TABLE WFAssigneeHistory 
(
   taskID                     VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   version                    INT,
   maxVersion                 INT,
   assignee                   VARCHAR(200),
   guid                       VARCHAR(64),
   identityContext            VARCHAR(200),
   isGroup                    VARCHAR(2) 
                               CONSTRAINT WFASSIGNEEHISTORY_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
   PRIMARY KEY (TaskID, Version,Assignee )
);
*/


CREATE TABLE WFRoutingSlip
(
  taskId                           VARCHAR(64) PRIMARY KEY,
  taskNumber                       INT,
  routingSlip                      IMAGE,
  noOfTimesModified                INT
);

/**
   Store workflow notifications of the task.
 */

CREATE TABLE WFNotification
(
  notificationId                   VARCHAR(64) PRIMARY KEY,
  taskId                           VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
  version                          INT,
  taskNumber                       INT,
  recipientUsers                   VARCHAR(1000),
  recipientGroups                  VARCHAR(1000),
  identityContext                  VARCHAR(200),
  domain                           VARCHAR(200),
  action                           VARCHAR(20),
  status                           VARCHAR(20),
  channel                          VARCHAR(20),
  noOfNotification                 INT
);

create index WFNotificationId_I on WFNotification(taskId);

/**
   Store worklfow notification channel status of the user/group
 */
CREATE TABLE WFNotificationStatus
(
  recipientUser                  VARCHAR(100),
  recipientGroup                 VARCHAR(100),
  identityContext                VARCHAR(200),
  domain                         VARCHAR(200),
  status                         VARCHAR(20),
  channelAddress                 VARCHAR(500),
  channel                        VARCHAR(20)
);



CREATE TABLE WFAttributeLabelMap
(
    id                       VARCHAR(64) primary key,
    taskAttribute            VARCHAR(100),
    labelName                VARCHAR(30),                      
    createdDate              DATETIME,
    active                   VARCHAR(1),
    workflowType             VARCHAR(30),
    dataType                 VARCHAR(10),
    CONSTRAINT wfattributemap_uk UNIQUE (taskAttribute,labelName)
);

CREATE TABLE WFAttributeLabelUsage
(
    mapId          VARCHAR(64) REFERENCES WFAttributeLabelMap(id)ON DELETE CASCADE,
    workflowId     VARCHAR(200),
    workflowName   VARCHAR(60),
    attributeName  VARCHAR(64),
    createdDate    DATETIME,
    CONSTRAINT wfattributeusage_uk UNIQUE (mapId,workflowId,attributeName)
);

/*CREATE SEQUENCE WFTaskSeq START WITH 10000 INCREMENT BY 1; -- This was used in Oracle database*/

create table WF_TASKSEQUENCE (seqnumber INT);
insert into WF_TASKSEQUENCE values(10000);
go

create procedure get_WF_TaskSequence_NextVal
as
begin
      declare @NewWFTaskSeqVal int

      set NOCOUNT ON

      update WF_TASKSEQUENCE

      set @NewWFTaskSeqVal = seqnumber = seqnumber+1      

      if @@rowcount = 0 begin
      	print 'Sequence does not exist'
      	return
      end
      return @NewWFTaskSeqVal
end
go

CREATE TABLE WFUserVacation
(
        userId                  VARCHAR(200),
        identityContext         VARCHAR(200),
        startDate               DATETIME,
        endDate                 DATETIME,
        PRIMARY KEY (userId,identityContext)
);

CREATE TABLE WFUserTaskView
(
    viewName         VARCHAR(100),
    viewId           VARCHAR(64) PRIMARY KEY,
    viewType         VARCHAR(15),
    viewOwner        VARCHAR(200),
    identityContext  VARCHAR(200),
    hidden           VARCHAR(1),
    description      VARCHAR(1000),
    definition       IMAGE
);


CREATE UNIQUE INDEX WFUserTaskView_UIdx 
    ON WFUserTaskView(viewOwner,identityContext,viewName);

CREATE TABLE WFUserTaskViewGrant
(
    viewId           VARCHAR(64) REFERENCES WFUserTaskView(viewId) ON DELETE CASCADE,
    grantee          VARCHAR(200),
    identityContext  VARCHAR(200),
    grantedName      VARCHAR(100),
    grantedDesc      VARCHAR(1000),
    hidden           VARCHAR(1),
    grantType        VARCHAR(20),
    /*
     AS11 Changes start
    */
    granteeType        VARCHAR2(20),
    applicationContext VARCHAR2(200),
    PRIMARY KEY (grantee,identityContext,viewId)
);

create index WFUserTaskViewGrantId on WFUserTaskViewGrant(viewId);

CREATE UNIQUE INDEX WFUserTaskViewGrant_UIdx 
    ON WFUserTaskViewGrant(grantee,identityContext,grantedName);


CREATE TABLE WFUserPreference
(
   userName        VARCHAR(200),
   identityContext VARCHAR(200),
   preferenceName  VARCHAR(100),
   preferenceValue VARCHAR(200),
   PRIMARY KEY (userName,identityContext,preferenceName)
);

CREATE TABLE WFTaskMetadata
(
      id              VARCHAR(200) PRIMARY KEY,
      uri             VARCHAR(2000) ,
      name            VARCHAR(200),
      title           VARCHAR(2000),
      description     VARCHAR(2000),
      domainId        VARCHAR(100),
      processName     VARCHAR(100),
      processId       VARCHAR(100),
      processVersion  VARCHAR(100)
);

CREATE TABLE WFTaskDisplay
(
      wfTaskMetadataId     VARCHAR(200) REFERENCES WFTaskMetadata(id) ON DELETE CASCADE ,
      uri                  VARCHAR(200),
      applicationName      VARCHAR(20)
);

create index WFTaskDisplayMid_I on WFTaskDisplay(wfTaskMetadataId);

CREATE TABLE WFTaskTimer
(
      id                   VARCHAR(300) PRIMARY KEY,
      taskId               VARCHAR(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
      jobName              VARCHAR(30),
      jobDate              DATETIME,
      key                  VARCHAR(100)
);

create index WFTaskTimerTaskId_I on WFTaskTimer(taskId);

CREATE TABLE WFNotificationMessages
(
   taskId VARCHAR(200),
   taskVersion  INT,
   action  VARCHAR(100),
   status  VARCHAR(100),
   primary key(taskId,taskVersion)
);

CREATE TABLE WFRuleDictionaryNOTM
(
  dictionaryName VARCHAR(200),
  dictionaryVersion VARCHAR(200),
  numberOfTimesModified INT,
  primary key (dictionaryName, dictionaryVersion)
);

go

/*
* Productivity report view
*/
create view WFProductivity_view as
      select taskname, taskid, tasknumber, username, state, lastupdateddate from
      (
select w.taskdefinitionname taskname, w.taskid taskid, w.tasknumber tasknumber,  a.assignee username, w.state state, w.updateddate lastupdateddate
from wftask w, wfassignee a
where
      w.state = 'ASSIGNED' and
      a.taskid = w.taskid
UNION select h.taskdefinitionname taskname, h.taskid taskid, h.tasknumber tasknumber, h.updatedby username, 
		CASE h.state 
				WHEN 'OUTCOME_UPDATED' THEN 'COMPLETED' 
				ELSE h.state 
		END state , h.updateddate lastupdateddate 
from wftaskhistory h
where 
      h.state = 'OUTCOME_UPDATED' 
UNION
select w.taskid taskid, w.taskdefinitionname taskname, w.tasknumber tasknumber, a.assignee username, w.state state, w.updateddate lastupdateddate
from wftask w, wfassignee a
where
      w.state != 'ASSIGNED' and w.state != 'OUTCOME_UPDATED' and w.state IS NULL and
      a.taskid = w.taskid 
      ) alias1;
      
go      

/*
* UnattendedTasks report view
*/
create view WFUnattendedtasks_view as
      select taskid, taskname, tasknumber, createddate, expirationdate, state, priority, assigneegroups from
      (
          select w.taskid taskid, w.taskdefinitionname taskname, w.tasknumber tasknumber, w.createddate createddate, w.expirationdate expirationdate, w.state state, w.priority priority, w.assigneegroups assigneegroups
          from wftask w
          where
                w.isGroup = 'T' and w.acquiredby IS NULL and 
                w.state in ('ASSIGNED','EXPIRED','INFO_REQUESTED') 
      ) alias1;
      
go      

/*
* Task Cycle Time  report view
*/
create view WFTaskcycletime_view as
      select taskid, taskname, tasknumber, createddate, enddate, cycletime  from
      (
          select taskid, taskdefinitionname taskname, tasknumber, createddate, enddate, (enddate - createddate) cycletime
          from wftask w
          where w.state IS NULL 
      ) alias1;
      
go      

/*
* Task Priority report view
*/
create view WFTaskpriority_view as
 select taskid, taskdefinitionname taskname, tasknumber, priority, outcome, assigneddate, updateddate, updatedby from wftask;
 
go 
