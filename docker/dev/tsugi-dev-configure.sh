echo "Running dev Configure"

bash /usr/local/bin/tsugi-mysql-configure.sh return

COMPLETE=/usr/local/bin/tsugi-dev-complete
if [ -f "$COMPLETE" ]; then
    echo "Dev configure already has run"
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
        echo "<h1>Test Dev Page</h1>" > /var/www/html/index.html
    fi
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
ROOT_PASS=root
else
ROOT_PASS=$MYSQL_ROOT_PASSWORD
fi  

mysql -u root --password=$ROOT_PASS << EOF
    CREATE DATABASE tsugi DEFAULT CHARACTER SET utf8;
    GRANT ALL ON tsugi.* TO 'ltiuser'@'localhost' IDENTIFIED BY 'ltipassword';
    GRANT ALL ON tsugi.* TO 'ltiuser'@'127.0.0.1' IDENTIFIED BY 'ltipassword';
EOF

echo "Updating build scripts..."
cd /root/tsugi-build
git pull

bash /root/tsugi-build/common/tsugi-common-configure.sh

echo "Installing phpMyAdmin"
rm -rf /var/www/html/phpMyAdmin
cd /root
unzip phpMyAdmin-4.7.9-all-languages.zip
mv phpMyAdmin-4.7.9-all-languages /var/www/html/phpMyAdmin
rm phpMyAdmin-4.7.9-all-languages.zip


# if COMPLETE
fi

touch $COMPLETE

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi Dev Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi Dev Sleeping forever..."
while :; do sleep 2073600; done
