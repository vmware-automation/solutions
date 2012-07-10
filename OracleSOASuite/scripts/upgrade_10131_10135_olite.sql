Rem
Rem $Header: bpel/everest/src/modules/server/database/scripts/upgrade_10131_10135_olite.sql /st_pcbpel_10.1.3.1/1 2009/05/11 20:44:51 ramisra Exp $
Rem
Rem upgrade_10131_10135_olite.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      upgrade_10131_10135_olite.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     03/20/09 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@upgrade_10131_10133_olite.sql
@@upgrade_10133_10134_olite.sql
@@upgrade_10134_10135_olite.sql
