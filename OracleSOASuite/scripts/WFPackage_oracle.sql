/**
Rem $Header: WFPackage_oracle.sql 20-jul-2006.14:41:02 ykuntawa Exp $
Rem
Rem WFPackage_oracle.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      WFPackage_oracle.sql -  Packages used by Workflow services
Rem
Rem    DESCRIPTION
Rem      Methods and procedures used by Human workflow services in 10.1.3
Rem
Rem    NOTES
Rem      This is a replacement for workflow_oracle.sql. 
Rem      This file was developed in a separate directory under
Rem      workflow and I moved it here (the final place). So, 
Rem      the history is retained
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ykuntawa    07/20/06 - XbranchMerge ykuntawa_bug-5395008 from main 
Rem    ykuntawa    07/19/06 - Add index hints 
Rem    rarangas    05/23/06 - 
Rem    ykuntawa    05/11/06 - Adding identificationKey 
Rem    ykuntawa    05/01/06 - Change message 
Rem    seraiah     02/09/06 - move REM and SET statements  inside comments. The install
                              scripts execute JDBC calls based on contents of this file 
                              and REM and SET are not recognized by JDBC
Rem    seraiah     01/26/06 - Fix for updateMessageAttribute to fix the
Rem                           version issue
Rem    ykuntawa    01/22/06 - Adding taskDefinitionURI
Rem    ykuntawa    01/06/06 - Adding sequence in MessageAttribute table
Rem    ykuntawa    12/19/05 - Change column names
Rem    ykuntawa    10/27/05 - Modifying schema
Rem    ykuntawa    08/04/05 - ykuntawa_workflow_persistency_as11_1
Rem    ykuntawa    07/29/05 - Created

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

*/

