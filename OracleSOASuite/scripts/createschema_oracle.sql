Rem
Rem $Header: createschema_oracle.sql 05-may-2006.12:55:30 gsah Exp $
Rem
Rem loaddata_oracle.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      loaddata_oracle.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gsah        05/05/06 - run server_oracle.ddl first 
Rem    gsah        03/21/06 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@server_oracle.ddl
@@domain_oracle.ddl

