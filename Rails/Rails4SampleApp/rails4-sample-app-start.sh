#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE
export HOME=/home/$RAILSUSER

export config_script="/home/$RAILSUSER/rails4-sample-app-start.sh"
cat > $config_script << EOF
#!/usr/bin/env bash
set -e

export COMMON_INCLUDE=/tmp/common_include
. $COMMON_INCLUDE
export HOME=/home/$RAILSUSER

export PATH="$PATH:$sample_app_dir/bin"
cd $sample_app_dir

. $RVM_HOME/scripts/rvm
try rvm use $ruby_version@appdirector-gemset
echo Starting Rails 4 Sample App Server ...
try nohup rails server --binding=$self_ip --port=$sample_app_port 2>&1 > $sample_app_dir/running.log &

echo Success, visit http://$self_ip:$sample_app_port
EOF
chmod +x $config_script
chown $RAILSUSER:$RAILSUSER $config_script
try su - $RAILSUSER -p -c \"$config_script\"

