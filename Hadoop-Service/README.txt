***************************************************
      Hadoop Service Blueprint  (v 0.20.203.0)
***************************************************

The typical Hadoop service application (blueprint) is shown as in the png file "Hadoop-snapshot.png". In the blueprint, the Hadoop service is made of four service components and two script components. The service component "vFabric_tc_Server" is for demo purpose to show the usage of Hadoop service. It is not necessary to be part of the blueprint of the Hadoop app.

From the service names, you will be able to tell what role each node acts as, like "Hadoop_NameNode" (NN) acts as the Name Node in the service BP, "Hadoop_DataNode" (DN) as Data Node, "Hadoop_JobTracker" (JT) as Job Tracker, and "Hadoop_TaskTracker" (TT) as Task Tracker.

We have created two scripts, "Sync_DataNode" and "Sync_TaskTracker" for the sync purpose. The intent of these scripts is to add entries like IP and host name of all the slave nodes (both DataNode and TaskTracker) in the /etc/hosts file.

To add the Hadoop blueprint to vFabric Application Director follow the steps below.

1. Create the four services - "Hadoop_NameNode", "Hadoop_DataNode", "Hadoop_JobTracker", and "Hadoop_TaskTracker" in the catalog.
   
   1.1 Use the following values for the service details in the service "Details" pane:

   Name:                Apache Hadoop Cluster
   Version:             0.20.203.0
   Tags:                Hadoop Services
   Supported OSes       CentOS 5.7, RHEL 6.1, Ubuntu 10, SUSE 11

   1.2 Use the properties in the "Hadoop_Properties.pdf" file to specify the properties for each service in the service "Properties" pane.

   1.3 Use the scripts in the directories of the four services ("nameNode", "dataNode", "jobTracker", and "taskTracker) to specify the actions in the service "Actions" pane.

2. Create a new application, e.g. called "Hadoop App".

3. Add the nodes and services to the app "Hadoop App" according the blueprint snapshot.

4. Add the two scripts "Sync_DataNode" and "Sync_TaskTracker" to the corresponding nodes as indicated in the blueprint snapshot.

5. Add the dependencies to the services and scripts according to the blueprint.

6. (Optional) For testing purpose, you can add "vFabric_tc_Server" service to the app, which will be used to test if the Hadoop service works. The scripts are in the "tc_server" directory and the properties of the services are listed in "Hadoop_Properites" pdf file. For detailed guidance of the sample app that will be added to to the tc_Server, please refer to the doc sampleApp/Hadoop_Cluster_Sample_Webapp.pdf.

7. Start the deployment of the Hadoop service app.

8. Upon the successful deployment, you can follow the validation procedure of the Hadoop service, specified in "Hadoop_Cluster_Sample_Webapp.pdf", to verify the deployment.

There are yum/zypper/apt-get install for some OSes in the scripts of the services. For some OSes running in the VM template, e.g. CentOS and RHEL, you may need to add the yum/zypper/apt-get repositories to the node. Please refer to vFabric Application Director user manual to see how to add yum/zypper/apt-get repository scripts to the node.
 
