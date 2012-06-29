This demonstrates a Rails service creation.
  
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

NOTES:
***

 The darwin_global.conf file is an example how you can make shared properties accessible through all the types of scripts.
 Where you see '. $global_conf', this is mapped to the global_conf content property.

***

Application Creation Steps

To see an example of how to use this service with an application view the Radiant-CMS sample.


