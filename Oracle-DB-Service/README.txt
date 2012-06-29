***************************************************
      Oracle DB Service (v 11.2.0)
***************************************************

To add the Oracle DB v11.2.0 to vFabric Application Director follow the steps below.

1. Create the service "Oracle_DB" in the catalog.
   
   1.1 Use the following values for the service details in the service "Details" pane:

   Name:                Oracle_DB
   Version:             11.2.0
   Tags:                  DB Services
   Supported OSes     CentOS 5.6, RHEL 6.1, Ubuntu 10, SUSE 11

   1.2 Use the properties in the "Oracle_Properties.JPG" file to specify the properties for the service in the service "Properties" pane.

   1.3 Use the scripts in the directory "oracleDB" to specify the actions in the service "Actions" pane.

2. Save the service.

For the Oracle DB 11.2.0 installer packages. You need to download it from Oracle download website, and put them in a NFS server that the deployment Oracle DB service can mount onto. During the deployment of the Oracle DB, the Oracle DB service will copy the installer packages from the NFS server and start the installation.

