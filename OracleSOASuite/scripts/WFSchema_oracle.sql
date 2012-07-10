/**
Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/WFSchema_oracle.sql /st_pcbpel_10.1.3.1/12 2010/05/20 11:27:07 wstallar Exp $
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
Rem    rarangas    08/23/08 - Backport rarangas_blr_backport_6510734_10.1.3.3.1
Rem                           from st_pcbpel_10.1.3.1
Rem    wstallar    09/24/07 - Backport wstallar_bug-5971534 from main
Rem    vumapath    03/02/07 - BUG 5862802 - HWF: REGRESSION: DATABASE VIEWS NOT
Rem                           SUPPORTED FOR REPORTING DATA
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


DROP SEQUENCE WFTaskSeq;

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

CREATE TABLE WFTask ( acquiredBy     VARCHAR2(300),
   assigneeGroups                    VARCHAR2(2000),
   assigneeGroupsDisplayName         VARCHAR2(2000),
   assigneeUsers                     VARCHAR2(2000),
   assigneeUsersDisplayName          VARCHAR2(2000),
   callbackContext                   VARCHAR2(2000),
   callbackId                        VARCHAR2(2000),
   callbackType                      VARCHAR2(20),
   creator                           VARCHAR2(300),
   digitalSignatureRequired          VARCHAR2(1),
   expirationDate                    DATE,
   expirationDuration                VARCHAR2(64),
   identityContext                   VARCHAR2(200),
   ownerUser                         VARCHAR2(300),
   ownerGroup                        VARCHAR2(300),
   passwordRequiredOnUpdate          VARCHAR2(1),
   priority                          NUMBER,
   domainId                          VARCHAR2(100),
   instanceId                        VARCHAR2(200),
   processId                         VARCHAR2(100),
   processName                       VARCHAR2(100),
   processType                       VARCHAR2(10),
   processVersion                    VARCHAR2(100),
   secureNotifications               VARCHAR2(1),
   accessKey                         VARCHAR2(80),
   approvalDuration                  NUMBER,
   approvers                         VARCHAR2(2000),
   assignedDate                      DATE,
   createdDate                       DATE,
   elapsedTime                       NUMBER,
   endDate                           DATE,
   fromUser                          VARCHAR2(100),
   fromUserDisplayName               VARCHAR2(200),
   hasSubtask                        VARCHAR2(1),
   inShortHistory                    VARCHAR2(1),
   isGroup                           VARCHAR2(1),
   language                          VARCHAR2(4),
   mailStatus                        VARCHAR2(8),
   numberOfTimesModified             NUMBER,
   originalAssigneeUser              VARCHAR2(100),
   outcome                           VARCHAR2(100),
   parallelOutcomeCount              VARCHAR2(300),
   pushbackSequence                  VARCHAR2(200),
   State                             VARCHAR2(100),
   SubState                          VARCHAR2(200),
   systemString1                     VARCHAR2(200),
   systemString2                     VARCHAR2(200),
   SystemString3                     VARCHAR2(200),
   taskGroupId                       VARCHAR2(64),
   taskId                            VARCHAR2(64) PRIMARY KEY,
   taskNumber                        NUMBER,
   updatedBy                         VARCHAR2(64),
   updatedByDisplayName              VARCHAR2(200),
   updatedDate                       DATE,
   version                           NUMBER,
   versionReason                     VARCHAR2(2000),
   workflowPattern                   VARCHAR2(2000),
   textAttribute1                    VARCHAR2(2000),
   textAttribute2                    VARCHAR2(2000),
   textAttribute3                    VARCHAR2(2000),
   textAttribute4                    VARCHAR2(2000),
   textAttribute5                    VARCHAR2(2000),
   textAttribute6                    VARCHAR2(2000),
   textAttribute7                    VARCHAR2(2000),
   textAttribute8                    VARCHAR2(2000),
   textAttribute9                    VARCHAR2(2000),
   textAttribute10                   VARCHAR2(2000),
   formAttribute1                    VARCHAR2(2000),
   formAttribute2                    VARCHAR2(2000),
   formAttribute3                    VARCHAR2(2000),
   formAttribute4                    VARCHAR2(2000),
   formAttribute5                    VARCHAR2(2000),
   urlAttribute1                     VARCHAR2(200),
   urlAttribute2                     VARCHAR2(200),
   urlAttribute3                     VARCHAR2(200),
   urlAttribute4                     VARCHAR2(200),
   urlAttribute5                     VARCHAR2(200),
   dateAttribute1                    DATE,
   dateAttribute2                    DATE,
   dateAttribute3                    DATE,
   dateAttribute4                    DATE,
   dateAttribute5                    DATE,
   numberAttribute1                  NUMBER,
   numberAttribute2                  NUMBER,
   numberAttribute3                  NUMBER,
   numberAttribute4                  NUMBER,
   numberAttribute5                  NUMBER,
   protectedTextAttribute1           VARCHAR2(2000),
   protectedTextAttribute2           VARCHAR2(2000),
   protectedTextAttribute3           VARCHAR2(2000),
   protectedTextAttribute4           VARCHAR2(2000),
   protectedTextAttribute5           VARCHAR2(2000),
   protectedTextAttribute6           VARCHAR2(2000),
   protectedTextAttribute7           VARCHAR2(2000),
   protectedTextAttribute8           VARCHAR2(2000),
   protectedTextAttribute9           VARCHAR2(2000),
   protectedTextAttribute10          VARCHAR2(2000),
   protectedFormAttribute1           VARCHAR2(2000),
   protectedFormAttribute2           VARCHAR2(2000),
   protectedFormAttribute3           VARCHAR2(2000),
   protectedFormAttribute4           VARCHAR2(2000),
   protectedFormAttribute5           VARCHAR2(2000),
   protectedUrlAttribute1            VARCHAR2(200),
   protectedUrlAttribute2            VARCHAR2(200),
   protectedUrlAttribute3            VARCHAR2(200),
   protectedUrlAttribute4            VARCHAR2(200),
   protectedUrlAttribute5            VARCHAR2(200),
   protectedDateAttribute1           DATE,
   protectedDateAttribute2           DATE,
   protectedDateAttribute3           DATE,
   protectedDateAttribute4           DATE,
   protectedDateAttribute5           DATE,
   protectedNumberAttribute1         NUMBER,
   protectedNumberAttribute2         NUMBER,
   protectedNumberAttribute3         NUMBER,
   protectedNumberAttribute4         NUMBER,
   protectedNumberAttribute5         NUMBER,
   title                             VARCHAR2(500),
   titleResourceKey                  VARCHAR2(100),
   identificationKey                 VARCHAR2(100),
   userComment                       VARCHAR2(2000),
   workflowDescriptorURI             VARCHAR2(200),
   taskDefinitionId                  varchaR2(100),
   taskDefinitionName                VARCHAR2(100)
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



CREATE TABLE WFTaskHistory ( acquiredBy     VARCHAR2(300),
   assigneeGroups                    VARCHAR2(2000),
   assigneeGroupsDisplayName         VARCHAR2(2000),
   assigneeUsers                     VARCHAR2(2000),
   assigneeUsersDisplayName          VARCHAR2(2000),
   callbackContext                   VARCHAR2(2000),
   callbackId                        VARCHAR2(2000),
   callbackType                      VARCHAR2(20),
   creator                           VARCHAR2(300),
   digitalSignatureRequired          VARCHAR2(1),
   expirationDate                    DATE,
   expirationDuration                VARCHAR2(64),
   identityContext                   VARCHAR2(200),
   ownerUser                         VARCHAR2(300),
   ownerGroup                        VARCHAR2(300),
   passwordRequiredOnUpdate          VARCHAR2(1),
   priority                          NUMBER,
   domainId                          VARCHAR2(100),
   instanceId                        VARCHAR2(200),
   processId                         VARCHAR2(100),
   processName                       VARCHAR2(100),
   processType                       VARCHAR2(10),
   processVersion                    VARCHAR2(100),
   secureNotifications               VARCHAR2(1),
   accessKey                         VARCHAR2(80),
   approvalDuration                  NUMBER,
   approvers                         VARCHAR2(2000),
   assignedDate                      DATE,
   createdDate                       DATE,
   elapsedTime                       NUMBER,
   endDate                           DATE,
   fromUser                          VARCHAR2(100),
   fromUserDisplayName               VARCHAR2(200),
   hasSubtask                        VARCHAR2(1),
   inShortHistory                    VARCHAR2(1),
   isGroup                           VARCHAR2(1),
   language                          VARCHAR2(4),
   mailStatus                        VARCHAR2(8),
   numberOfTimesModified             NUMBER,
   originalAssigneeUser              VARCHAR2(100),
   outcome                           VARCHAR2(100),
   parallelOutcomeCount              VARCHAR2(300),
   pushbackSequence                  VARCHAR2(200),
   State                             VARCHAR2(100),
   SubState                          VARCHAR2(200),
   systemString1                     VARCHAR2(200),
   systemString2                     VARCHAR2(200),
   SystemString3                     VARCHAR2(200),
   taskGroupId                       VARCHAR2(64),
   taskId                            VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   taskNumber                        NUMBER,
   updatedBy                         VARCHAR2(64),
   updatedByDisplayName              VARCHAR2(200),
   updatedDate                       DATE,
   version                           NUMBER,
   versionReason                     VARCHAR2(2000),
   workflowPattern                   VARCHAR2(2000),
   textAttribute1                    VARCHAR2(2000),
   textAttribute2                    VARCHAR2(2000),
   textAttribute3                    VARCHAR2(2000),
   textAttribute4                    VARCHAR2(2000),
   textAttribute5                    VARCHAR2(2000),
   textAttribute6                    VARCHAR2(2000),
   textAttribute7                    VARCHAR2(2000),
   textAttribute8                    VARCHAR2(2000),
   textAttribute9                    VARCHAR2(2000),
   textAttribute10                   VARCHAR2(2000),
   formAttribute1                    VARCHAR2(2000),
   formAttribute2                    VARCHAR2(2000),
   formAttribute3                    VARCHAR2(2000),
   formAttribute4                    VARCHAR2(2000),
   formAttribute5                    VARCHAR2(2000),
   urlAttribute1                     VARCHAR2(200),
   urlAttribute2                     VARCHAR2(200),
   urlAttribute3                     VARCHAR2(200),
   urlAttribute4                     VARCHAR2(200),
   urlAttribute5                     VARCHAR2(200),
   dateAttribute1                    DATE,
   dateAttribute2                    DATE,
   dateAttribute3                    DATE,
   dateAttribute4                    DATE,
   dateAttribute5                    DATE,
   numberAttribute1                  NUMBER,
   numberAttribute2                  NUMBER,
   numberAttribute3                  NUMBER,
   numberAttribute4                  NUMBER,
   numberAttribute5                  NUMBER,
   protectedTextAttribute1           VARCHAR2(2000),
   protectedTextAttribute2           VARCHAR2(2000),
   protectedTextAttribute3           VARCHAR2(2000),
   protectedTextAttribute4           VARCHAR2(2000),
   protectedTextAttribute5           VARCHAR2(2000),
   protectedTextAttribute6           VARCHAR2(2000),
   protectedTextAttribute7           VARCHAR2(2000),
   protectedTextAttribute8           VARCHAR2(2000),
   protectedTextAttribute9           VARCHAR2(2000),
   protectedTextAttribute10          VARCHAR2(2000),
   protectedFormAttribute1           VARCHAR2(2000),
   protectedFormAttribute2           VARCHAR2(2000),
   protectedFormAttribute3           VARCHAR2(2000),
   protectedFormAttribute4           VARCHAR2(2000),
   protectedFormAttribute5           VARCHAR2(2000),
   protectedUrlAttribute1            VARCHAR2(200),
   protectedUrlAttribute2            VARCHAR2(200),
   protectedUrlAttribute3            VARCHAR2(200),
   protectedUrlAttribute4            VARCHAR2(200),
   protectedUrlAttribute5            VARCHAR2(200),
   protectedDateAttribute1           DATE,
   protectedDateAttribute2           DATE,
   protectedDateAttribute3           DATE,
   protectedDateAttribute4           DATE,
   protectedDateAttribute5           DATE,
   protectedNumberAttribute1         NUMBER,
   protectedNumberAttribute2         NUMBER,
   protectedNumberAttribute3         NUMBER,
   protectedNumberAttribute4         NUMBER,
   protectedNumberAttribute5         NUMBER,
   title                             VARCHAR2(500),
   titleResourceKey                  VARCHAR2(100),
   identificationKey                 VARCHAR2(100),
   userComment                       VARCHAR2(2000),
   workflowDescriptorURI             VARCHAR2(200),
   taskDefinitionId                  VARCHAR2(100),
   taskDefinitionName                VARCHAR2(100),
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
  taskId                            VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
  version                           NUMBER,
  updatedBy                         VARCHAR2(64),
  updatedByDisplayName              VARCHAR2(200),
  commentDate                       DATE,
  action                            VARCHAR2(30),
  wfcomment                         VARCHAR2(2000),
  displayNameLanguage               VARCHAR2(4)
);


create index WFCommentsUpdatedBy_I on WFComments(updatedBy);
create index WFCommentsTaskId_I on WFComments(taskId,version);

/**
   Stores message attribute of the payload
 */