CREATE OR REPLACE PACKAGE WFTaskpkg AS
  
  BLOB_DATATYPE NUMBER := 7;
  BOOLEAN_FALSE_STRING VARCHAR2(1) := 'F';
  BOOLEAN_TRUE_STRING VARCHAR2(1) := 'T';
  FUNCTION insertRoutingSlip(
                             p_taskId  VARCHAR2,
                             p_taskNumber NUMBER
                            ) RETURN blob;
  
  
  FUNCTION updateRoutingSlip(
                              p_taskId  VARCHAR2,
                              p_notm NUMBER
                             ) RETURN blob;


  PROCEDURE insertTask(  
                               p_acquiredBy                  VARCHAR2,
                               p_assigneeGroups              VARCHAR2,
                               p_assigneeGroupsDisplayName   VARCHAR2,
                               p_assigneeUsers               VARCHAR2,
                               p_assigneeUsersDisplayName    VARCHAR2,
                               p_callbackContext             VARCHAR2,
                               p_callbackId                  VARCHAR2,
                               p_callbackType                VARCHAR2,
                               p_creator                     VARCHAR2,
                               p_digitalSignatureRequired    VARCHAR2,
                               p_expirationDate              DATE,
                               p_expirationDuration          VARCHAR2,
                               p_identityContext             VARCHAR2,
                               p_ownerUser                   VARCHAR2,
                               p_ownerGroup                   VARCHAR2,
                               p_passwordRequiredOnUpdate    VARCHAR2,
                               p_priority                    NUMBER,
                               p_domainId                    VARCHAR2,
                               p_instanceId                  VARCHAR2,
                               p_processId                   VARCHAR2,
                               p_processName                 VARCHAR2,
                               p_processType                 VARCHAR2,
                               p_processVersion              VARCHAR2,
                               p_secureNotifications         VARCHAR2,
                               p_accessKey                   VARCHAR2,
                               p_approvalDuration            NUMBER,
                               p_approvers                   VARCHAR2,
                               p_assignedDate                DATE,
                               p_createdDate                 DATE,
                               p_elapsedTime                 NUMBER,
                               p_endDate                     DATE,
                               p_fromUser                    VARCHAR2,
                               p_fromUserDisplayName         VARCHAR2,
                               p_hasSubtask                  VARCHAR2,
                               p_inShortHistory              VARCHAR2,
                               p_isGroup                     VARCHAR2,
                               p_language                    VARCHAR2,
                               p_mailStatus                  VARCHAR2,
                               p_numberOfTimesModified       NUMBER,
                               p_originalAssigneeUser        VARCHAR2,
                               p_outcome                     VARCHAR2,
                               p_parallelOutcomeCount        VARCHAR2,
                               p_pushbackSequence            VARCHAR2,
                               p_State                       VARCHAR2,
                               p_SubState                    VARCHAR2,
                               p_systemString1               VARCHAR2,
                               p_systemString2               VARCHAR2,
                               p_SystemString3               VARCHAR2,
                               p_taskGroupId                 VARCHAR2,
                               p_taskId                      VARCHAR2,
                               p_taskNumber      IN OUT      NUMBER,
                               p_updatedBy                   VARCHAR2,
                               p_updatedByDisplayName        VARCHAR2,
                               p_updatedDate                 DATE,
                               p_version                     NUMBER,
                               p_versionReason               VARCHAR2,
                               p_workflowPattern             VARCHAR2,
                               p_textAttribute1              VARCHAR2,
                               p_textAttribute2              VARCHAR2,
                               p_textAttribute3              VARCHAR2,
                               p_textAttribute4              VARCHAR2,
                               p_textAttribute5              VARCHAR2,
                               p_textAttribute6              VARCHAR2,
                               p_textAttribute7              VARCHAR2,
                               p_textAttribute8              VARCHAR2,
                               p_textAttribute9              VARCHAR2,
                               p_textAttribute10             VARCHAR2,
                               p_formAttribute1              VARCHAR2,
                               p_formAttribute2              VARCHAR2,
                               p_formAttribute3              VARCHAR2,
                               p_formAttribute4              VARCHAR2,
                               p_formAttribute5              VARCHAR2,
                               p_urlAttribute1               VARCHAR2,
                               p_urlAttribute2               VARCHAR2,
                               p_urlAttribute3               VARCHAR2,
                               p_urlAttribute4               VARCHAR2,
                               p_urlAttribute5               VARCHAR2,
                               p_dateAttribute1              DATE,
                               p_dateAttribute2              DATE,
                               p_dateAttribute3              DATE,
                               p_dateAttribute4              DATE,
                               p_dateAttribute5              DATE,
                               p_numberAttribute1            NUMBER,
                               p_numberAttribute2            NUMBER,
                               p_numberAttribute3            NUMBER,
                               p_numberAttribute4            NUMBER,
                               p_numberAttribute5            NUMBER,
                               p_protectedTextAttribute1     VARCHAR2,
                               p_protectedTextAttribute2     VARCHAR2,
                               p_protectedTextAttribute3     VARCHAR2,
                               p_protectedTextAttribute4     VARCHAR2,
                               p_protectedTextAttribute5     VARCHAR2,
                               p_protectedTextAttribute6     VARCHAR2,
                               p_protectedTextAttribute7     VARCHAR2,
                               p_protectedTextAttribute8     VARCHAR2,
                               p_protectedTextAttribute9     VARCHAR2,
                               p_protectedTextAttribute10    VARCHAR2,
                               p_protectedFormAttribute1     VARCHAR2,
                               p_protectedFormAttribute2     VARCHAR2,
                               p_protectedFormAttribute3     VARCHAR2,
                               p_protectedFormAttribute4     VARCHAR2,
                               p_protectedFormAttribute5     VARCHAR2,
                               p_protectedUrlAttribute1      VARCHAR2,
                               p_protectedUrlAttribute2      VARCHAR2,
                               p_protectedUrlAttribute3      VARCHAR2,
                               p_protectedUrlAttribute4      VARCHAR2,
                               p_protectedUrlAttribute5      VARCHAR2,
                               p_protectedDateAttribute1     DATE,
                               p_protectedDateAttribute2     DATE,
                               p_protectedDateAttribute3     DATE,
                               p_protectedDateAttribute4     DATE,
                               p_protectedDateAttribute5     DATE,
                               p_protectedNumberAttribute1   NUMBER,
                               p_protectedNumberAttribute2   NUMBER,
                               p_protectedNumberAttribute3   NUMBER,
                               p_protectedNumberAttribute4   NUMBER,
                               p_protectedNumberAttribute5   NUMBER,
                               p_title                       VARCHAR2,
                               p_titleResourceKey            VARCHAR2,
                               p_identificationKey            VARCHAR2,
                               p_workflowDescriptorURI       VARCHAR2,
                               p_taskDefinitionId                  VARCHAR2,
                               p_taskDefinitionName                VARCHAR2
                             );
      
      PROCEDURE updateTask(  
                               p_acquiredBy                  VARCHAR2,
                               p_assigneeGroups              VARCHAR2,
                               p_assigneeGroupsDisplayName   VARCHAR2,
                               p_assigneeUsers               VARCHAR2,
                               p_assigneeUsersDisplayName    VARCHAR2,
                               p_callbackContext             VARCHAR2,
                               p_callbackId                  VARCHAR2,
                               p_callbackType                VARCHAR2,
                               p_creator                     VARCHAR2,
                               p_digitalSignatureRequired    VARCHAR2,
                               p_expirationDate              DATE,
                               p_expirationDuration          VARCHAR2,
                               p_identityContext             VARCHAR2,
                               p_ownerUser                   VARCHAR2,
                               p_ownerGroup                   VARCHAR2,
                               p_passwordRequiredOnUpdate    VARCHAR2,
                               p_priority                    NUMBER,
                               p_domainId                    VARCHAR2,
                               p_instanceId                  VARCHAR2,
                               p_processId                   VARCHAR2,
                               p_processName                 VARCHAR2,
                               p_processType                 VARCHAR2,
                               p_processVersion              VARCHAR2,
                               p_secureNotifications         VARCHAR2,
                               p_accessKey                   VARCHAR2,
                               p_approvalDuration            NUMBER,
                               p_approvers                   VARCHAR2,
                               p_assignedDate                DATE,
                               p_createdDate                 DATE,
                               p_elapsedTime                 NUMBER,
                               p_endDate                     DATE,
                               p_fromUser                    VARCHAR2,
                               p_fromUserDisplayName         VARCHAR2,
                               p_hasSubtask                  VARCHAR2,
                               p_inShortHistory              VARCHAR2,
                               p_isGroup                     VARCHAR2,
                               p_language                    VARCHAR2,
                               p_mailStatus                  VARCHAR2,
                               p_numberOfTimesModified       NUMBER,
                               p_originalAssigneeUser        VARCHAR2,
                               p_outcome                     VARCHAR2,
                               p_parallelOutcomeCount        VARCHAR2,
                               p_pushbackSequence            VARCHAR2,
                               p_State                       VARCHAR2,
                               p_SubState                    VARCHAR2,
                               p_systemString1               VARCHAR2,
                               p_systemString2               VARCHAR2,
                               p_SystemString3               VARCHAR2,
                               p_taskGroupId                 VARCHAR2,
                               p_taskId                      VARCHAR2,
                               p_taskNumber                  NUMBER,
                               p_updatedBy                   VARCHAR2,
                               p_updatedByDisplayName        VARCHAR2,
                               p_updatedDate                 DATE,
                               p_version                     NUMBER,
                               p_versionReason               VARCHAR2,
                               p_workflowPattern             VARCHAR2,
                               p_textAttribute1              VARCHAR2,
                               p_textAttribute2              VARCHAR2,
                               p_textAttribute3              VARCHAR2,
                               p_textAttribute4              VARCHAR2,
                               p_textAttribute5              VARCHAR2,
                               p_textAttribute6              VARCHAR2,
                               p_textAttribute7              VARCHAR2,
                               p_textAttribute8              VARCHAR2,
                               p_textAttribute9              VARCHAR2,
                               p_textAttribute10             VARCHAR2,
                               p_formAttribute1              VARCHAR2,
                               p_formAttribute2              VARCHAR2,
                               p_formAttribute3              VARCHAR2,
                               p_formAttribute4              VARCHAR2,
                               p_formAttribute5              VARCHAR2,
                               p_urlAttribute1               VARCHAR2,
                               p_urlAttribute2               VARCHAR2,
                               p_urlAttribute3               VARCHAR2,
                               p_urlAttribute4               VARCHAR2,
                               p_urlAttribute5               VARCHAR2,
                               p_dateAttribute1              DATE,
                               p_dateAttribute2              DATE,
                               p_dateAttribute3              DATE,
                               p_dateAttribute4              DATE,
                               p_dateAttribute5              DATE,
                               p_numberAttribute1            NUMBER,
                               p_numberAttribute2            NUMBER,
                               p_numberAttribute3            NUMBER,
                               p_numberAttribute4            NUMBER,
                               p_numberAttribute5            NUMBER,
                               p_protectedTextAttribute1     VARCHAR2,
                               p_protectedTextAttribute2     VARCHAR2,
                               p_protectedTextAttribute3     VARCHAR2,
                               p_protectedTextAttribute4     VARCHAR2,
                               p_protectedTextAttribute5     VARCHAR2,
                               p_protectedTextAttribute6     VARCHAR2,
                               p_protectedTextAttribute7     VARCHAR2,
                               p_protectedTextAttribute8     VARCHAR2,
                               p_protectedTextAttribute9     VARCHAR2,
                               p_protectedTextAttribute10    VARCHAR2,
                               p_protectedFormAttribute1     VARCHAR2,
                               p_protectedFormAttribute2     VARCHAR2,
                               p_protectedFormAttribute3     VARCHAR2,
                               p_protectedFormAttribute4     VARCHAR2,
                               p_protectedFormAttribute5     VARCHAR2,
                               p_protectedUrlAttribute1      VARCHAR2,
                               p_protectedUrlAttribute2      VARCHAR2,
                               p_protectedUrlAttribute3      VARCHAR2,
                               p_protectedUrlAttribute4      VARCHAR2,
                               p_protectedUrlAttribute5      VARCHAR2,
                               p_protectedDateAttribute1     DATE,
                               p_protectedDateAttribute2     DATE,
                               p_protectedDateAttribute3     DATE,
                               p_protectedDateAttribute4     DATE,
                               p_protectedDateAttribute5     DATE,
                               p_protectedNumberAttribute1   NUMBER,
                               p_protectedNumberAttribute2   NUMBER,
                               p_protectedNumberAttribute3   NUMBER,
                               p_protectedNumberAttribute4   NUMBER,
                               p_protectedNumberAttribute5   NUMBER,
                               p_title                       VARCHAR2,
                               p_titleResourceKey            VARCHAR2,
                               p_identificationKey            VARCHAR2,
                               p_workflowDescriptorURI       VARCHAR2,
                               p_taskDefinitionId                  VARCHAR2,
                               p_taskDefinitionName                VARCHAR2,
                               p_IsVersionable               VARCHAR2
                             );           
      FUNCTION insertAttachment (
                                  p_taskID                VARCHAR,
                                  p_version               NUMBER,
                                  p_updatedBy             VARCHAR,
                                  p_updatedByDisplayName  VARCHAR,
                                  p_updatedDate           DATE,
                                  p_encoding              VARCHAR,
                                  p_uri                   VARCHAR,
                                  p_name                  VARCHAR
                                ) RETURN BLOB;
                                
      FUNCTION insertMessageAttribute (
                                        p_taskId        VARCHAR,
                                        p_version       NUMBER,
                                        p_name          VARCHAR,
                                        p_storageType   INTEGER,
                                        p_encoding      VARCHAR,
                                        p_stringValue   VARCHAR,
                                        p_numberValue   NUMBER,
                                        p_dateValue     DATE,
                                        p_elementSeq    NUMBER
                                      ) RETURN BLOB;
                                      
      FUNCTION updateMessageAttribute (
                                        p_taskId        VARCHAR,
                                        p_version       NUMBER,
                                        p_name          VARCHAR,
                                        p_storageType   INTEGER,
                                        p_encoding      VARCHAR,
                                        p_stringValue   VARCHAR,
                                        p_numberValue   NUMBER,
                                        p_dateValue     DATE,
                                        p_elementSeq    NUMBER
                                      ) RETURN BLOB;                       
                                
      PROCEDURE createWFTaskVersion(
                                  p_taskID   VARCHAR,
                                  p_version  NUMBER,
                                  p_notm     NUMBER,
                                  p_versionReason VARCHAR
                                );
     
