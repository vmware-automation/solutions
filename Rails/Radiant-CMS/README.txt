This example demonstrates creating a service which deploys a Radiant CMS application running on Rails
  
!! IMPORTANT POINT REGARDING PROPERTIES !!
When dealing with setting up properties in this demo take care to notice the Property Type.
If you are downloading any file this must be of type content. If you use another type there is a good chance your deployment will fail.

Service Creation Steps

1. Create a new Rails service in the catalog
Radiant CMS requires a Rails environment to run.

- Use the following values for the service details:

	Name: Rails
	Version: 3.2.6
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit, CentOS 5.6 64bit"
	Supported Components: Script, Ruby Gem

    See railsservicedetails.png for an example.

- Set the service properties for both the target ruby and rails version.
  See railsserviceproperties.png for an example.

-  Add the rails-install.sh script contents to the install service lifecycle.

2. Create a MySQL service in the catalog

- Use the following values for the service details:

	Name: MySQL
	Version: 5.0.0
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit, CentOS 5.6 64bit"
	Supported Components: SQL Script

    See mysqlservicedetails.png for an example.

- Set the MySQL service properties required.
  See mysqlservicepproperties.png for an example.

- Add the mysql-install.sh and mysql-configure.sh scripts contents to each of the corresponding service lifecycles.


NOTES:
***

 The darwin_global.conf file is an example how you can make shared properties accessible through all the types of scripts.
 Where you see '. $global_conf', this is mapped to the global_conf content property.

***

Application Creation Steps

To create the Radiant-CMS application blueprint follow these steps:

1. In the App Director UI, create a new application from the pane "Applications", call it Radiant CMS for example.

2. Inside of the blueprint window of the application, add a CentOS 5.6 32bit logical template and drag the Rails Service you created in the Service Creation Steps onto the template.

3. Click on the service you just dragged onto the template. In the Properties pane, fill/adjust in the values for the properties as necessary. 

4. Add a RUBY_GEM application component to the Rails service and name it Radiant_CMS.

5. Add and update property values to be similar to those seen in radiantcmsgemproperties.png. 

6. Add the radiantcmsgem-install.sh to the install lifecycle of the Radiant CMS component.

7. Drag the MySQL Service you created in the Service Creation Steps onto the same templates as the Rails Service.

8. Click on the service you just dragged onto the template. In the Properties pane, fill/adjust in the values for the properties as necessary. 

9. Define a dependency relationship from the Radiant Gem Component to the MySQL Service. This ensures that the MySQL Service will be configured prior to Radiant since it is unable to complete without it. 
   
   You do this by:
   1. Selecting the "Add Relation" link icon in the upper right of the toolbar
   2. Draw a line connecting the Radiant CMS Application Component to the MySQL Service

   When you are done it should look something like radiantbpcomponents.png

7. Click "deploy" icon to start the deployment process.

8. Follow the wizard steps to build up the deployment profile. 
   At the step "Execution Plan", add the Yum Repository Config task included with Application Director and fill in the properties as necessary.

9. The application is ready to be deployed.  Click on "Deploy".

10. Once the deployment finishes, check the service log from the "Execution Plan" pane of the deployment to find the start status of the Radiant CMS Application. 

11. Go to http://<deployed ip> and login with username: admin and password: radiant