CREATE TABLE WFMessageAttribute
(  
  taskId                           VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
  name                             VARCHAR2(100),
  version                          NUMBER,
  maxVersion                       NUMBER,
  storageType                      INTEGER,
  encoding                         VARCHAR2(50),
  stringValue                      VARCHAR2(2000),
  numberValue                      NUMBER,
  dateValue                        DATE,
  blobValue                        BLOB,  
  elementSeq                       NUMBER
);

create index WFMessageAttributeTaskId_I on WFMessageAttribute(taskId,version);
create index WFMessageAttributeTaskName_I on WFMessageAttribute(taskId,name);


/**
 * TaskAttachment table contains all the attachments.
 */
CREATE TABLE WFAttachment 
(
   taskId                            VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   version                           NUMBER,
   maxVersion                        NUMBER,
   updatedBy                         VARCHAR2(64),
   updatedByDisplayName              VARCHAR2(200),
   updatedDate                       DATE,
   encoding                          VARCHAR2(100),
   uri                               VARCHAR2(256),
   content                           BLOB,
   name                              VARCHAR2(128),
   PRIMARY KEY (TaskId,Version,Name,UpdatedBy)
);

create index WFAttachmentTaskId_I on WFAttachment(taskId,version);
create index WFAttachmentTaskIdName_I on WFAttachment(taskId,version,name);


