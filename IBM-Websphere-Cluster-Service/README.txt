***************************************************************************************

      Service Blueprint for Websphere Application Server Cluster  (v 8.0.0)
***************************************************************************************

The typical Websphere Application Server Cluster (Websphere Cluster) service application (blueprint) is shown as in the png file "Websphere_Cluster_Blueprint.png". In the blueprint, the Websphere Cluster service is made of Domain Manager node, Managed Websphere server nodes (standalone and clustered). The service components "SampleApp" and "WebSphere_IHS_HTTP_Server" are for demo purpose to show the usage of Websphere Cluster service. It is not necessary to be part of the blueprint of the Websphere cluster.

To add the Websphere Cluster blueprint to vFabric Application Director follow the steps below.

1. Create the services  "WebSphereDevelopmentManager" and "WebSphereAppServer" as shown in the blueprint.
   
   1.1 Use the following values for the service details in the service "Details" pane:

   Name:                <service name as shown in the blueprint>
   Version:             8.0.0
   Tags:                  Websphere Cluster Services
   Supported OSes       CentOS 5.7, RHEL 6.1, Ubuntu 10, SUSE 11

   1.2 Use the properties in the "Websphere_Cluster_Properties.pdf" file to specify the properties for each service in the service "Properties" pane.

   1.3 Use the scripts in the directories of each node to specify the actions in the service "Actions" pane. The directory "dmgr" contains the scripts for the service "WebSphereDevelopmentManager", and the directory "managed_node" contains the scripts for the service "WebSphereAppServer".

2. Create a new application, e.g. called "Websphere Cluster App".

3. Add the nodes and services to the app "Websphere Cluster App" according the blueprint snapshot.

4. Add the scripts "GetHostname" and "Federate", and "CreateCluster" to the corresponding nodes as indicated in the blueprint snapshot. The properties are listed in the file "Websphere_Cluster_Properties.pdf", and the action scripts are listed in the directoris "managed_nodes" and "dmgr".

5. Add the dependencies to the services and scripts according to the blueprint.

6. (Optional) For testing purpose, you can add "SampleApp" script and "WebSphere_IHS_HTTP_Server" to the app, which will be used to test if the Websphere Cluster service works.

7. Start the deployment of the Websphere Cluster service app.

There are yum/zypper/apt-get install for some OSes in the scripts of the services. For some OSes running in the VM template, e.g. CentOS and RHEL, you may need to add the yum/zypper/apt-get repositories to the node. Please refer to vFabric Application Director user manual to see how to add yum/zypper/apt-get repository scripts to the node.

