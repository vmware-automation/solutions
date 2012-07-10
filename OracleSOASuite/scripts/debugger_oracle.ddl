Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/debugger_oracle.ddl /st_pcbpel_10.1.3.1/4 2009/07/06 10:21:04 ykumar Exp $
Rem
Rem debugger_oracle.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      debugger_oracle.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ykumar      07/02/09 - Backport ykumar_bug-8649638 from
Rem                           st_pcbpel_10.1.3.1
Rem    mchmiele    06/10/09 - Removed instance breakpoints tables
Rem    vnanjund    04/12/09 - Debugger Persistence Tables
Rem    vnanjund    04/12/09 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

/**
*	BPEL Debugger Tables definition - used for persisting debugger state to DB
*
* Only process breakpoints are held here. The instance breakpoints are maintained on
* the cube instance using the BPEL Persistence mechenism.
*/ 

drop table DBG_PROCESS_BREAKPOINT;

CREATE TABLE  "DBG_PROCESS_BREAKPOINT" 
(	"PROCESS_ID" VARCHAR2(100) NOT NULL, 
	"REVISION_TAG" VARCHAR2(50) NOT NULL, 
	"DOMAIN_REF" NUMBER NOT NULL, 
	"ELEMENT_ID" VARCHAR2(50) NOT NULL, 
	"CONDITION" VARCHAR2(250), 
	 CONSTRAINT "DBG_PROCESS_BREAKPOINTS_PK" PRIMARY KEY ("PROCESS_ID", "REVISION_TAG", "ELEMENT_ID") ENABLE
);
   

commit;
