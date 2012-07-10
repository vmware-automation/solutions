update "ORABPEL"."DOMAIN_PROPERTIES" set "PROP_VALUE"='jdbc/BPELServerDataSourceWorkflow' where "PROP_ID"='datasourceJndi';
update "ORABPEL"."DOMAIN_PROPERTIES" set "PROP_VALUE"='jdbc/BPELServerDataSource' where "PROP_ID"='txDatasourceJndi';
commit;

