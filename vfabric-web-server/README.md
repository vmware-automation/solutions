# Creating a vFabric Web Server Service in Application Director

The set of scripts in this GitHub repository help you create a **vFabric Web Server** service in vFabric Application Director.  vFabric Web Server is the HTTP Server and load-balancing component of vFabric Suite. The three scripts correspond to the three lifecycles stages of a service: 

* `webserver-install.sh`:  Installs vFabric Web Server using an RPM from the VMware RPM repository.  
* `webserver-config.sh`:  Configures the new vFabric Web Server service.   
* `webserver-start.sh`: Starts the service.  

You do not run these scripts yourself.  Rather, you specify their contents when you create a new service using the Application Director wizard.

**Note**: Because it is assumed that you already know how to use Application Director, the following procedures concentrate on showing specific vFabric Web Server information rather than detailed steps about using the user interface.  See the [documentation](http://pubs.vmware.com/appdirector-1/index.jsp) for general information about using Application Director.

To create a vFabric Web Server service in vFabric Application Director, follow these steps:

1.   [Add a new service to the catalog.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-68665799-52B6-4B70-82CE-9F03C60958FB.html)

2.   When entering details about the new service, use the following values, as shown in [this screenshot](vfws-create.png):

    **Name**: `vFabric Web Server 5.1`  
    **Service Version**: `5.1`  
    **Tags**: `Web Servers`  
    **Supported OSes**: `CentOS32 5.6.0` `CentOS64 6.0.0` `CentOS64 5.6.0` `RHEL32 6.1.0` `RHEL64 6.1.0`  
    **Supported Components**: `SCRIPT` `Other`

3.   Add the following required Properties to the service, as shown in [this screenshot](vfws-properties.png):
<table border=1>
    <tr>
      <th style="background-color:#F0F0F0">Property Name</th>
      <th style="background-color:#F0F0F0">Type</th>
      <th style="background-color:#F0F0F0">Value</th>
    </tr>
    <tr>
       <td>global_conf</td>
       <td>Content</td>
       <td>https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf</td>
    </tr> 
    <tr>
        <td>http_node_ips</td>
        <td>Array</td>
        <td></td>
    </tr> 
    <tr>
        <td>webserver_ip</td>
        <td>String</td>
	<td></td>
    </tr> 
</table>

    Leave the values of `http_node_ips` and `webserver_ip` blank.  Use default values for the other columns, [as shown](vfws-properties.png).

4.  Copy and paste the contents of the `webserver-install.sh`, `webserver-config.sh`, and `webserver-start.sh` scripts to the corresponding service lifecycle stages under the Actions tab.

# Creating and Deploying an Application that Uses a vFabric Web Server Service  

After you create a vFabric Web Server service in Application Director, you can start using it in your deployed applications.  You can use it as a standalone HTTP Server, or you can use it as a load-balancer in front of one or more vFabric tc Server instances by specifying the IP addresses of their VMs at deployment time.  The basic steps are as follows: 

1.   [Create a new Application.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-E5C015BA-415C-43A8-A144-8CFBB6117EE3.html)

3.   On the Blueprint canvas, drag and drop the appropriate OS template (such as RHEL or CentOS 6) from the Logical Templates menu.

4.   From the Services menu, select **vFabric Web Server 5.1** and drop it under the OS.  

5.   Save the Application.

6.   Click Deploy and step through the deployment wizard.  

    If you want to deploy vFabric Web Server standalone, do not enter any values for its properties.  If you want the vFabric Web Server instance to load balance between two or more vFabric tc Server instances, enter their IP addresses as Array values to the `http_node_ips` property, for example `["10.5.120.2", "10.5.120.3"]`.
