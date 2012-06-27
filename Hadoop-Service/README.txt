*****************************************
      Hadoop Service  v 0.20.203.0
*****************************************

The typical Hadoop service application is shown as in the png file "Hadoop-snapshot.png". In the blueprint, the Hadoop service is made of four service components and two script components. The service component "vFabric_tc_Server" is for demo purpose to show the usage of Hadoop service. It is not necessary to be part of the blueprint of the Hadoop app.

From the service names, you will be able to tell what role each node acts as, like "Hadoop_NameNode" (NN) acts as the Name Node in the service BP, "Hadoop_DataNode" (DN) as Data Node, "Hadoop_JabTracker" (JT) as Job Tracker, and "Hadoop_TaskTracker" (TT) as Task Tracker.

We have created two scripts, "Sync_DataNode" and "Sync_TaskTracker", for the sync purpose. The intent of these scripts is to add entries like IP and host name of all the slave nodes (both DataNode and TaskTracker) in the /etc/hosts file. We can get the IP of all the slave nodes from the self:IP but we were not able to find the any similar property to retrieve the “host name” in the AppDirector.

To add the  to vFabric Application Director follow the steps below.

1. Create a new service in the catalog.

2. Use the following values for the service details:

   Name: 		Apache Hadoop Cluster
   Version: 		0.20.203.0
   Tags: 		Hadoop Services
   Supported OSes 	CentOS 5.7, RHEL 6.1, Ubuntu 10, SUSE 11

 