CREATE TABLE WFAssignee 
(
   taskID                     VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   version                    NUMBER,
   assignee                   VARCHAR2(200),
   guid                       VARCHAR2(64),
   isGroup                    VARCHAR2(2) CONSTRAINT WFASSIGNEE_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
   PRIMARY KEY (TaskID, Version,Assignee)
);

create index WFAssigneeAssignee_I on WFAssignee(assignee);
create index WFAssigneeTaskId_I on WFAssignee(taskID);
create index WFAssigneeCompositeId_I on WFAssignee(taskID,isGroup,assignee);


/*
CREATE TABLE WFAssigneeHistory 
(
   taskID                     VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
   version                    NUMBER,
   maxVersion                 NUMBER,
   assignee                   VARCHAR2(200),
   guid                       VARCHAR2(64),
   identityContext            VARCHAR2(200),
   isGroup                    VARCHAR2(2) 
                               CONSTRAINT WFASSIGNEEHISTORY_ISGROUP_CK CHECK
                                         ( IsGroup IN('T','F')),
   PRIMARY KEY (TaskID, Version,Assignee )
);
*/


CREATE TABLE WFRoutingSlip
(
  taskId                           VARCHAR2(64) PRIMARY KEY REFERENCES WFTask(taskId) ON DELETE CASCADE,
  taskNumber                       NUMBER,
  routingSlip                      BLOB,
  noOfTimesModified                NUMBER
);

