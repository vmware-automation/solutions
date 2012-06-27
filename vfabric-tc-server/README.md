The set of scripts provided here helps you install, configure and deploy
vFabric tc Server to vFabric Application Director.

To create vFabric tc Server service in vFabric Application Director follow these steps:

1. Create a new service in the catalog.
2. Use following values for service details:
	Name: vFabric tc Server
	Version: 2.7.0.RELEASE
	Tags: "Application Servers"
	Supported OSes: "RHEL 5 32bit"
	Supported Components:  war
3. Add following properties to the service:

This example uses the values posted below as defaults.   To change any of these
values, add the Property Name as shown below as individual properties in your 
service definition in the ApplicationDirector Catalog.   The value specified after
the Property name is the Type to use for the property (i.e. String, Content, Array etc)
There are two types of properties for this script: Required and Optional.  Both are 
listed below.

REQUIRED PROPERTIES:
These are the properties you must add in order for this sample script to work. The property
is added when you create your service definition in the ApplicationDirector Catalog.  
Property Description:                                Property Value settable in blueprint [type]:
--------------------------------------------------------------------------------------------
Location of global configuration data                global_conf [Content]
value: https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf
                                                           
OPTIONAL PROPERTIES:
Property Description:                                Property Name settable in blueprint:
--------------------------------------------------------------------------------------------
which java to use                                    JAVA_HOME [String]
name of the new tc server instance to be created      INSTANCE_NAME [String]
which java to use                                     JAVA_HOME [String]
minimum version of java required                      REQUIRED_VERSION [String]
application war to be downloaded and deployed         WAR [Content]
tc Server template used to create new instance        TCSERVER_TEMPLATE [String]
application name if different from war                APPLICATION_NAME [String]

4. Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.
