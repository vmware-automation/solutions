#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE
export HOME=/home/$RAILSUSER


exportAppDir='export sample_app_dir="/home/$RAILSUSER/sample_app_rails_4"'
eval $exportAppDir
echo "$exportAppDir" >> $COMMON_INCLUDE

export config_script="/home/$RAILSUSER/rails4-sample-app-configure.sh"
cat > $config_script << EOF
#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE
export HOME=/home/$RAILSUSER

### get sample Rails 4 App
echo Cloning Sample Rails 4 Application
try git clone https://github.com/railstutorial/sample_app_rails_4.git $sample_app_dir

export PATH="$PATH:$sample_app_dir/bin"
cd $sample_app_dir

echo Configuring Gemfile with additional dependencies
try cp config/database.yml.example config/database.yml
try cat >> Gemfile <<EXJSCONF

gem 'execjs'
gem 'therubyracer'
EXJSCONF

. $RVM_HOME/scripts/rvm
try rvm use $ruby_version@appdirector-gemset
echo Setting bundle config properites
try bundle config build.pg --with-pg-dir=/usr/pgsql-9.3 --with-pg-config=/usr/pgsql-9.3/bin/pg_config
echo Running bundle install
try bundle install
echo Executing db procedures
try bundle exec rake db:create:all
try bundle exec rake db:setup
try bundle exec rake db:migrate
EOF
chmod +x $config_script
chown $RAILSUSER:$RAILSUSER $config_script
try su - $RAILSUSER -p -c \"$config_script\"