/**
   Store workflow notifications of the task.
 */

CREATE TABLE WFNotification
(
  notificationId                   VARCHAR2(64) PRIMARY KEY,
  taskId                           VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
  version                          NUMBER,
  taskNumber                       NUMBER,
  recipientUsers                   VARCHAR2(1000),
  recipientGroups                  VARCHAR2(1000),
  identityContext                  VARCHAR2(200),
  domain                           VARCHAR2(200),
  action                           VARCHAR2(20),
  status                           VARCHAR2(20),
  channel                          VARCHAR2(20),
  noOfNotification                 NUMBER
);

create index WFNotificationId_I on WFNotification(taskId);

/**
   Store worklfow notification channel status of the user/group
 */
CREATE TABLE WFNotificationStatus
(
  recipientUser                  VARCHAR2(100),
  recipientGroup                 VARCHAR2(100),
  identityContext                VARCHAR2(200),
  domain                         VARCHAR2(200),
  status                         VARCHAR2(20),
  channelAddress                 VARCHAR2(500),
  channel                        VARCHAR2(20)
);



CREATE TABLE WFAttributeLabelMap
(
    id                       VARCHAR2(64) primary key,
    taskAttribute            VARCHAR2(100),
    labelName                VARCHAR2(30),                      
    createdDate              DATE,
    active                   VARCHAR2(1),
    workflowType             VARCHAR2(30),
    dataType                 VARCHAR2(10),
    CONSTRAINT wfattributemap_uk UNIQUE (taskAttribute,labelName)
);

CREATE TABLE WFAttributeLabelUsage
(
    mapId          VARCHAR2(64) REFERENCES WFAttributeLabelMap(id)ON DELETE CASCADE,
    workflowId     VARCHAR2(200),
    workflowName   VARCHAR2(60),
    attributeName  VARCHAR2(64),
    createdDate    DATE,
    CONSTRAINT wfattributeusage_uk UNIQUE (mapId,workflowId,attributeName)
);

