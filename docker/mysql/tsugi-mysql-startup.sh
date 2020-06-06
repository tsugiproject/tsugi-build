echo "Running MySQL Startup"

bash /usr/local/bin/tsugi-base-startup.sh return

COMPLETE=/usr/local/bin/tsugi-mysql-complete
if [ -f "$COMPLETE" ]; then
    echo "MySQL startup already has run"
else

# Mysql
# sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

# Make it so mysql can touch the local file system
rm /var/log/mysql/error.log
chmod -R ug+rw /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# https://stackoverflow.com/questions/9083408/fatal-error-cant-open-and-lock-privilege-tables-table-mysql-host-doesnt-ex
# This happens if /var/lib/mysql is a fresh mount
if [ ! -f /var/lib/mysql/mysql ]; then
    echo Re-initializing the mysql database
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

    echo Starting mysql
    service mysql start
    # Note this is different than in the AMI since it is 100% fresh
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        echo "Setting mysql root password to default pw"
        /usr/bin/mysqladmin -u root --password=root password root
    else
        echo "Setting mysql root password to $MYSQL_ROOT_PASSWORD"
        /usr/bin/mysqladmin -u root --password=root password "$MYSQL_ROOT_PASSWORD"
    fi
fi

# COMPLETE
fi
touch $COMPLETE

echo Starting mysql
service mysql start

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi MySQL Startup Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi MySql Sleeping forever..."
while :; do sleep 2073600; done

