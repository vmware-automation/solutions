!! Important !!
This sample deploys a 32bit instance of PostgreSQL and has been tested with CentOS 5.8 32bit.

Properties
----------
Be sure to bind the rails_version and ruby_version to those on the Rails Service

This deploys the reference implementation of the sample app for the Ruby on Rails Tutorial (Rails 4)
The code is pulled from GH @ https://github.com/railstutorial/sample_app_rails_4 so it is necessary to have external access for deployment either direct or through proxy settings.

This is a script deployed as part of the application that has a dependency on the Rails 4 Service. This isn't necessary but the BP is setup bundling both into a single application for demo purposes.

See the included png files for information on setting things up. The properties can be left as is and place the included install, configure and start scripts in the corresponding action locations on the script as displayed in the actions.png.

After successful deployment, if the default settings are used, you can view the Rails 4 Sample Application using:
http://${self_ip}:3001
