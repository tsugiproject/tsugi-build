#! /bin/bash

# Live upgrade to an 8.4 install for Ubuntu 20 or 22

xrel=`grep -oP 'VERSION_ID="\K[\d]+' /etc/os-release`

if [ "$xrel" = "20" ] || [ "$xrel" = "22" ]; then
    echo "Ubuntu version: " $xrel
else
    echo "This script will only run on Ubuntu 20 or 22. Your version:" $xrel
    exit
fi

if [ -f "/usr/bin/php8.4" ]; then
    echo "It looks like you already have PHP 8.4 installed"
    exit
fi

sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
locale -a
env


TSUGI_PHP_VERSION=8.4

echo ======= Update 1
apt -y update
# apt -y upgrade
apt-get install -y build-essential
apt-get install -y software-properties-common
apt-get install -y byobu curl git htop man zip unzip vim wget
apt-get install -y apt-utils
apt-get install -y mysql-client-8.0
apt-get install -y nfs-common
apt-get install -y sqlite3
if [ ! -f "/usr/bin/crontab" ]; then
    apt-get install -y cron
fi
apt-get install -y ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

echo ======= Update 2 after adding apt-key
apt update
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
add-apt-repository -y universe
apt update
apt-get install -y apache2
apt-get install -y php${TSUGI_PHP_VERSION}
apt-get install -y libapache2-mod-php${TSUGI_PHP_VERSION} php${TSUGI_PHP_VERSION}-mysql php${TSUGI_PHP_VERSION}-curl
apt-get install -y php${TSUGI_PHP_VERSION}-mbstring php${TSUGI_PHP_VERSION}-zip php${TSUGI_PHP_VERSION}-xml php${TSUGI_PHP_VERSION}-gd
apt-get install -y php${TSUGI_PHP_VERSION}-apcu php${TSUGI_PHP_VERSION}-intl php${TSUGI_PHP_VERSION}-memcached php${TSUGI_PHP_VERSION}-memcache php${TSUGI_PHP_VERSION}-sqlite3

# Seems like these are not automatic in ubuntu 20
apt-get install -y php${TSUGI_PHP_VERSION}-common php${TSUGI_PHP_VERSION}-opcache

# phpMyAdmin might need these
apt-get install -y php${TSUGI_PHP_VERSION}-imagick php${TSUGI_PHP_VERSION}-xmlrpc php${TSUGI_PHP_VERSION}-cli php${TSUGI_PHP_VERSION}-soap php${TSUGI_PHP_VERSION}-imap

# In case we want to develop or check something
apt-get install -y composer

echo ======= Installing Node and Friends
apt-get install -y nodejs
node --version
apt-get install -y npm
# https://phoenixnap.com/kb/update-node-js-version
npm install -g n
PATH="$PATH"
n stable
PATH="$PATH"

npm --version
echo === Installing certbot - https://certbot.eff.org/lets-encrypt/ubuntufocal-apache
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

echo === Installed versions
echo -n "Node " ; node --version
echo -n "npm " ; npm --version
php --version
mysql --version
lsb_release -a

phpenmod mysqlnd pdo_mysql intl sqlite3 pdo_sqlite
a2enmod -q rewrite dir expires headers

if [ -f "/usr/bin/php8.4" ]; then
cat << EOF
It looks like you have installed PHP 8.4.

To make sure you are running PHP 8.4 at the command line use

update-alternatives --config php

If that works, do the following steps manually to switch php versions in Apache:

ls /etc/apache2/mods-enabled/php*.load

Disable the apache version you currently have enabled

a2dismod phpX.Y  # From the above list
a2enmod php8.4
systemctl restart apache2

Then check with info.php to make sure you have PHP 8.4

EOF
else
cat << EOF

If you have problems with the apt-get install complaining about versions and you
have upgraded this server from ubuntu 18 to ubuntu 20, take a look at this stack overflow article

https://askubuntu.com/questions/111645/whats-the-best-way-to-re-enable-ppas-repos-after-an-upgrade

You may need to uncomment some lines in the list files to get the PPAs re-enabled

EOF
fi


