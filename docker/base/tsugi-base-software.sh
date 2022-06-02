
# This file lives in two repos
# https://github.com/tsugicloud/ami-sql/blob/master/tsugi-base-software.sh
# https://github.com/tsugiproject/tsugi-build/blob/master/docker/base/tsugi-base-software.sh

# http://jpetazzo.github.io/2013/10/06/policy-rc-d-do-not-start-services-automatically/
cat > /usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 0
EOF

sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
locale -a
env

TSUGI_PHP_VERSION=8.0

echo ======= Update 1
apt -y update

echo ======= Upgrade
apt -y upgrade
apt-get install -y build-essential
apt-get install -y software-properties-common
apt-get install -y byobu curl git htop man unzip vim wget
apt-get install -y apt-utils
apt-get install -y mysql-client-8.0
apt-get install -y nfs-common
if [ ! -f "/usr/bin/crontab" ]; then
    apt-get install -y cron
fi
apt-get install -y ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
echo ======= Update 2
apt update
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
add-apt-repository -y universe
apt update
apt-get install -y apache2
apt-get install -y php${TSUGI_PHP_VERSION}
apt-get install -y libapache2-mod-php${TSUGI_PHP_VERSION} php${TSUGI_PHP_VERSION}-mysql php${TSUGI_PHP_VERSION}-curl
apt-get install -y php${TSUGI_PHP_VERSION}-mbstring php${TSUGI_PHP_VERSION}-zip php${TSUGI_PHP_VERSION}-xml php${TSUGI_PHP_VERSION}-gd
apt-get install -y php${TSUGI_PHP_VERSION}-apcu
apt-get install -y php${TSUGI_PHP_VERSION}-intl
apt-get install -y php${TSUGI_PHP_VERSION}-memcached php${TSUGI_PHP_VERSION}-memcache
a2enmod -q rewrite dir expires headers
phpenmod mysqlnd pdo_mysql intl

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

# Cleanup is outside this file

