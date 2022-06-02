echo "Running MariaDB Configure"

bash /usr/local/bin/tsugi-base-configure.sh return

COMPLETE=/usr/local/bin/tsugi-mariadb-complete
if [ -f "$COMPLETE" ]; then
    echo "MariaDB configure already has run"
else

# MariaDB
# sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

# Make it so mysql can touch the local file system
rm /var/log/mysql/error.log
chmod -R ug+rw /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "Setting mariadb root password to default pw"
    /usr/bin/mariadb-admin -u root --password=root password root
else
    echo "Setting mariadb root password to $MYSQL_ROOT_PASSWORD"
    /usr/bin/mariadb-admin -u root --password=root password "$MYSQL_ROOT_PASSWORD"
fi

# COMPLETE
fi
touch $COMPLETE

echo Starting mariadb
service mariadb start

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi MariaDB Configure Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi MariaDB Sleeping forever..."
while :; do sleep 2073600; done

