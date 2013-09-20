This demonstrates creating a domain controller or master/slave JBoss 7 configuration.
  
!! IMPORTANT POINT REGARDING PROPERTIES !!
When dealing with setting up properties in this demo take care to notice the Property Type.
If you are downloading any file this must be of type content. If you use another type there is a good chance your deployment will fail.

There are two services as part of this blueprint 
1. The domain controller which performs maitenance and coordination for the cluster, it itself does not host applications
2. The slaves that register with the controller and are responsible for servicing applications.

==
[Host Controller] 23:06:21,047 INFO  [org.jboss.as] (Controller Boot Thread) JBAS015874: JBoss AS 7.2.0.Final "Janus" (Host Controller) started in 4120ms - Started 11 of 11 services (0 services are passive or on-demand)
[Host Controller] 23:33:40,311 INFO  [org.jboss.as.domain] (slave-request-threads - 1) JBAS010918: Registered remote slave host "slave1", JBoss AS 7.2.0.Final "Janus"
[Host Controller] 23:37:55,449 INFO  [org.jboss.as.domain] (slave-request-threads - 1) JBAS010918: Registered remote slave host "slave2", JBoss AS 7.2.0.Final "Janus"
==

Building JBoss Archive
----------------------
NOTE: This Blueprint has been tested with JBoss AS 7.2.0.Final
At present this was not a downloadable archive and required checking out and building manually
1.) Checkout the code from GH
$ git clone https://github.com/wildfly/wildfly.git
Cloning into 'wildfly'...
2.) You want to checkout the 7.2.0 Final
$ git tag -l
...
7.2.0.Final
...

$ git checkout tags/7.2.0.Final
Note: checking out 'tags/7.2.0.Final'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at 4ed76ce... Prepare 7.2.0.Final for pre-releases
3.) Build
$./build.sh -DskipTests -Drelease=true install
./tools/maven/bin/mvn -s tools/maven/conf/settings.xml install  -Dts.smoke  -DskipTests -Drelease=true
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:

...

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 6:16.144s

4.) Deploy the newly built artifact to your content server.
The location of the archive will be relative to the root of your build directory.
$ ls -1 dist/target
archive-tmp
jboss-as-7.2.0.Final-src.tar.gz
jboss-as-7.2.0.Final-src.zip
jboss-as-7.2.0.Final.tar.gz
jboss-as-7.2.0.Final.zip

USE jboss-as-7.2.0.Final.tar.gz


Creating Services
-----------------
1. Create a new JBoss 7 Domain Controller service in the catalog.

- Use the following values for the service details:

	Name: JBoss 7 Domain Controller
	Version: 7
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit+, CentOS 5.6 64bit+, RHEL 6.1 32bit*, RHEL 6.1 64bit*"
	Supported Components: war, ear and script

    See jbossdomaincontrollerdetails.png for an example.

- Add properties similar to what is shown in jbossdomaincontrollerproperties.png
 -  host_master - The JBoss 7 host.xml file for the master configuration (downloadable content)
 -  domain_master - The JBoss 7 domain.xml file for the master configuration (downloadable content)
 -  common_utils - this a place for storing extra utility methods (downloadable content)
 -  cluster_group - this a place for storing extra utility methods (downloadable content)
 -  global_conf - the standard darwin_global.conf (downloadable content)
 -  JBOSS_MGMT_PWD - the mgmt password free to chose
 -  JBOSS_NAME_AND_VERSION - this is a legacy carry over and is basically the name of directory created from the zip
 -  JBOSS_MGMT_USER - the mgmt user free to chose
 -  cluster_nodenames_and_passwords - An array of key:value pairs for each slaves slave_name:slave_password
 -    each slavename needs to be unique in the cluster an example of what this could look like would be:
 -    ["slave-1:slave123","slave-2:slave456"] 
 -  zip_url - This is the url of the JBoss-as-7xx.zip file (downloadable content)
 -  domain_init_script - The domain controller service script (downloadable content)
 -  self_ip - This is the ip address of this vm (bind this property to self:ip in the blueprint)
 -  master_cluster_user - This is the username for the hornetmq cluster setting
 -  master_cluster_password - This is the password for the hornetmq cluster setting

  The host-master.xml, jboss-as-domain.sh and darwin_global.conf are located in the Content directory.
  These need to be configured to be downloadable content in the properties

- Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.
  For each one use the corresponding prefixed jboss7-domaincontroller*.sh file included.


