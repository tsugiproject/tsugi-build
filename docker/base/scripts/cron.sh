#! /bin/bash

echo "I am Cron Cron I Am"
date

sudo su -s "/home/ubuntu/ami-sql/html_update.sh" www-data

sudo su -s "/home/ubuntu/ami-sql/tsugi_update.sh" www-data

# Install any needed tools if we are second to the cluster
sudo su -s "/home/ubuntu/ami-sql/tool_update.sh" www-data

# Wait some random time so we don't all hit at once
echo
echo "Pausing for a moment..."
sleep $[ ( $RANDOM % 60 ) + 1 ]s

# Create/update the Tsugi database tables
sudo su -s "/home/ubuntu/ami-sql/db_upgrade.sh" www-data

# Run cron_extra_root
if [ -f "/home/ubuntu/cron_extra_root.sh" ] ; then
    echo Running cron_extra_root.sh
    sudo su -s "/home/ubuntu/cron_extra_root.sh" root
fi

# Run cron_extra
if [ -f "/home/ubuntu/cron_extra.sh" ] ; then
    echo Running cron_extra.sh
    sudo su -s "/home/ubuntu/cron_extra.sh" www-data
fi


