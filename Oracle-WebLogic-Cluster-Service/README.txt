***************************************************************************************
      Service Blueprint for WebLogic Application Server Cluster  (v 12c)
***************************************************************************************

The typical WebLogic Application Server Cluster (WebLogic Cluster) service application (blueprint) is shown as in the png file "WebLogic_Cluster_Blueprint.png". In the blueprint, the WebLogic Cluster service is made of Admin_Server node, Managed WebLogic server nodes (standalone and clustered). The script components "Load_Balancer" and "Demo_App" are for demo purpose to show the usage of WebLogic Cluster service. It is not necessary to be part of the blueprint of the WebLogic cluster.

To add the WebLogic Cluster blueprint to vFabric Application Director follow the steps below.

1. Create the services  "Weblogic_Admin" and "WebLogic_Managed_Server" as shown in the blueprint.
   
   1.1 Use the following values for the service details in the service "Details" pane:

   Name:                <service name as shown in the blueprint>
   Version:             12.0.0-c
   Tags:                  WebLogic Cluster Services
   Supported OSes       CentOS 5.7, RHEL 6.1, Ubuntu 10, SUSE 11

   1.2 Use the properties in the "WebLogic_Cluster_Properties.pdf" file to specify the properties for each service in the service "Properties" pane.

   1.3 Use the scripts in the directories of each node to specify the actions in the service "Actions" pane. The directory "admin" contains the scripts for the service "WebLogic_Admin", and the directory "managed" contains the scripts for the service "WebLogic_Managed_Server".

2. Create a new application, e.g. called "WebLogic Cluster App".

3. Add the nodes and services to the app "WebLogic Cluster App" according the blueprint snapshot.

4. Add the script "Enroll" to the corresponding nodes as indicated in the blueprint snapshot. The properties are listed in the file "WebLogic_Cluster_Properties.pdf", and the action scripts are in the directory "enroll".

5. Add the dependencies to the services and scripts according to the blueprint.

6. (Optional) For testing purpose, you can add "Sample_App" script and "Load_Balancer" to the app, which will be used to test if the WebLogic Cluster service works.

7. Start the deployment of the WebLogic Cluster service app.

There are yum/zypper/apt-get install for some OSes in the scripts of the services. For some OSes running in the VM template, e.g. CentOS and RHEL, you may need to add the yum/zypper/apt-get repositories to the node. Please refer to vFabric Application Director user manual to see how to add yum/zypper/apt-get repository scripts to the node.

