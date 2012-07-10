Rem
Rem $Header: upgrade_10131_10134_olite.sql 16-may-2008.14:37:09 ramisra Exp $
Rem
Rem upgrade_10131_10134_olite.sql
Rem
Rem Copyright (c) 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      upgrade_10131_10134_olite.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ramisra     05/16/08 - upgrade script for upgrading from 10.1.3.1 ->
Rem                           10.1.3.4
Rem    ramisra     05/16/08 - Created
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
