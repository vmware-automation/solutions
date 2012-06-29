***************************************************
      Websphere Application Server Service (v 8.0.0)
***************************************************

To add the Websphere Application Server v8.0.0 to  vFabric Application Director follow the steps below.

1. Create the service "Websphere_App_Server" in the catalog.
   
   1.1 Use the following values for the service details in the service "Details" pane:

   Name:                Websphere App Server
   Version:             8.0.0
   Tags:                  Application Servers
   Supported OSes     CentOS 5.6, RHEL 6.1, Ubuntu 10, SUSE 11

   1.2 Use the properties in the "Websphere_Properties.png" file to specify the properties for the service in the service "Properties" pane.

   1.3 Use the scripts in the directory "websphere" to specify the actions in the service "Actions" pane.

2. Save the service.

For the Websphere 8.0.0 installer packages, you need to download it from Oracle download website, and put them in a NFS server that the deployment Websphere service can mount onto. During the deployment of the Websphere App Server, the service will copy the installer packages from the NFS server and start the installation.

