This demonstrates a Rails service creation.
Installs:
* Ruby 2.0.0
* Rails 4.0.0
* Passenger (apache2-module)
  
!! IMPORTANT POINT REGARDING PROPERTIES !!
When dealing with setting up properties in this demo take care to notice the Property Type.
If you are downloading any file this must be of type content. If you use another type there is a good chance your deployment will fail.

Service Creation Steps

1. Create a new Rails service in the catalog

- Use the following values for the service details:

	Name: Rails
	Version: 4.0.0
	Tags: "Application Servers"
	Supported OSes: "CentOS 5.6 32bit, CentOS 5.6 64bit"
	Supported Components: Script, Ruby Gem

    See railsservicedetails.png for an example.

- Set the service properties for both the target ruby and rails version.
  See railsserviceproperties.png for an example.

* ruby_version string 2.0.0
* rails_version string 4.0.0

-  Add the rails-install.sh script contents to the install service lifecycle.

NOTES:

The darwin_global.conf file is an example how you can make shared properties accessible through all the types of scripts.
Where you see '. $global_conf', this is mapped to the global_conf content property.

After install visit http://${server.ip} to verify the rails/passenger environment
