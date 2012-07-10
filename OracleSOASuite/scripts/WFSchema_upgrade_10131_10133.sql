/**
Rem
Rem $Header: patch_10133_oracle.sql 15-mar-2007.17:09:50 vumapath Exp $
Rem
Rem patch_10133_oracle.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      patch_10133_oracle.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vumapath    03/15/07 - Human workflow schema changes for 10133 patchset
Rem    vumapath    03/15/07 - Created
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
