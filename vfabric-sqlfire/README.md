# Creating a vFabric SQLFire Service in Application Director

The scripts in this GitHub repository help you create a **vFabric SQLFire** service in vFabric Application Director that your applications can use to manage in-memory SQL databases using SQLfire.  The scripts correspond to some of the lifecycles stages of a service: 

* `sqlfire-install.sh`:  Installs vFabric SQLFire using an RPM from the VMware RPM repository. 
* `sqlfire-start.sh`: Starts a SQLFire locator process, starts a cluster of two SQLFire servers, and then uses the sample scripts in the `quickstart` directory under the main installation directory to create sample tables and load data into them.

You do not run these scripts yourself.  Rather, you specify their contents when you create a new service using the Application Director wizard.

**Note**: Because it is assumed that you already know how to use Application Director, the following procedures concentrate on showing specific vFabric SQLFire information rather than detailed steps about using the user interface.  See the [documentation](http://pubs.vmware.com/appdirector-1/index.jsp) for general information about using Application Director.

To create a vFabric SQLFire service in vFabric Application Director, follow these steps:

1.   [Add a new service to the catalog.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-68665799-52B6-4B70-82CE-9F03C60958FB.html)

2.   When entering details about the new service, use the following values, as shown in [this screenshot](vfabric-sqlfire/sqlfire-create.png): 

    * **Name**: `vFabric SQLFire 1.0`
    * **Service Version**: `1.0`
    * **Tags**: `Database Servers`  
    * **Supported OSes**: `CentOS32 5.6.0` `CentOS64 6.0.0` `CentOS64 5.6.0` `RHEL32 6.1.0` `RHEL64 6.1.0`  
    * **Supported Components**:  `SCRIPT`  


3.   Add the following required Properties to the service, as shown in [this screenshot](vfabric-sqlfire/sqlfire-properties.png):

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

4.  Copy and paste the contents of the `sqlfire-install.sh` and `sqlfire-start.sh` scripts to the corresponding service lifecycle stages under the Actions tab.


# Creating and Deploying an Application that Uses a vFabric SQLFire Service  

After you create a vFabric SQLFire service in Application Director, you can start using it in your applications to manage your in-memory SQL databases.   The SQLFire service automatically starts a locator process and cluster of SQLFire servers and you can use the SQLFire APIs to connect to the cluster and execute SQL statements.  The basic steps are as follows: 

1.   [Create a new Application.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-E5C015BA-415C-43A8-A144-8CFBB6117EE3.html)

3.   On the Blueprint canvas, drag and drop an RHEL or CentOS template from the Logical Templates menu.

4.   From the Services menu, select **vFabric SQLFire 1.0** and drop it under the OS.  

5.   Save the Application.

6.   Click Deploy and step through the deployment wizard.  When you finish, the SQLFire locator process and cluster of servers will have started and your applications can connect to it to manage the data in the in-memory SQL database.  

See the [vFabric SQLFire documentation](http://pubs.vmware.com/vfabric51/topic/com.vmware.vfabric.sqlfire.1.0/about_users_guide.html) for detailed information about using the SQLFire APIs in your application.
