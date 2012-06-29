# Creating a vFabric tc Server Service in Application Director

The set of scripts in this GitHub repository help you create a **vFabric tc Server** service in vFabric Application Director to which you can deploy your applications.  The three scripts correspond to the three lifecycles stages of a service: 

* `tcserver-install.sh`:  Installs vFabric tc Server using an RPM from the VMware RPM repository.  
* `tcserver-config.sh`:  Configures the new tc Server service.   Configuration includes adding a sample application (Spring Travel) that is automatically deployed as soon as you start the service.
* `tcserver-start.sh`: Starts the service.  

You do not run these scripts yourself.  Rather, you specify their contents when you create a new service using the Application Director wizard.

To create a vFabric tc Server service in vFabric Application Director, follow these steps:

1.   [Add a new service to the catalog.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-68665799-52B6-4B70-82CE-9F03C60958FB.html)

2.   When entering details about the new service, use the following values, as shown in [this screenshot](service-create.png):

     **Name**: `vFabric tc Server 5.1.0`  
     **Service Version**: `5.1.0`  
     **Tags**: `Application Servers`  
     **Supported OSes**: `RHEL32 5.x` `RHEL64 5.x` `RHEL32 6.x` `RHEL64 6.x`  
     **Supported Components**:  `JAR`, `WAR`, `SCRIPT`  
3.   Add the following required Properties to the service, as shown in [this screenshot](service-properties.png):
<table border=1>
    <tr>
      <th style="background-color:#F0F0F0">Property Name</th>
      <th style="background-color:#F0F0F0">Data Type</th>
      <th style="background-color:#F0F0F0">Value</th>
    </tr>
    <tr>
       <td>global_conf</td>
       <td>Content</td>
       <td>`https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf`</td>
    </tr> 
    <tr>
        <td>WAR</td>
        <td>Content</td>
        <td>`http://${darwin.server.ip}/artifacts/app-components/spring-travel/swf-booking-mvc-2.0.3.RELEASE.war`</td>
    </tr> 
    <tr>
        <td>TCSERVER_HOME</td>
        <td>String</td>
        <td>`/opt/vmware/vfabric-tc-server-standard`</td>
    </tr> 
</table>
4.  Copy and paste the contents of the `tcserver-install.sh`, `tcserver-config.sh`, and `tcserver-start.sh` scripts to the corresponding service lifecycle stages under the Action tab, as shown in [this screenshot](service-actions.png).

# Creating and Deploying an Application that Uses a vFabric tc Server Service  

After you create a vFabric tc Server service in Application Director, you can start using it to deploy applications. The basic steps are as follows: 

1.   [Create a new Application.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-E5C015BA-415C-43A8-A144-8CFBB6117EE3.html)

2.   Set the following properties:  

     **Name**: Spring Travel Application  

3.   On the Blueprint canvas, drag and drop the RHEL 5 or 6 OS template from the Logical Templates menu.

4.   From the Services menu, select **vFabric tc Server 5.1.0** and drop it under the OS.  

5.   Save the Application.

6.   Click Deploy and step through the deployment wizard.  When you finish, your application will be deployed to a tc Server instance.
