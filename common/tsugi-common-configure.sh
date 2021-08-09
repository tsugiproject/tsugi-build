echo "Running Tsugi common configure"

echo Running tsugi-common `date "+%F-%T"`
touch /tmp/tsugi-common-`date "+%F-%T"`

echo "====== Environment variables"
env | sort

if [ -d /home/ubuntu ] ; then
cat << EOF >> /home/ubuntu/.bashrc
if [ "\$EUID" -ne 0 ]
then
PS1="\e[0;32m${TSUGI_SERVICENAME}:\e[m\e[0;34m\w\e[m$ "
else
PS1="\e[0;31m${TSUGI_SERVICENAME}:\e[m\e[0;34m\w\e[m# "
fi
EOF
fi

apt update

# Move this to pre eventually - may not need this
# apt install debconf-utils

echo ======= Installing Postfix
echo "postfix postfix/mailname string ${TSUGI_MAIL_DOMAIN}" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
debconf-show postfix

apt-get install -y mailutils

if [[ -n "$POSTFIX_ORIGIN_DOMAIN"&& -n "$POSTFIX_RELAYHOST" && -n "$POSTFIX_SASL_PASSWORD" ]]; then
  echo ======= Post-patching Postfix
  sed < /home/ubuntu/ami-sql/main.cf > /etc/postfix/main.cf \
    -e "s/POSTFIX_ORIGIN_DOMAIN/$POSTFIX_ORIGIN_DOMAIN/" \
    -e "s/POSTFIX_RELAYHOST/$POSTFIX_RELAYHOST/"
  echo $POSTFIX_SASL_PASSWORD > /etc/postfix/sasl_passwd
  echo ======= Restarting Postfix
  postmap hash:/etc/postfix/sasl_passwd
  /etc/init.d/postfix reload
else
  echo "Postfix configuration not done, please POSTFIX_ORIGIN_DOMAIN, POSTFIX_RELAYHOST, POSTFIX_SASL_PASSWORD"
fi

if [ ! -d /efs ]; then
    echo ====== Setting up the efs volume
    mkdir /efs
    if [ -n "$TSUGI_NFS_VOLUME" ] ; then
      mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $TSUGI_NFS_VOLUME:/ /efs
      if grep --quiet /efs /etc/fstab ; then
        echo Fstab already has efs mount
      else
          echo Adding efs mount to /etc/fstab
          cat << EOF >> /etc/fstab
$TSUGI_NFS_VOLUME:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport 0 0
EOF
      fi
   fi
fi

if [ ! -d /efs ]; then
    echo Failed to mount /efs - execution terminated
    exit 1
fi


if [ ! -d /efs/blobs ]; then
  mkdir /efs/blobs
fi

# This takes way too long...
echo "Patching efs permissions"
chown www-data:www-data /efs
chown www-data:www-data /efs/*
chown www-data:www-data /efs/*/*

# Construct the web
cd /var/www/html/
rm index.html   # Apache2 Debian default page

if [ -n "$MAIN_REDIRECT" ] ; then
  echo Redirecting top level path to $MAIN_REDIRECT
  cat << EOF > /var/www/html/.htaccess
RedirectMatch ^/$ $MAIN_REDIRECT
EOF
  mkdir /var/www/html/mod
  cat << EOF > /var/www/html/mod/config.php
<?php
require_once dirname(__DIR__)."/tsugi/config.php";
EOF

else
  if [ -n "$MAIN_REPO" ] ; then
    echo Cloning $MAIN_REPO
    git clone $MAIN_REPO site
  else
    echo Cloning default repo
    git clone https://github.com/tsugiproject/tsugi-parent site
  fi
  cd site
  mv .git* * ..
  mv .??* ..
  cd ..
  rm -r site

  # Sanity Check
  if [[ -d /var/www/html/.git ]] ; then
    echo Main site checkout looks good
  else
    echo Main site checkout fail
    exit 1
  fi
fi

cd /var/www/html/
git clone https://github.com/tsugiproject/tsugi.git

# Sanity Check
if [[ -f /var/www/html/tsugi/admin/upgrade.php ]] ; then
  echo Tsugi checkout looks good
else
  echo Tsugi checkout fail
  exit 1
fi

# Make sure FETCH_HEAD and ORIG_HEAD are created
cd /var/www/html
git pull
cd /var/www/html/tsugi
git pull

# Fix the config.php file
if [ ! -f /var/www/html/tsugi/config.php ] ; then
    echo Building config.php
    php /root/tsugi-build/common/fixconfig.php < /root/tsugi-build/common/config.php > /var/www/html/tsugi/config.php
fi

echo Re-starting Apache before running Tsugi scripts
/usr/sbin/apachectl restart

# Create/update the Tsugi database tables
cd /var/www/html/tsugi/admin
php upgrade.php

# Make git work from the browser
cp /usr/bin/git /usr/local/bin/gitx
chown www-data:www-data /usr/local/bin/gitx
chmod a+s /usr/local/bin/gitx

# Checkout necessary mods
cd /var/www/html/tsugi/admin/install
php update.php

# Patch permissions
chown -R www-data:www-data /var/www/html

# Create the tables
cd /var/www/html/tsugi/admin
php upgrade.php

echo ======= Cleanup Start
df
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
df
echo ======= Cleanup Done

# https://askubuntu.com/questions/2368/how-do-i-set-up-a-cron-job

if [ ! -z "$AUTO_UPDATE_ENABLE" ]; then
    echo "Setting up automatic update"

    echo ====== Setting up cron jobs
    chmod 664 /root/tsugi-build/common/cron*.sh

    cp /root/tsugi-build/common/crontab.txt /var/spool/cron/crontabs/root
    chmod 600 /var/spool/cron/crontabs/root
    service cron restart
fi

# Patch permissions (again)
chown -R www-data:www-data /var/www/html

echo Setting Apache to auto-start on reboot
update-rc.d apache2 defaults

echo Re-starting Apache
/usr/sbin/apachectl restart

