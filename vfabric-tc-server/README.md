Instructions to create vFabric tc Server service for Application Director
-------------------------------------------------------------------------

The set of scripts provided here helps you install, configure and deploy
**vFabric tc Server** to vFabric Application Director.

To create vFabric tc Server service in vFabric Application Director follow these steps:

1.   Create a new service in the catalog

2.   Use following values for service details

	Name: vFabric tc Server 5.1.0 
	Service Version: 5.1.0  
	Tags: "Application Servers"  
	Supported OSes: "RHEL32 5.x", "RHEL64 5.x", "RHEL32 6.x", "RHEL64 6.x"  
	Supported Components:  JAR, WAR, SCRIPT  
[Here's a screenshot](https://github.com/vmware-applicationdirector/solutions/blob/staging/vfabric-tc-server/service-create.png)  
3.   Add following Properties to the service:

    This example uses the values posted below as defaults.   To change any of these
    values, add the Property Name as shown below as individual properties in your 
    service definition in the ApplicationDirector Catalog.   The value specified after
    the Property name is the Type to use for the property (i.e. String, Content, Array etc)

    **Required Properties**  
    These are the properties you must add in order for this sample script to work. The property
    is added when you create your service definition in the ApplicationDirector Catalog.    
    `Property Name [Type]    Property Value`  
    .................................................................................................  
    `global_conf [Content]   https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf`  
    `WAR [Content]           http://${darwin.server.ip}/artifacts/app-components/spring-travel/swf-booking-mvc-2.0.3.RELEASE.war`  
    `TCSERVER_HOME [String]  /opt/vmware/vfabric-tc-server-standard`  
[Here's a screenshot](https://github.com/vmware-applicationdirector/solutions/blob/staging/vfabric-tc-server/service-properties.png)  
4.   Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.  
[Here's a screenshot](https://github.com/vmware-applicationdirector/solutions/blob/staging/vfabric-tc-server/service-actions.png)  


Create and Deploy Application using vFabric tc Server service  
-------------------------------------------------------------  

Once you have finished creating vFabric tc Server service you should see it under existing and new Applications.  

1.   Create a new Application  
2.   Set following properties:  
     Name : Spring Travel Application  
3.   On Blueprint canvass drag and drop RHEL 5 or 6 OS template from Logical Templates menu  
4.   From Services menu select **vFabric tc Server 5.1.0** and drop it under OS  
5.   Save Application  
6.   Click Deploy and step through deployment wizard  
