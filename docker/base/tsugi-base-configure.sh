echo "Running Base Configure"

COMPLETE=/usr/local/bin/tsugi-base-complete
if [ -f "$COMPLETE" ]; then
    echo "Base configure already has run"
else

# sanity check in case Docker went wrong with freshly mounted html folder
if [ -d "/var/www/html" ] ; then
    echo "Normal case: /var/www/html is a directory";
else
    if [ -f "/var/www/html" ]; then
        echo "OOPS /var/www/html is a file";
        rm -f /var/www/html
        mkdir /var/www/html
        echo "<h1>Test Page</h1>" > /var/www/html/index.html
    else
        echo "OOPS /var/www/html is not there";
        rm -f /var/www/html
        mkdir /var/www/html
        echo "<h1>Test Base Page</h1>" > /var/www/html/index.html
    fi
fi

# if COMPLETE
fi

if [ ! -z "$APACHE_SERVER_NAME" ]; then
cat >> /etc/apache2/sites-available/000-default.conf << EOF

ServerName $APACHE_SERVER_NAME

EOF

fi

if [ ! -z "$AUTO_UPDATE_ENABLE" ]; then
    echo "Setting up automatic update"

    echo ====== Setting up cron jobs
    chmod 664 /root/cron*.sh

    cp /root/crontab.txt /var/spool/cron/crontabs/root
    chmod 600 /var/spool/cron/crontabs/root
fi

touch $COMPLETE

/usr/sbin/apachectl start

echo "Environment variables:"
env | sort

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi Base Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi Base Sleeping forever..."
while :; do sleep 2073600; done


