This example demonstrates creating a service which deploys a JBoss 7 standalone intance followed by a sample petcare application deployed to it.  
To add the JBoss 7 Application Server to vFabric Application Director follow the steps below.
  
!! IMPORTANT POINT REGARDING PROPERTIES !!
When dealing with setting up properties in this demo take care to notice the Property Type.
If you are downloading any file this must be of type content. If you use another type there is a good chance your deployment will fail.

Steps

1. Create a new service in the catalog.

2. Use the following values for the service details:

	Name: JBoss
	Version: 7
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit+, CentOS 5.6 64bit+, RHEL 6.1 32bit*, RHEL 6.1 64bit*"
	Supported Components: war, ear and script

    See jbossservicedetails.png for an example.

* If using Red Hat Enterprise Linux
  You will need to establish a connection to Red Hat Network prior to starting the flow. This is done through the addition of a task.
  
  1.) On the Tasks tab of the Catalog create a new Task and add the RHN Registration Task.
  2.) For the script field use the rhn-task.sh included.
  3.) Setup the properties as shown in the rhn.png for example

+ If using CentOS then follow similar steps
  1.) On the Tasks tab of the Catalog create a new Task and add the Yum Repository Task
  2.) For the script field use the yum-task.sh included.
  3.) Setup the properties as shown in the yum.png for example

3. Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.
   For each one use the corresponding prefixed jboss7*.sh file included.

4. Download the Jboss 7 Application Server to NFS server.
   You can usually get a copy here http://www.jboss.org/jbossas/downloads/

NOTES:

* Each property is explained in the "Description" field of the property.
  See jbosserviceproperties.png for an example.
  

* The darwin_global.conf file is an example how you can make shared properties accessible through all the types of scripts.
  Where you see '. $global_conf', this is mapped to the global_conf content property.

* Most properties are set to a default value. And they can be modified in the blueprint before the deployment.

***
To use the JBoss Server service in the sample petcare application blueprint follow these steps:

1. In the App Director UI, create a new application from the pane "Applications", call it JBoss 7 Petcare for example.

2. Inside of the blueprint window of the application, add a CentOS 5.6 32bit logical template and drag the JBoss 7 service onto the template.

3. Click on the service you just dragged onto the template. In the Properties pane, fill/adjust in the values for the properties as necessary. 
   The default values are commonly used. See the NOTES above for details.

4. Add a WAR application component to the JBoss service and name it Petcare.

5. Add and update property values to be similar to those seen in petcarewarproperties.png. 
   Be sure to put the petcare.war file on a web server and set the URL for the "war_file" properly.

6. Add the petcarewar-start.sh to the install lifecycle of the Petcare WAR component.

7. Click "deploy" icon to start the deployment process.

8. Follow the wizard steps to build up the deployment profile. 
   At the step "Execution Plan", the yum repository script may need to be added before the Redhat Server service install script.

9. The application is ready to be deployed.  Click on "Deploy".

10. Once the deployment finishes, check the service log from the "Execution Plan" pane of the deployment to find the start status of the JBoss 7 server. 

11. View the JBoss 7 landing page at http://<deployed ip>:8080/

12. View the sample petcare app at http://<deployed ip>:8080/petcare/

13. You can login to the administration console at http://<deployed ip>:9990/console, the default user/password is admin/changeme