2. Create a new JBoss 7 Slave service in the catalog.
----------------------------------------------------
- Use the following values for the service details:

	Name: JBoss 7 Slave Instance
	Version: 7
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit+, CentOS 5.6 64bit+, RHEL 6.1 32bit*, RHEL 6.1 64bit*"
	Supported Components: war, ear and script

    See jbossslavedetails.png for an example.

- Add properties similar to what is shown in jbossslaveproperties.png
 -  cluster_group - this a place for storing extra utility methods (downloadable content)
 -  slave_name - This is a unique slave name in the cluster, it must be an entry in the domain controller's cluster_nodenames_and_passwords array
 -  slave_password - This is the password for this slave and is entered in the domain controller's cluster_nodenames_and_passwords array
 -  JBOSS_MGMT_PWD - the mgmt password free to chose
 -  JBOSS_NAME_AND_VERSION - this is a legacy carry over and is basically the name of directory created from the zip
 -  global_conf - the standard darwin_global.conf (downloadable content)
 -  self_ip - This is the ip address of this vm (bind this property to self:ip in the blueprint)
 -  zip_url - This is the url of the JBoss-as-7xx.zip file (downloadable content)
 -  JBOSS_MGMT_USER - the mgmt user free to chose
 -  domain_init_script - The slave service script (downloadable content)
 -  host_slave - The JBoss 7 host.xml file for the slave configuration (downloadable content)
 -  master_ip - Bind this to the domain controllers ip in the blueprint, this is set in the JBOSS_HOME/system.properties to communicate with controller.
 -  master_cluster_user - Bind this to the domain controllers master_cluster_user property
 -  master_cluster_password - Bind this to the domain controllers master_cluster_password property
  
  The host-slave.xml, jboss-as-domain-slave.sh and darwin_global.conf are located in the Content directory.
  These need to be configured to be downloadable content in the properties

- Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.
  For each one use the corresponding prefixed jboss7-slave*.sh file included.

* If using Red Hat Enterprise Linux
  You will need to establish a connection to Red Hat Network prior to starting the flow. This is done through the addition of a task.
  
  1.) On the Tasks tab of the Catalog create a new Task and add the RHN Registration Task.
  2.) For the script field use the rhn-task.sh included.
  3.) Setup the properties as shown in the rhn.png for example

+ If using CentOS then follow similar steps
  1.) On the Tasks tab of the Catalog create a new Task and add the Yum Repository Task
  2.) For the script field use the yum-task.sh included.
  3.) Setup the properties as shown in the yum.png for example

-  Download the Jboss 7 Application Server to NFS server.
   You can usually get a copy here http://www.jboss.org/jbossas/downloads/

NOTES:

* Each property is explained in the "Description" field of the property.
  See jbosserviceproperties.png for an example.
  
* The darwin_global.conf file is an example how you can make shared properties accessible through all the types of scripts.
  Where you see '. $global_conf', this is mapped to the global_conf content property.

* Most properties are set to a default value. And they can be modified in the blueprint before the deployment.


Adding the Blueprint
--------------------
- Create a new application, call it JBoss 7 Clustered for example
- Drag 3 RHEL 6.1 or CentOS OS templates onto the blueprint area
- On one drag the Domain Controller service you created in step 1, configure the properties a described.
- On the other two drag the Slave service you created in step 2, configure the properties as described, remember to give each a unique name.
- Draw a dependency from each slave to the domain controller since the the domain controller must be deployed and running before the slaves.

When you are done it should look something like: jbossdomaincontrollerbp.png

Now you can deploy, step through each of the steps verifying the values configured in the blueprint and deploy in the final step.
You should see the deployment succeed and look something like: jbossdomaincontrollerdeployed.png


Some additional files of interest
---------------------------------
/etc/jboss-as/jboss-as.conf - Contains properties for controlling jboss service startup and shutdown
/etc/init.d/jboss - The jboss service script
/var/log/jboss-as/console.log - The service log output

JBoss Cluster Howto: https://docs.jboss.org/author/display/AS71/AS7+Cluster+Howto


Verify Deployment
-----------------
Validation of the deploymsent setup can be done either from 

1.) From either the webconsole at http://<domain controller ip>:9990/console
Note: on the 7.2.0 release the console login just gave me a spinner and appeared to be hung
2.) From the CLI
[root@JBoss7-BDULH8AK bin]# $JBOSS_HOME/bin/jboss-cli.sh --controller=10.140.17.137
You are disconnected at the moment. Type 'connect' to connect to the server or 'help' for the list of supported commands.
[disconnected /] connect
[domain@10.140.17.137:9999 /] ls -l /host
master
slave1
slave2
[domain@10.140.17.137:9999 /] 

