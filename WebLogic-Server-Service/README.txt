To add the WebLogic server to vFabric Application Director follow the steps below.

1. Create a new service in the catalog.

2. Use the following values for the service details:

	Name: Oracle WebLogic Server
	Version: 12.1.1
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit"
	Supported Components: jar, war, and script


3. Add the properties as listed in the <properties.jpg> file.

4. Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.

5. Download the WebLogic Server installer binaries to an NFS server.


NOTES:

* Each property is explained in the "Description" field of the property.

* The most properties are set to a default value. And they can be modified at blueprint phase or deployment phase.

* The Property "webloigc_server_ip" can be commonly set to "self:ip" or any available nic ip.

* The property "nfs_path": it is the nfs path to the WebLogic Server installer, for example nfs_path=10.140.16.224:/disk2/software/weblogic12.1.1.

	* The WebLogic Server installer can be download from here, and the type of the installer needs to be .bin file.

	* The installer that is located to nfs_path needs to be named "webLogicInstaller.bin", which means if your installer name is other name than that, you can either rename it or create a symbolic name of "webLogicInstaller.bin" to the actual installer file.


***
To use the WebLogic Server service in a sample application blueprint follow these steps:

1. In the App Director UI, create a new application from the pane "Applications".

2. Inside of the blueprint window of the application, add a CentOS 5.6 32bit logical template and drag the Oracle WebLogic Server 12.1.1 service onto the template.

3. Click on the service you just dragged onto the template. In the Properties pane, fill/adjust in the values for the properties as necessary. The default values are commonly used. See the NOTES above for details.

4. Add a WAR application component to the WebLogic service and name it DemoApp.

5. Add and update property value to match those in the <weblogic-demoapp-properties.png> file.  Be sure to put the demoapp.war file on a web server and set the URL for the "war_file" properly.

6. Add the <demoapp-install.sh> to the install lifecycle of the DemoApp WAR component.

7. Click "deploy" icon to start the deployment process.

8. Follow the wizard steps to build up the deployment profile. At the step "Execution Plan", the yum repository script may need to be added before the WebLogic Server service install script.

9. The application is ready to be deployed.  Click on "Deploy".

10. Once the deployment finishes, check the service log from the "Execution Plan" pane of the deployment to find the start status of the WebLogic Server.

11. Log into the WebLogic server console at http://<deployed IP>:7001/console/login/LoginForm.jsp

12. Log into the application at http://<deployed IP>:7001/TestWebApp/


