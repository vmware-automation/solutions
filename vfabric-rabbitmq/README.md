# Creating a vFabric RabbitMQ Service in Application Director

The scripts in this GitHub repository help you create a **vFabric RabbitMQ** service in vFabric Application Director that your applications can use to manage messaging traffic with RabbitMQ.  The scripts correspond to some of the lifecycles stages of a service: 

* `rabbitmq-install.sh`:  Installs vFabric RabbitMQ using an RPM from the VMware RPM repository.  This script also installs Erlang, which is a RabbitMQ software requirement.
* `rabbitmq-start.sh`: Starts a RabbitMQ `rabbitmq-server` process.

You do not run these scripts yourself.  Rather, you specify their contents when you create a new service using the Application Director wizard.

**Note**: Because it is assumed that you already know how to use Application Director, the following procedures concentrate on showing specific vFabric RabbitMQ information rather than detailed steps about using the user interface.  See the [documentation](http://pubs.vmware.com/appdirector-1/index.jsp) for general information about using Application Director.

To create a vFabric RabbitMQ service in vFabric Application Director, follow these steps:

1.   [Add a new service to the catalog.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-68665799-52B6-4B70-82CE-9F03C60958FB.html)

2.   When entering details about the new service, use the following values, as shown in [this screenshot](vfabric-rabbitmq/rabbitmq-create.png): 

    * **Name**: `vFabric RabbitMQ 2.8`
    * **Service Version**: `2.8`
    * **Tags**: `Messaging Servers`  
    * **Supported OSes**: `CentOS32 5.6.0` `CentOS64 6.0.0` `CentOS64 5.6.0` `RHEL32 6.1.0` `RHEL64 6.1.0`  
    * **Supported Components**:  `SCRIPT`  

3.  Copy and paste the contents of the `rabbitmq-install.sh` and `rabbitmq-start.sh` scripts to the corresponding service lifecycle stages under the Actions tab.

The RabbitMQ service does not require you to add service properties.

# Creating and Deploying an Application that Uses a vFabric RabbitMQ Service  

After you create a vFabric RabbitMQ service in Application Director, you can start using it in your applications to manage messaging traffic.   The RabbitMQ service automatically starts a `rabbitmq-server` on the VM on which it is installed, and your application can use the RabbitMQ APIs to connect and perform messaging operations.  The basic steps are as follows: 

1.   [Create a new Application.](http://pubs.vmware.com/appdirector-1/topic/com.vmware.appdirector.using.doc/GUID-E5C015BA-415C-43A8-A144-8CFBB6117EE3.html)

3.   On the Blueprint canvas, drag and drop an RHEL or CentOS template from the Logical Templates menu.

4.   From the Services menu, select **vFabric RabbitMQ 2.8** and drop it under the OS.  

5.   Save the Application.

6.   Click Deploy and step through the deployment wizard.  When you finish, the `rabbitmq-server` process will have started and your applications can connect to it to mange their messaging traffic.  

See the [vFabric RabbitMQ documentation](http://pubs.vmware.com/vfabric51/topic/com.vmware.vfabric.rabbitmq.2.8/index.html) for detailed information about using the RabbitMQ APIs in your application.