CREATE SEQUENCE WFTaskSeq START WITH 10000 INCREMENT BY 1;

CREATE TABLE WFUserVacation
(
        userId                  VARCHAR2(200),
        identityContext         VARCHAR2(200),
        startDate               DATE,
        endDate                 DATE,
        PRIMARY KEY (userId,identityContext)
);

CREATE TABLE WFUserTaskView
(
    viewName         VARCHAR2(100),
    viewId           VARCHAR2(64) PRIMARY KEY,
    viewType         VARCHAR2(15),
    viewOwner        VARCHAR2(200),
    identityContext  VARCHAR2(200),
    hidden           VARCHAR2(1),
    description      VARCHAR2(1000),
    definition       BLOB
);


CREATE UNIQUE INDEX WFUserTaskView_UIdx 
    ON WFUserTaskView(viewOwner,identityContext,viewName);

CREATE TABLE WFUserTaskViewGrant
(
    viewId             VARCHAR2(64) REFERENCES WFUserTaskView(viewId) ON DELETE CASCADE,
    grantee            VARCHAR2(200),
    identityContext    VARCHAR2(200),
    grantedName        VARCHAR2(100),
    grantedDesc        VARCHAR2(1000),
    hidden             VARCHAR2(1),
    grantType          VARCHAR2(20),
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
   userName        VARCHAR2(200),
   identityContext VARCHAR2(200),
   preferenceName  VARCHAR2(100),
   preferenceValue VARCHAR2(200),
   PRIMARY KEY (userName,identityContext,preferenceName)
);

CREATE TABLE WFTaskMetadata
(
      id              VARCHAR2(200) PRIMARY KEY,
      uri             VARCHAR2(2000) ,
      name            VARCHAR2(200),
      title           VARCHAR2(2000),
      description     VARCHAR2(2000),
      domainId        VARCHAR2(100),
      processName     VARCHAR2(100),
      processId       VARCHAR2(100),
      processVersion  VARCHAR2(100)
);

CREATE TABLE WFTaskDisplay
(
      wfTaskMetadataId     VARCHAR2(200) REFERENCES WFTaskMetadata(id) ON DELETE CASCADE ,
      uri                  VARCHAR2(200),
      applicationName      VARCHAR2(20)
);

create index WFTaskDisplayMid_I on WFTaskDisplay(wfTaskMetadataId);

CREATE TABLE WFTaskTimer
(
      id                   VARCHAR2(300) PRIMARY KEY,
      taskId               VARCHAR2(64) REFERENCES WFTask(taskId) ON DELETE CASCADE,
      jobName              VARCHAR2(30),
      jobDate              DATE,
      key                  VARCHAR(100)
);

create index WFTaskTimerTaskId_I on WFTaskTimer(taskId);

CREATE TABLE WFNotificationMessages
(
   taskId VARCHAR2(200),
   taskVersion  NUMBER,
   action  VARCHAR2(100),
   status  VARCHAR2(100),
   primary key(taskId,taskVersion)
);

CREATE TABLE WFRuleDictionaryNOTM
(
  dictionaryName VARCHAR2(200),
  dictionaryVersion VARCHAR2(200),
  numberOfTimesModified NUMBER,
  primary key (dictionaryName, dictionaryVersion)
);

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
UNION select h.taskdefinitionname taskname, h.taskid taskid, h.tasknumber tasknumber, h.updatedby username, decode(h.state , 'OUTCOME_UPDATED', 'COMPLETED', h.state) state, h.updateddate lastupdateddate 
from wftaskhistory h
where 
      h.state = 'OUTCOME_UPDATED' 
UNION
select w.taskid taskid, w.taskdefinitionname taskname, w.tasknumber tasknumber, a.assignee username, w.state state, w.updateddate lastupdateddate
from wftask w, wfassignee a
where
      w.state != 'ASSIGNED' and w.state != 'OUTCOME_UPDATED' and w.state IS NULL and
      a.taskid = w.taskid 
      );

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
      );

/*
* Task Cycle Time  report view
*/
create view WFTaskcycletime_view as
      select taskid, taskname, tasknumber, createddate, enddate, cycletime  from
      (
          select taskid, taskdefinitionname taskname, tasknumber, createddate, enddate, (enddate - createddate) cycletime
          from wftask w
          where w.state IS NULL 
      );

/*
* Task Priority report view
*/
create view WFTaskpriority_view as
 select taskid, taskdefinitionname taskname, tasknumber, priority, outcome, assigneddate, updateddate, updatedby from wftask;
