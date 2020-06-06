echo "Running Kube Startup"

bash /usr/local/bin/tsugi-base-startup.sh return

COMPLETE=/usr/local/bin/tsugi-prod-complete
if [ -f "$COMPLETE" ]; then
    echo "Kube startup already has run"
else

# This might be a read-write volume from before
if [ ! -d /var/www/html/tsugi/.git ]; then
  cd /var/www/html/
  git clone https://github.com/tsugiproject/tsugi.git

  # Make sure FETCH_HEAD and ORIG_HEAD are created
  cd /var/www/html/tsugi
  git pull
fi

mv /root/www/* /var/www/html
mv /var/www/html/config.php /var/www/html/tsugi

# Create the tables
cd /var/www/html/tsugi/admin
php upgrade.php


cp /usr/bin/git /usr/local/bin/gitx
chown www-data:www-data /usr/local/bin/gitx
chown -R www-data:www-data /var/www/html/tsugi

# Make git work from the browser
if [ -n "$SETUP_GIT" ] ; then
  echo "Enabling git from the browser"
  chmod a+s /usr/local/bin/gitx
fi

# if COMPLETE
fi

touch $COMPLETE

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi Kube Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi Kube Sleeping forever..."
while :; do sleep 2073600; done
