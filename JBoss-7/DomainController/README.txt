This demonstrates creating a domain controller or master/slave JBoss 7 configuration.
  
!! IMPORTANT POINT REGARDING PROPERTIES !!
When dealing with setting up properties in this demo take care to notice the Property Type.
If you are downloading any file this must be of type content. If you use another type there is a good chance your deployment will fail.

There are two services as part of this blueprint 
1. The domain controller which performs maitenance and coordination for the cluster, it itself does not host applications
2. The slaves that register with the controller and are responsible for servicing applications.

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
    
  domain_init_script - The domain controller service script (downloadable content)
  host_master - The JBoss 7 host.xml file for the master configuration (downloadable content)
  self_ip - This is the ip address of this vm (bind this property to self:ip in the blueprint)
  cluster_nodenames_and_passwords - An array of key:value pairs for each slaves slave_name:slave_password
    each slavename needs to be unique in the cluster an example of what this could look like would be:
    ["slave-1:slave123","slave-2:slave456"] 
  zip_url - This is the url of the JBoss-as-7xx.zip file (downloadable content)
  JBOSS_MGMT_USER - the mgmt user free to chose
  JBOSS_MGMT_PWD - the mgmt password free to chose
  JBOSS_NAME_AND_VERSION - this is a legacy carry over and is basically the name of directory created from the zip
  global_conf - the standard darwin_global.conf (downloadable content)

  The host-master.xml, jboss-as-domain.sh and darwin_global.conf are located in the Content directory.
  These need to be configured to be downloadable content in the properties

- Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.
  For each one use the corresponding prefixed jboss7-domaincontroller*.sh file included.

2. Create a new JBoss 7 Slave service in the catalog.

- Use the following values for the service details:

	Name: JBoss 7 Slave Instance
	Version: 7
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit+, CentOS 5.6 64bit+, RHEL 6.1 32bit*, RHEL 6.1 64bit*"
	Supported Components: war, ear and script

    See jbossslavedetails.png for an example.

- Add properties similar to what is shown in jbossslaveproperties.png
  
  domain_init_script - The slave service script (downloadable content)
  host_slave - The JBoss 7 host.xml file for the slave configuration (downloadable content)
  self_ip - This is the ip address of this vm (bind this property to self:ip in the blueprint)
  master_ip - Bind this to the domain controllers ip in the blueprint, this is set in the JBOSS_HOME/system.properties to communicate with controller.
  zip_url - This is the url of the JBoss-as-7xx.zip file (downloadable content)
  JBOSS_MGMT_USER - the mgmt user free to chose
  JBOSS_MGMT_PWD - the mgmt password free to chose
  JBOSS_NAME_AND_VERSION - this is a legacy carry over and is basically the name of directory created from the zip
  global_conf - the standard darwin_global.conf (downloadable content)
  slave_name - This is a unique slave name in the cluster, it must be an entry in the domain controller's cluster_nodenames_and_passwords array
  slave_password - This is the password for this slave and is entered in the domain controller's cluster_nodenames_and_passwords array
  
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
----------------------

- Create a new application, call it JBoss 7 Clustered for example
- Drag 3 RHEL 6.1 or CentOS OS templates onto the blueprint area
- On one drag the Domain Controller service you created in step 1, configure the properties a described.
- On the other two drag the Slave service you created in step 2, configure the properties as described, remember to give each a unique name.
- Draw a dependency from each slave to the domain controller since the the domain controller must be deployed and running before the slaves.

When you are done it should look something like: jbossdomaincontrollerbp.png

Now you can deploy, step through each of the steps verifying the values configured in the blueprint and deploy in the final step.
You should see the deployment succeed and look something like: jbossdomaincontrollerdeployed.png

One Final Step
--------------

At the moment the slaves themselves are unaware of the domain controller and need one property set before they can be started.
- With an editor, edit $JBOSS_HOME/system.properties
- After the jboss.domain.master.address= replace the text with the address or fully qualified hostname of the controller
- Start jboss service by issuing the command as root: service jboss start

After that you can monitor the logs in each of the master and slave in /var/log/jboss-as/console.log to verify that each slave was registered
with the domain controller.