END WFTaskpkg;
/


CREATE OR REPLACE PACKAGE BODY WFTaskpkg AS
  v_lockException EXCEPTION;
  v_lockErrorNumber NUMBER := -20001;
  PRAGMA EXCEPTION_INIT(v_lockException,-20001);
 
  v_updateErrorNumber NUMBER := -20002;
  v_insertErrorNumber NUMBER := -20003;
  
  v_deletedException EXCEPTION ;
  v_deletedErrorNumber NUMBER := -20004;
  PRAGMA EXCEPTION_INIT(v_deletedException,-20004);

  v_modifiedException EXCEPTION ;
  v_modifiedErrorNumber NUMBER := -20005;
  PRAGMA EXCEPTION_INIT(v_modifiedException,-20005);


  v_createHistoryException EXCEPTION;  
  v_createHistoryErrorNumber  NUMBER  := -20007;  
  PRAGMA EXCEPTION_INIT(v_createHistoryException,-20007);

  FUNCTION insertRoutingSlip(
                             p_taskId  VARCHAR2,
                             p_taskNumber NUMBER
                            ) RETURN BLOB IS
     v_blob  BLOB;
     v_taskNumber NUMBER;

  BEGIN 
     
     IF p_taskNumber <= 0 THEN
        SELECT /*+ INDEX(WFTask WFTask(taskId)) */ taskNumber INTO v_taskNumber 
                 FROM WFTask WHERE taskId = p_taskId;
     ELSE
       v_taskNumber := p_taskNumber ;
     END IF;

     INSERT INTO WFRoutingSlip 
          (taskId , taskNumber, routingSlip, noOfTimesModified )
        VALUES( p_taskId, v_taskNumber , empty_blob(), 1);

     SELECT /*+ INDEX(WFRoutingSlip WFRoutingSlip(taskId)) */ routingSlip INTO v_blob  
            FROM WFRoutingSlip WHERE taskId = p_taskId;
     return v_blob;
  EXCEPTION
     WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(v_insertErrorNumber,'Error while inserting routing slip',true);
   
  END  insertRoutingSlip; 

  
  FUNCTION updateRoutingSlip(
                              p_taskId  VARCHAR2,
                              p_notm NUMBER
                             ) RETURN BLOB IS
    v_notm NUMBER;
    v_blob  BLOB;
  BEGIN

    BEGIN
     SELECT /*+ INDEX(WFRoutingSlip WFRoutingSlip(taskId)) */ noOfTimesModified INTO v_notm 
           FROM WFRoutingSlip WHERE taskId = p_taskId FOR UPDATE NOWAIT;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN 
       RAISE v_deletedException;
     WHEN OTHERS THEN 
       RAISE v_lockException;
    END;

    BEGIN
       IF v_notm != p_notm THEN
         RAISE v_modifiedException;
       END IF;
    END;

    UPDATE /*+ INDEX(WFRoutingSlip WFRoutingSlip(taskId)) */ 
        WFRoutingSlip 
        SET noOfTimesModified = p_notm +1,
            routingSlip = empty_blob()
        WHERE taskId = p_taskId;

    SELECT /*+ INDEX(WFRoutingSlip WFRoutingSlip(taskId)) */ routingSlip INTO v_blob  
            FROM WFRoutingSlip WHERE taskId = p_taskId;
     return v_blob;

  EXCEPTION
    WHEN  v_lockException THEN
       RAISE_APPLICATION_ERROR(v_lockErrorNumber,'Task is locked for update',true);
    WHEN v_deletedException THEN
       RAISE_APPLICATION_ERROR(v_deletedErrorNumber,'Task is deleted',true);
    WHEN v_modifiedException THEN
       RAISE_APPLICATION_ERROR(v_modifiedErrorNumber,'Task is modified',true);
    WHEN OTHERS THEN 
       RAISE_APPLICATION_ERROR(v_updateErrorNumber,'Error while updating routing slip',true);
  END updateRoutingSlip;

  /**
     To lock the WFTask table
   */
   
  PROCEDURE lockWFTask(
                       p_taskId VARCHAR,
                       p_notm   NUMBER
                      ) IS
    v_notm NUMBER;
  BEGIN
     BEGIN
        SELECT /*+ INDEX(WFTask WFTask(taskId)) */ numberOfTimesModified INTO v_notm 
             FROM WFTask WHERE taskId = p_taskId FOR UPDATE NOWAIT;
     EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                  RAISE v_deletedException;
            WHEN OTHERS THEN 
                 RAISE v_lockException;
     END;
     IF v_notm != p_notm THEN
         RAISE v_modifiedException;
     END IF;
  END lockWFTask;
  

  PROCEDURE createHistory(p_taskID VARCHAR2) IS
  BEGIN
    INSERT INTO WFTaskHistory 
                             ( acquiredBy,
                               assigneeGroups,
                               assigneeGroupsDisplayName,
                               assigneeUsers,
                               assigneeUsersDisplayName,
                               callbackContext,
                               callbackId,
                               callbackType,
                               creator,
                               digitalSignatureRequired,
                               expirationDate,
                               expirationDuration,
                               identityContext,
                               ownerUser,
                               ownerGroup,
                               passwordRequiredOnUpdate,
                               priority,
                               domainId,
                               instanceId,
                               processId,
                               processName,
                               processType,
                               processVersion,
                               secureNotifications,
                               accessKey,
                               approvalDuration,
                               approvers,
                               assignedDate,
                               createdDate,
                               elapsedTime,
                               endDate,
                               fromUser,
                               fromUserDisplayName,
                               hasSubtask,
                               inShortHistory,
                               isGroup,
                               language,
                               mailStatus,
                               numberOfTimesModified,
                               originalAssigneeUser,
                               outcome,
                               parallelOutcomeCount,
                               pushbackSequence,
                               State,
                               SubState,
                               systemString1,
                               systemString2,
                               SystemString3,
                               taskGroupId,
                               taskId,
                               taskNumber,
                               updatedBy,
                               updatedByDisplayName,
                               updatedDate,
                               version,
                               versionReason,
                               workflowPattern,
                               textAttribute1,
                               textAttribute2,
                               textAttribute3,
                               textAttribute4,
                               textAttribute5,
                               textAttribute6,
                               textAttribute7,
                               textAttribute8,
                               textAttribute9,
                               textAttribute10,
                               formAttribute1,
                               formAttribute2,
                               formAttribute3,
                               formAttribute4,
                               formAttribute5,
                               urlAttribute1,
                               urlAttribute2,
                               urlAttribute3,
                               urlAttribute4,
                               urlAttribute5,
                               dateAttribute1,
                               dateAttribute2,
                               dateAttribute3,
                               dateAttribute4,
                               dateAttribute5,
                               numberAttribute1,
                               numberAttribute2,
                               numberAttribute3,
                               numberAttribute4,
                               numberAttribute5,
                               protectedTextAttribute1,
                               protectedTextAttribute2,
                               protectedTextAttribute3,
                               protectedTextAttribute4,
                               protectedTextAttribute5,
                               protectedTextAttribute6,
                               protectedTextAttribute7,
                               protectedTextAttribute8,
                               protectedTextAttribute9,
                               protectedTextAttribute10,
                               protectedFormAttribute1,
                               protectedFormAttribute2,
                               protectedFormAttribute3,
                               protectedFormAttribute4,
                               protectedFormAttribute5,
                               protectedUrlAttribute1,
                               protectedUrlAttribute2,
                               protectedUrlAttribute3,
                               protectedUrlAttribute4,
                               protectedUrlAttribute5,
                               protectedDateAttribute1,
                               protectedDateAttribute2,
                               protectedDateAttribute3,
                               protectedDateAttribute4,
                               protectedDateAttribute5,
                               protectedNumberAttribute1,
                               protectedNumberAttribute2,
                               protectedNumberAttribute3,
                               protectedNumberAttribute4,
                               protectedNumberAttribute5,
                               title,
                               titleResourceKey,
                               identificationKey,
                               userComment,
                               workflowDescriptorURI,
                               taskDefinitionId,
                               taskDefinitionName)
            SELECT /*+ INDEX(WFTask WFTask(taskId)) */
                               acquiredBy,
                               assigneeGroups,
                               assigneeGroupsDisplayName,
                               assigneeUsers,
                               assigneeUsersDisplayName,
                               callbackContext,
                               callbackId,
                               callbackType,
                               creator,
                               digitalSignatureRequired,
                               expirationDate,
                               expirationDuration,
                               identityContext,
                               ownerUser,
                               ownerGroup,
                               passwordRequiredOnUpdate,
                               priority,
                               domainId,
                               instanceId,
                               processId,
                               processName,
                               processType,
                               processVersion,
                               secureNotifications,
                               accessKey,
                               approvalDuration,
                               approvers,
                               assignedDate,
                               createdDate,
                               elapsedTime,
                               endDate,
                               fromUser,
                               fromUserDisplayName,
                               hasSubtask,
                               inShortHistory,
                               isGroup,
                               language,
                               mailStatus,
                               numberOfTimesModified,
                               originalAssigneeUser,
                               outcome,
                               parallelOutcomeCount,
                               pushbackSequence,
                               State,
                               SubState,
                               systemString1,
                               systemString2,
                               SystemString3,
                               taskGroupId,
                               taskId,
                               taskNumber,
                               updatedBy,
                               updatedByDisplayName,
                               updatedDate,
                               version,
                               versionReason,
                               workflowPattern,
                               textAttribute1,
                               textAttribute2,
                               textAttribute3,
                               textAttribute4,
                               textAttribute5,
                               textAttribute6,
                               textAttribute7,
                               textAttribute8,
                               textAttribute9,
                               textAttribute10,
                               formAttribute1,
                               formAttribute2,
                               formAttribute3,
                               formAttribute4,
                               formAttribute5,
                               urlAttribute1,
                               urlAttribute2,
                               urlAttribute3,
                               urlAttribute4,
                               urlAttribute5,
                               dateAttribute1,
                               dateAttribute2,
                               dateAttribute3,
                               dateAttribute4,
                               dateAttribute5,
                               numberAttribute1,
                               numberAttribute2,
                               numberAttribute3,
                               numberAttribute4,
                               numberAttribute5,
                               protectedTextAttribute1,
                               protectedTextAttribute2,
                               protectedTextAttribute3,
                               protectedTextAttribute4,
                               protectedTextAttribute5,
                               protectedTextAttribute6,
                               protectedTextAttribute7,
                               protectedTextAttribute8,
                               protectedTextAttribute9,
                               protectedTextAttribute10,
                               protectedFormAttribute1,
                               protectedFormAttribute2,
                               protectedFormAttribute3,
                               protectedFormAttribute4,
                               protectedFormAttribute5,
                               protectedUrlAttribute1,
                               protectedUrlAttribute2,
                               protectedUrlAttribute3,
                               protectedUrlAttribute4,
                               protectedUrlAttribute5,
                               protectedDateAttribute1,
                               protectedDateAttribute2,
                               protectedDateAttribute3,
                               protectedDateAttribute4,
                               protectedDateAttribute5,
                               protectedNumberAttribute1,
                               protectedNumberAttribute2,
                               protectedNumberAttribute3,
                               protectedNumberAttribute4,
                               protectedNumberAttribute5,
                               title,
                               titleResourceKey,
                               identificationKey,
                               userComment,
                               workflowDescriptorURI,
                               taskDefinitionId,
                               taskDefinitionName
              FROM WFTask WHERE taskId = p_taskID;
  END;
  
  
  PROCEDURE insertTask(
                               p_acquiredBy                  VARCHAR2,
                               p_assigneeGroups              VARCHAR2,
                               p_assigneeGroupsDisplayName   VARCHAR2,
                               p_assigneeUsers               VARCHAR2,
                               p_assigneeUsersDisplayName    VARCHAR2,
                               p_callbackContext             VARCHAR2,
                               p_callbackId                  VARCHAR2,
                               p_callbackType                VARCHAR2,
                               p_creator                     VARCHAR2,
                               p_digitalSignatureRequired    VARCHAR2,
                               p_expirationDate              DATE,
                               p_expirationDuration          VARCHAR2,
                               p_identityContext             VARCHAR2,
                               p_ownerUser                   VARCHAR2,
                               p_ownerGroup                  VARCHAR2,
                               p_passwordRequiredOnUpdate    VARCHAR2,
                               p_priority                    NUMBER,
                               p_domainId                    VARCHAR2,
                               p_instanceId                  VARCHAR2,
                               p_processId                   VARCHAR2,
                               p_processName                 VARCHAR2,
                               p_processType                 VARCHAR2,
                               p_processVersion              VARCHAR2,
                               p_secureNotifications         VARCHAR2,
                               p_accessKey                   VARCHAR2,
                               p_approvalDuration            NUMBER,
                               p_approvers                   VARCHAR2,
                               p_assignedDate                DATE,
                               p_createdDate                 DATE,
                               p_elapsedTime                 NUMBER,
                               p_endDate                     DATE,
                               p_fromUser                    VARCHAR2,
                               p_fromUserDisplayName         VARCHAR2,
                               p_hasSubtask                  VARCHAR2,
                               p_inShortHistory              VARCHAR2,
                               p_isGroup                     VARCHAR2,
                               p_language                    VARCHAR2,
                               p_mailStatus                  VARCHAR2,
                               p_numberOfTimesModified       NUMBER,
                               p_originalAssigneeUser        VARCHAR2,
                               p_outcome                     VARCHAR2,
                               p_parallelOutcomeCount        VARCHAR2,
                               p_pushbackSequence            VARCHAR2,
                               p_State                       VARCHAR2,
                               p_SubState                    VARCHAR2,
                               p_systemString1               VARCHAR2,
                               p_systemString2               VARCHAR2,
                               p_SystemString3               VARCHAR2,
                               p_taskGroupId                 VARCHAR2,
                               p_taskId                      VARCHAR2,
                               p_taskNumber      IN OUT      NUMBER,
                               p_updatedBy                   VARCHAR2,
                               p_updatedByDisplayName        VARCHAR2,
                               p_updatedDate                 DATE,
                               p_version                     NUMBER,
                               p_versionReason               VARCHAR2,
                               p_workflowPattern             VARCHAR2,
                               p_textAttribute1              VARCHAR2,
                               p_textAttribute2              VARCHAR2,
                               p_textAttribute3              VARCHAR2,
                               p_textAttribute4              VARCHAR2,
                               p_textAttribute5              VARCHAR2,
                               p_textAttribute6              VARCHAR2,
                               p_textAttribute7              VARCHAR2,
                               p_textAttribute8              VARCHAR2,
                               p_textAttribute9              VARCHAR2,
                               p_textAttribute10             VARCHAR2,
                               p_formAttribute1              VARCHAR2,
                               p_formAttribute2              VARCHAR2,
                               p_formAttribute3              VARCHAR2,
                               p_formAttribute4              VARCHAR2,
                               p_formAttribute5              VARCHAR2,
                               p_urlAttribute1               VARCHAR2,
                               p_urlAttribute2               VARCHAR2,
                               p_urlAttribute3               VARCHAR2,
                               p_urlAttribute4               VARCHAR2,
                               p_urlAttribute5               VARCHAR2,
                               p_dateAttribute1              DATE,
                               p_dateAttribute2              DATE,
                               p_dateAttribute3              DATE,
                               p_dateAttribute4              DATE,
                               p_dateAttribute5              DATE,
                               p_numberAttribute1            NUMBER,
                               p_numberAttribute2            NUMBER,
                               p_numberAttribute3            NUMBER,
                               p_numberAttribute4            NUMBER,
                               p_numberAttribute5            NUMBER,
                               p_protectedTextAttribute1     VARCHAR2,
                               p_protectedTextAttribute2     VARCHAR2,
                               p_protectedTextAttribute3     VARCHAR2,
                               p_protectedTextAttribute4     VARCHAR2,
                               p_protectedTextAttribute5     VARCHAR2,
                               p_protectedTextAttribute6     VARCHAR2,
                               p_protectedTextAttribute7     VARCHAR2,
                               p_protectedTextAttribute8     VARCHAR2,
                               p_protectedTextAttribute9     VARCHAR2,
                               p_protectedTextAttribute10    VARCHAR2,
                               p_protectedFormAttribute1     VARCHAR2,
                               p_protectedFormAttribute2     VARCHAR2,
                               p_protectedFormAttribute3     VARCHAR2,
                               p_protectedFormAttribute4     VARCHAR2,
                               p_protectedFormAttribute5     VARCHAR2,
                               p_protectedUrlAttribute1      VARCHAR2,
                               p_protectedUrlAttribute2      VARCHAR2,
                               p_protectedUrlAttribute3      VARCHAR2,
                               p_protectedUrlAttribute4      VARCHAR2,
                               p_protectedUrlAttribute5      VARCHAR2,
                               p_protectedDateAttribute1     DATE,
                               p_protectedDateAttribute2     DATE,
                               p_protectedDateAttribute3     DATE,
                               p_protectedDateAttribute4     DATE,
                               p_protectedDateAttribute5     DATE,
                               p_protectedNumberAttribute1   NUMBER,
                               p_protectedNumberAttribute2   NUMBER,
                               p_protectedNumberAttribute3   NUMBER,
                               p_protectedNumberAttribute4   NUMBER,
                               p_protectedNumberAttribute5   NUMBER,
                               p_title                       VARCHAR2,
                               p_titleResourceKey            VARCHAR2,
                               p_identificationKey            VARCHAR2,
                               p_workflowDescriptorURI       VARCHAR2,
                               p_taskDefinitionId                  VARCHAR2,
                               p_taskDefinitionName                VARCHAR2
                             ) IS
    BEGIN 
    
        SELECT WFTaskSeq.NEXTVAL INTO p_taskNumber
               FROM DUAL;
        INSERT INTO WFTask
                              (acquiredBy,
                               assigneeGroups,
                               assigneeGroupsDisplayName,
                               assigneeUsers,
                               assigneeUsersDisplayName,
                               callbackContext,
                               callbackId,
                               callbackType,
                               creator,
                               digitalSignatureRequired,
                               expirationDate,
                               expirationDuration,
                               identityContext,
                               ownerUser,
                               ownerGroup,
                               passwordRequiredOnUpdate,
                               priority,
                               domainId,
                               instanceId,
                               processId,
                               processName,
                               processType,
                               processVersion,
                               secureNotifications,
                               accessKey,
                               approvalDuration,
                               approvers,
                               assignedDate,
                               createdDate,
                               elapsedTime,
                               endDate,
                               fromUser,
                               fromUserDisplayName,
                               hasSubtask,
                               inShortHistory,
                               isGroup,
                               language,
                               mailStatus,
                               numberOfTimesModified,
                               originalAssigneeUser,
                               outcome,
                               parallelOutcomeCount,
                               pushbackSequence,
                               State,
                               SubState,
                               systemString1,
                               systemString2,
                               SystemString3,
                               taskGroupId,
                               taskId,
                               taskNumber,
                               updatedBy,
                               updatedByDisplayName,
                               updatedDate,
                               version,
                               versionReason,
                               workflowPattern,
                               textAttribute1,
                               textAttribute2,
                               textAttribute3,
                               textAttribute4,
                               textAttribute5,
                               textAttribute6,
                               textAttribute7,
                               textAttribute8,
                               textAttribute9,
                               textAttribute10,
                               formAttribute1,
                               formAttribute2,
                               formAttribute3,
                               formAttribute4,
                               formAttribute5,
                               urlAttribute1 ,
                               urlAttribute2,
                               urlAttribute3,
                               urlAttribute4,
                               urlAttribute5,
                               dateAttribute1,
                               dateAttribute2,
                               dateAttribute3,
                               dateAttribute4,
                               dateAttribute5,
                               numberAttribute1,
                               numberAttribute2,
                               numberAttribute3,
                               numberAttribute4,
                               numberAttribute5,
                               protectedTextAttribute1,
                               protectedTextAttribute2,
                               protectedTextAttribute3,
                               protectedTextAttribute4,
                               protectedTextAttribute5,
                               protectedTextAttribute6,
                               protectedTextAttribute7,
                               protectedTextAttribute8,
                               protectedTextAttribute9,
                               protectedTextAttribute10,
                               protectedFormAttribute1,
                               protectedFormAttribute2,
                               protectedFormAttribute3,
                               protectedFormAttribute4,
                               protectedFormAttribute5,
                               protectedUrlAttribute1,
                               protectedUrlAttribute2,
                               protectedUrlAttribute3,
                               protectedUrlAttribute4,
                               protectedUrlAttribute5,
                               protectedDateAttribute1,
                               protectedDateAttribute2,
                               protectedDateAttribute3,
                               protectedDateAttribute4,
                               protectedDateAttribute5,
                               protectedNumberAttribute1,
                               protectedNumberAttribute2,
                               protectedNumberAttribute3,
                               protectedNumberAttribute4,
                               protectedNumberAttribute5,
                               title,
                               titleResourceKey,
                               identificationKey,
                               workflowDescriptorURI,
                               taskDefinitionId,
                               taskDefinitionName
                          )VALUES(
                               p_acquiredBy,
                               p_assigneeGroups,
                               p_assigneeGroupsDisplayName,
                               p_assigneeUsers,
                               p_assigneeUsersDisplayName,
                               p_callbackContext,
                               p_callbackId,
                               p_callbackType,
                               p_creator,
                               p_digitalSignatureRequired,
                               p_expirationDate,
                               p_expirationDuration,
                               p_identityContext,
                               p_ownerUser,
                               p_ownerGroup,
                               p_passwordRequiredOnUpdate,
                               p_priority,
                               p_domainId,
                               p_instanceId,
                               p_processId,
                               p_processName,
                               p_processType,
                               p_processVersion,
                               p_secureNotifications,
                               p_accessKey,
                               p_approvalDuration,
                               p_approvers,
                               p_assignedDate,
                               p_createdDate,
                               p_elapsedTime,
                               p_endDate,
                               p_fromUser,
                               p_fromUserDisplayName,
                               p_hasSubtask,
                               p_inShortHistory,
                               p_isGroup,
                               p_language,
                               p_mailStatus,
                               1,
                               p_originalAssigneeUser,
                               p_outcome,
                               p_parallelOutcomeCount,
                               p_pushbackSequence,
                               p_State,
                               p_SubState,
                               p_systemString1,
                               p_systemString2,
                               p_SystemString3,
                               p_taskGroupId,
                               p_taskId,
                               p_taskNumber,
                               p_updatedBy,
                               p_updatedByDisplayName,
                               p_updatedDate,
                               1,
                               p_versionReason,
                               p_workflowPattern,
                               p_textAttribute1,
                               p_textAttribute2,
                               p_textAttribute3,
                               p_textAttribute4,
                               p_textAttribute5,
                               p_textAttribute6,
                               p_textAttribute7,
                               p_textAttribute8,
                               p_textAttribute9,
                               p_textAttribute10,
                               p_formAttribute1,
                               p_formAttribute2,
                               p_formAttribute3,
                               p_formAttribute4,
                               p_formAttribute5,
                               p_urlAttribute1 ,
                               p_urlAttribute2,
                               p_urlAttribute3,
                               p_urlAttribute4,
                               p_urlAttribute5,
                               p_dateAttribute1,
                               p_dateAttribute2,
                               p_dateAttribute3,
                               p_dateAttribute4,
                               p_dateAttribute5,
                               p_numberAttribute1,
                               p_numberAttribute2,
                               p_numberAttribute3,
                               p_numberAttribute4,
                               p_numberAttribute5,
                               p_protectedTextAttribute1,
                               p_protectedTextAttribute2,
                               p_protectedTextAttribute3,
                               p_protectedTextAttribute4,
                               p_protectedTextAttribute5,
                               p_protectedTextAttribute6,
                               p_protectedTextAttribute7,
                               p_protectedTextAttribute8,
                               p_protectedTextAttribute9,
                               p_protectedTextAttribute10,
                               p_protectedFormAttribute1,
                               p_protectedFormAttribute2,
                               p_protectedFormAttribute3,
                               p_protectedFormAttribute4,
                               p_protectedFormAttribute5,
                               p_protectedUrlAttribute1,
                               p_protectedUrlAttribute2,
                               p_protectedUrlAttribute3,
                               p_protectedUrlAttribute4,
                               p_protectedUrlAttribute5,
                               p_protectedDateAttribute1,
                               p_protectedDateAttribute2,
                               p_protectedDateAttribute3,
                               p_protectedDateAttribute4,
                               p_protectedDateAttribute5,
                               p_protectedNumberAttribute1,
                               p_protectedNumberAttribute2,
                               p_protectedNumberAttribute3,
                               p_protectedNumberAttribute4,
                               p_protectedNumberAttribute5,
                               p_title,
                               p_titleResourceKey,
                               p_identificationKey,
                               p_workflowDescriptorURI,
                               p_taskDefinitionId,
                               p_taskDefinitionName
                          );
            
         createHistory(p_taskID);
    EXCEPTION
     WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(v_insertErrorNumber,'Error while inserting task',true);
    END insertTask;
   
   PROCEDURE updateTask(
                               p_acquiredBy                  VARCHAR2,
                               p_assigneeGroups              VARCHAR2,
                               p_assigneeGroupsDisplayName   VARCHAR2,
                               p_assigneeUsers               VARCHAR2,
                               p_assigneeUsersDisplayName    VARCHAR2,
                               p_callbackContext             VARCHAR2,
                               p_callbackId                  VARCHAR2,
                               p_callbackType                VARCHAR2,
                               p_creator                     VARCHAR2,
                               p_digitalSignatureRequired    VARCHAR2,
                               p_expirationDate              DATE,
                               p_expirationDuration          VARCHAR2,
                               p_identityContext             VARCHAR2,
                               p_ownerUser                   VARCHAR2,
                               p_ownerGroup                  VARCHAR2,
                               p_passwordRequiredOnUpdate    VARCHAR2,
                               p_priority                    NUMBER,
                               p_domainId                    VARCHAR2,
                               p_instanceId                  VARCHAR2,
                               p_processId                   VARCHAR2,
                               p_processName                 VARCHAR2,
                               p_processType                 VARCHAR2,
                               p_processVersion              VARCHAR2,
                               p_secureNotifications         VARCHAR2,
                               p_accessKey                   VARCHAR2,
                               p_approvalDuration            NUMBER,
                               p_approvers                   VARCHAR2,
                               p_assignedDate                DATE,
                               p_createdDate                 DATE,
                               p_elapsedTime                 NUMBER,
                               p_endDate                     DATE,
                               p_fromUser                    VARCHAR2,
                               p_fromUserDisplayName         VARCHAR2,
                               p_hasSubtask                  VARCHAR2,
                               p_inShortHistory              VARCHAR2,
                               p_isGroup                     VARCHAR2,
                               p_language                    VARCHAR2,
                               p_mailStatus                  VARCHAR2,
                               p_numberOfTimesModified       NUMBER,
                               p_originalAssigneeUser        VARCHAR2,
                               p_outcome                     VARCHAR2,
                               p_parallelOutcomeCount        VARCHAR2,
                               p_pushbackSequence            VARCHAR2,
                               p_State                       VARCHAR2,
                               p_SubState                    VARCHAR2,
                               p_systemString1               VARCHAR2,
                               p_systemString2               VARCHAR2,
                               p_SystemString3               VARCHAR2,
                               p_taskGroupId                 VARCHAR2,
                               p_taskId                      VARCHAR2,
                               p_taskNumber                  NUMBER,
                               p_updatedBy                   VARCHAR2,
                               p_updatedByDisplayName        VARCHAR2,
                               p_updatedDate                 DATE,
                               p_version                     NUMBER,
                               p_versionReason               VARCHAR2,
                               p_workflowPattern             VARCHAR2,
                               p_textAttribute1              VARCHAR2,
                               p_textAttribute2              VARCHAR2,
                               p_textAttribute3              VARCHAR2,
                               p_textAttribute4              VARCHAR2,
                               p_textAttribute5              VARCHAR2,
                               p_textAttribute6              VARCHAR2,
                               p_textAttribute7              VARCHAR2,
                               p_textAttribute8              VARCHAR2,
                               p_textAttribute9              VARCHAR2,
                               p_textAttribute10             VARCHAR2,
                               p_formAttribute1              VARCHAR2,
                               p_formAttribute2              VARCHAR2,
                               p_formAttribute3              VARCHAR2,
                               p_formAttribute4              VARCHAR2,
                               p_formAttribute5              VARCHAR2,
                               p_urlAttribute1               VARCHAR2,
                               p_urlAttribute2               VARCHAR2,
                               p_urlAttribute3               VARCHAR2,
                               p_urlAttribute4               VARCHAR2,
                               p_urlAttribute5               VARCHAR2,
                               p_dateAttribute1              DATE,
                               p_dateAttribute2              DATE,
                               p_dateAttribute3              DATE,
                               p_dateAttribute4              DATE,
                               p_dateAttribute5              DATE,
                               p_numberAttribute1            NUMBER,
                               p_numberAttribute2            NUMBER,
                               p_numberAttribute3            NUMBER,
                               p_numberAttribute4            NUMBER,
                               p_numberAttribute5            NUMBER,
                               p_protectedTextAttribute1     VARCHAR2,
                               p_protectedTextAttribute2     VARCHAR2,
                               p_protectedTextAttribute3     VARCHAR2,
                               p_protectedTextAttribute4     VARCHAR2,
                               p_protectedTextAttribute5     VARCHAR2,
                               p_protectedTextAttribute6     VARCHAR2,
                               p_protectedTextAttribute7     VARCHAR2,
                               p_protectedTextAttribute8     VARCHAR2,
                               p_protectedTextAttribute9     VARCHAR2,
                               p_protectedTextAttribute10    VARCHAR2,
                               p_protectedFormAttribute1     VARCHAR2,
                               p_protectedFormAttribute2     VARCHAR2,
                               p_protectedFormAttribute3     VARCHAR2,
                               p_protectedFormAttribute4     VARCHAR2,
                               p_protectedFormAttribute5     VARCHAR2,
                               p_protectedUrlAttribute1      VARCHAR2,
                               p_protectedUrlAttribute2      VARCHAR2,
                               p_protectedUrlAttribute3      VARCHAR2,
                               p_protectedUrlAttribute4      VARCHAR2,
                               p_protectedUrlAttribute5      VARCHAR2,
                               p_protectedDateAttribute1     DATE,
                               p_protectedDateAttribute2     DATE,
                               p_protectedDateAttribute3     DATE,
                               p_protectedDateAttribute4     DATE,
                               p_protectedDateAttribute5     DATE,
                               p_protectedNumberAttribute1   NUMBER,
                               p_protectedNumberAttribute2   NUMBER,
                               p_protectedNumberAttribute3   NUMBER,
                               p_protectedNumberAttribute4   NUMBER,
                               p_protectedNumberAttribute5   NUMBER,
                               p_title                       VARCHAR2,
                               p_titleResourceKey            VARCHAR2,
                               p_identificationKey            VARCHAR2,
                               p_workflowDescriptorURI       VARCHAR2,
                               p_taskDefinitionId                  VARCHAR2,
                               p_taskDefinitionName                VARCHAR2,
                               p_IsVersionable               VARCHAR2
                             ) IS
      v_notm NUMBER;
    BEGIN 
        /**
          As caller already increments notm value call lock method
          by decrementing notm value
         */
        lockWFTask(p_taskId, p_numberOfTimesModified-1);      
        UPDATE  /*+ INDEX(WFTask WFTask(taskId)) */ WFTask SET
                       acquiredBy = p_acquiredBy,
                       assigneeGroups = p_assigneeGroups,
                       assigneeGroupsDisplayName = p_assigneeGroupsDisplayName,
                       assigneeUsers = p_assigneeUsers,
                       assigneeUsersDisplayName = p_assigneeUsersDisplayName,
                       callbackContext = p_callbackContext,
                       callbackId = p_callbackId,
                       callbackType = p_callbackType,
                       creator = p_creator,
                       digitalSignatureRequired = p_digitalSignatureRequired,
                       expirationDate = p_expirationDate,
                       expirationDuration = p_expirationDuration,
                       identityContext = p_identityContext,
                       ownerUser = p_ownerUser,
                       ownerGroup = p_ownerGroup,
                       passwordRequiredOnUpdate = p_passwordRequiredOnUpdate,
                       priority = p_priority,
                       domainId = p_domainId,
                       instanceId = p_instanceId,
                       processId = p_processId,
                       processName = p_processName,
                       processType = p_processType,
                       processVersion = p_processVersion,
                       secureNotifications = p_secureNotifications,
                       accessKey = p_accessKey,
                       approvalDuration = p_approvalDuration,
                       approvers = p_approvers,
                       assignedDate = p_assignedDate,
                       createdDate = p_createdDate,
                       elapsedTime = p_elapsedTime,
                       endDate = p_endDate,
                       fromUser = p_fromUser,
                       fromUserDisplayName = p_fromUserDisplayName,
                       hasSubtask = p_hasSubtask,
                       inShortHistory = p_inShortHistory,
                       isGroup = p_isGroup,
                       language = p_language,
                       mailStatus = p_mailStatus,
                       numberOfTimesModified = p_numberOfTimesModified,
                       originalAssigneeUser = p_originalAssigneeUser,
                       outcome = p_outcome,
                       parallelOutcomeCount = p_parallelOutcomeCount,
                       pushbackSequence = p_pushbackSequence,
                       State = p_State,
                       SubState = p_SubState,
                       systemString1 = p_systemString1,
                       systemString2 = p_systemString2,
                       SystemString3 = p_SystemString3,
                       taskGroupId = p_taskGroupId,
                       taskId = p_taskId,
                       taskNumber = p_taskNumber,
                       updatedBy = p_updatedBy,
                       updatedByDisplayName = p_updatedByDisplayName,
                       updatedDate = p_updatedDate,
                       version = p_version,
                       versionReason = p_versionReason,
                       workflowPattern = p_workflowPattern,
                       textAttribute1 = p_textAttribute1,
                       textAttribute2 = p_textAttribute2,
                       textAttribute3 = p_textAttribute3,
                       textAttribute4 = p_textAttribute4,
                       textAttribute5 = p_textAttribute5,
                       textAttribute6 = p_textAttribute6,
                       textAttribute7 = p_textAttribute7,
                       textAttribute8 = p_textAttribute8,
                       textAttribute9 = p_textAttribute9,
                       textAttribute10 = p_textAttribute10,
                       formAttribute1 = p_formAttribute1,
                       formAttribute2 = p_formAttribute2,
                       formAttribute3 = p_formAttribute3,
                       formAttribute4 = p_formAttribute4,
                       formAttribute5 = p_formAttribute5,
                       urlAttribute1 = p_urlAttribute1,
                       urlAttribute2 = p_urlAttribute2,
                       urlAttribute3 = p_urlAttribute3,
                       urlAttribute4 = p_urlAttribute4,
                       urlAttribute5 = p_urlAttribute5,
                       dateAttribute1 = p_dateAttribute1,
                       dateAttribute2 = p_dateAttribute2,
                       dateAttribute3 = p_dateAttribute3,
                       dateAttribute4 = p_dateAttribute4,
                       dateAttribute5 = p_dateAttribute5,
                       numberAttribute1 = p_numberAttribute1,
                       numberAttribute2 = p_numberAttribute2,
                       numberAttribute3 = p_numberAttribute3,
                       numberAttribute4 = p_numberAttribute4,
                       numberAttribute5 = p_numberAttribute5,
                       protectedTextAttribute1 = p_protectedTextAttribute1,
                       protectedTextAttribute2 = p_protectedTextAttribute2,
                       protectedTextAttribute3 = p_protectedTextAttribute3,
                       protectedTextAttribute4 = p_protectedTextAttribute4,
                       protectedTextAttribute5 = p_protectedTextAttribute5,
                       protectedTextAttribute6 = p_protectedTextAttribute6,
                       protectedTextAttribute7 = p_protectedTextAttribute7,
                       protectedTextAttribute8 = p_protectedTextAttribute8,
                       protectedTextAttribute9 = p_protectedTextAttribute9,
                       protectedTextAttribute10 = p_protectedTextAttribute10,
                       protectedFormAttribute1 = p_protectedFormAttribute1,
                       protectedFormAttribute2 = p_protectedFormAttribute2,
                       protectedFormAttribute3 = p_protectedFormAttribute3,
                       protectedFormAttribute4 = p_protectedFormAttribute4,
                       protectedFormAttribute5 = p_protectedFormAttribute5,
                       protectedUrlAttribute1 = p_protectedUrlAttribute1,
                       protectedUrlAttribute2 = p_protectedUrlAttribute2,
                       protectedUrlAttribute3 = p_protectedUrlAttribute3,
                       protectedUrlAttribute4 = p_protectedUrlAttribute4,
                       protectedUrlAttribute5 = p_protectedUrlAttribute5,
                       protectedDateAttribute1 = p_protectedDateAttribute1,
                       protectedDateAttribute2 = p_protectedDateAttribute2,
                       protectedDateAttribute3 = p_protectedDateAttribute3,
                       protectedDateAttribute4 = p_protectedDateAttribute4,
                       protectedDateAttribute5 = p_protectedDateAttribute5,
                       protectedNumberAttribute1 = p_protectedNumberAttribute1,
                       protectedNumberAttribute2 = p_protectedNumberAttribute2,
                       protectedNumberAttribute3 = p_protectedNumberAttribute3,
                       protectedNumberAttribute4 = p_protectedNumberAttribute4,
                       protectedNumberAttribute5 = p_protectedNumberAttribute5,
                       title = p_title,
                       titleResourceKey = p_titleResourceKey,
                       identificationKey = p_identificationKey,
                       workflowDescriptorURI = p_workflowDescriptorURI,
                       taskDefinitionId = p_taskDefinitionId,
                       taskDefinitionName = p_taskDefinitionName
              WHERE taskID = p_taskId;
              
       IF p_IsVersionable =  BOOLEAN_TRUE_STRING THEN
        createHistory(p_taskID);
       END IF;
       
    EXCEPTION
       WHEN  v_lockException THEN
         RAISE_APPLICATION_ERROR(v_lockErrorNumber,'Task is locked for update',true);
       WHEN  v_deletedException THEN
         RAISE_APPLICATION_ERROR(v_deletedErrorNumber,'Task is deleted',true);
       WHEN v_modifiedException THEN
         RAISE_APPLICATION_ERROR(v_modifiedErrorNumber,'Task is modified',true);
       WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(v_updateErrorNumber,'Error while updating the task',true);
    END updateTask;
  
   PROCEDURE createWFTaskVersion(
                                  p_taskID   VARCHAR,
                                  p_version  NUMBER,
                                  p_notm     NUMBER,
                                  p_versionReason VARCHAR
                                ) IS
    BEGIN
        lockWFTask(p_taskId, p_notm); 
         UPDATE /*+ INDEX(WFTask WFTask(taskId)) */WFTask 
            SET versionReason = p_versionReason,
                version = p_version
            WHERE taskId = p_taskID;
         createHistory(p_taskID);
    EXCEPTION
       WHEN  v_lockException THEN
         RAISE_APPLICATION_ERROR(V_lockErrorNumber,'Task is locked for update',true);
       WHEN v_deletedException THEN
          RAISE_APPLICATION_ERROR(V_deletedErrorNumber,'Task is deleted',true);
       WHEN v_modifiedException THEN
          RAISE_APPLICATION_ERROR(V_modifiedErrorNumber,'Task is modified',true);
       WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(v_insertErrorNumber,'Error while creating task version ',true);
    END;
    
    
    FUNCTION insertAttachment (
                                  p_taskID   VARCHAR,
                                  p_version  NUMBER,
                                  p_updatedBy VARCHAR,
                                  p_updatedByDisplayName VARCHAR,
                                  p_updatedDate DATE,
                                  p_encoding VARCHAR,
                                  p_uri  VARCHAR,
                                  p_name VARCHAR
                                ) RETURN BLOB IS
      v_blob BLOB;
   
    BEGIN
       IF p_uri is NULL THEN
         v_blob := empty_blob();
       END IF;
       INSERT INTO WFAttachment(
                                taskID,
                                version,
                                encoding,
                                uri,
                                name,
                                content,
                                updatedby,
                                updatedByDisplayName,
                                updatedDate
                              ) VALUES (
                                p_taskID,
                                p_version,
                                p_encoding,
                                p_uri,
                                p_name,
                                v_blob,
                                p_updatedBy,
                                p_updatedByDisplayName,
                                p_updatedDate);
      SELECT /*+ INDEX(WFAttachment WFAttachment(taskId,version,name)) */ content INTO v_blob
            FROM WFAttachment
            WHERE taskId = p_taskId AND
                  version = p_version AND
                  name = p_name AND
                  maxVersion IS NULL;
      return v_blob;
    EXCEPTION
       WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(v_insertErrorNumber,'Error while inserting attachment',true);
    END insertAttachment;
    
    FUNCTION insertMessageAttribute (
                                        p_taskId        VARCHAR,
                                        p_version       NUMBER,
                                        p_name          VARCHAR,
                                        p_storageType   INTEGER,
                                        p_encoding      VARCHAR,
                                        p_stringValue   VARCHAR,
                                        p_numberValue   NUMBER,
                                        p_dateValue     DATE,
                                        p_elementSeq    NUMBER
                                      ) RETURN BLOB IS
       v_blob BLOB;
    BEGIN
       IF p_storageType = BLOB_DATATYPE THEN
         v_blob := empty_blob();
       END IF;
       
       UPDATE /*+ INDEX(WFMessageAttribute WFMessageAttribute(taskId, name)) */ WFMessageAttribute
               SET MaxVersion = p_version-1
               WHERE taskId = p_taskId AND
                     name = p_name AND
                     MaxVersion IS NULL;
       
       INSERT INTO WFMessageAttribute (
                                       taskId,
                                       version,
                                       name,
                                       storageType,
                                       encoding,
                                       stringValue,
                                       numberValue,
                                       dateValue,
                                       blobValue,
                                       elementSeq
                                      ) VALUES (
                                        p_taskId,
                                        p_version,
                                        p_name,
                                        p_storageType,
                                        p_encoding,
                                        p_stringValue,
                                        p_numberValue,
                                        p_dateValue,
                                        v_blob,
                                        p_elementSeq
                                      );
        SELECT /*+ INDEX(WFMessageAttribute WFMessageAttribute( taskId, name)) */ blobvalue INTO v_blob
            FROM WFMessageAttribute
            WHERE taskId = p_taskId AND
                  name = p_name AND
                  maxVersion IS NULL;
        return v_blob;
    EXCEPTION
       WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(v_insertErrorNumber,'Error while inserting payload',true);
    END insertMessageAttribute;
    
   
    FUNCTION updateMessageAttribute (
                                        p_taskId        VARCHAR,
                                        p_version       NUMBER,
                                        p_name          VARCHAR,
                                        p_storageType   INTEGER,
                                        p_encoding      VARCHAR,
                                        p_stringValue   VARCHAR,
                                        p_numberValue   NUMBER,
                                        p_dateValue     DATE,
                                        p_elementSeq    NUMBER
                                      ) RETURN BLOB IS
       v_blob BLOB;      
    BEGIN

       IF p_storageType = BLOB_DATATYPE THEN
         v_blob := empty_blob();
       END IF;
       
       UPDATE /*+ INDEX(WFMessageAttribute WFMessageAttribute(taskId, name)) */
               WFMessageAttribute 
               SET taskId = p_taskId,
                   name = p_name,
                   storageType = p_storageType,
                   encoding = p_encoding,
                   stringValue = p_stringValue,
                   numberValue = p_numberValue,
                   dateValue = p_dateValue,
                   blobvalue = v_blob,
                   elementSeq = p_elementSeq
                WHERE taskId = p_taskId AND
                      name = p_name AND
                      maxVersion IS NULL;
                      
       IF p_storageType = BLOB_DATATYPE THEN
         SELECT /*+ INDEX (WFMessageAttribute WFMessageAttribute(taskId,name)) */ blobvalue INTO v_blob
            FROM WFMessageAttribute
            WHERE taskId = p_taskId AND
                  name = p_name AND
                  maxVersion IS NULL FOR UPDATE NOWAIT;
       END IF;
       
       return v_blob;
       
    EXCEPTION
       WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(v_updateErrorNumber,'Error while updating payload',true);
    END updateMessageAttribute;
                                                                       
END WFTaskpkg;
/
