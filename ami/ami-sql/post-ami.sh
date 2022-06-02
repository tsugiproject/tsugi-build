#! /bin/bash

echo Running post-ami patch `date "+%F-%T"`
touch /tmp/post-ami-patch-`date "+%F-%T"`

if [ ! -f /root/ubuntu-env.sh ]
then
    if [ -f /home/ubuntu/tsugi_env.sh ]
    then
        echo "Copying tsugi_env.sh"
        echo "cp /home/ubuntu/tsugi_env.sh  /root/ubuntu-env.sh"
        cp /home/ubuntu/tsugi_env.sh  /root/ubuntu-env.sh
    else
        echo "ERROR could not find /home/ubuntu/tsugi_env.sh"
        exit -1
    fi
else
    echo "/root/ubuntu-env.sh already exists..."
fi

source /root/ubuntu-env.sh

# Get the latest build scripts
cd /root/tsugi-build
git pull

echo "bash /usr/local/bin/tsugi-prod-configure.sh return"
bash /usr/local/bin/tsugi-prod-configure.sh return

