# Creating a vFabric GemFire Service in Application Director

The scripts in this GitHub repository help you create a **vFabric GemFire** service in vFabric Application Director that your applications can use to manage distributed data with GemFire.  The scripts correspond to some of the lifecycles stages of a service: 

* `gemfire-install.sh`:  Installs vFabric GemFire using an RPM from the VMware RPM repository and makes the GemFire libraries available for your applications to use. 
* `gemfire-start.sh`: Starts a GemFire `cacheserver` process.

You do not run these scripts yourself.  Rather, you specify their contents when you create a new service using the Application Director wizard.

**Note**: Because it is assumed that you already know how to use Application Director, the following procedures concentrate on showing specific vFabric GemFire information rather than detailed steps about using the user interface.  See the [documentation](http://pubs.vmware.com/appdirector-1/index.jsp) for general information about using Application Director.

To create a vFabric GemFire service in vFabric Application Director, follow these steps:

1.   [Add a new service to the catalog.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-68665799-52B6-4B70-82CE-9F03C60958FB.html)

2.   When entering details about the new service, use the following values, as shown in [this screenshot](vfabric-gemfire/gemfire-create.png): 

    * **Name**: `vFabric GemFire 6.6`
    * **Service Version**: `6.6`
    * **Tags**: `Database Servers`  
    * **Supported OSes**: `CentOS32 5.6.0` `CentOS64 6.0.0` `CentOS64 5.6.0` `RHEL32 6.1.0` `RHEL64 6.1.0`  
    * **Supported Components**:  `SCRIPT`  


3.   Add the following required Properties to the service, as shown in [this screenshot](vfabric-gemfire/gemfire-properties.png):

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
</table>

4.  Copy and paste the contents of the `gemfire-install.sh` and `gemfire-start.sh` scripts to the corresponding service lifecycle stages under the Actions tab.


# Creating and Deploying an Application that Uses a vFabric GemFire Service  

After you create a vFabric GemFire service in Application Director, you can start using it in your applications to manage your distributed data.   The GemFire service automatically starts a `cacheserver` on the VM on which it is installed, and your application can use the GemFire APIs to connect to this `cacheserver` and perform data management operations.  The basic steps are as follows: 

1.   [Create a new Application.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-E5C015BA-415C-43A8-A144-8CFBB6117EE3.html)

3.   On the Blueprint canvas, drag and drop an RHEL or CentOS template from the Logical Templates menu.

4.   From the Services menu, select **vFabric GemFire 6.6** and drop it under the OS.  

5.   Save the Application.

6.   Click Deploy and step through the deployment wizard.  When you finish, the GemFire `cacheserver` process will have started and your applications can connect to it to mange their distributed data.  

See the [vFabric GemFire documentation](http://pubs.vmware.com/vfabric51/topic/com.vmware.vfabric.gemfire.6.6/about_gemfire.html) for detailed information about using the GemFire APIs in your application to create regions, populate them with data, and then perform CRUD operations on the data.
