#! /bin/bash

# Finish all four steps for one site before starting the next. A new Tsugi
# checkout has to be followed immediately by its database upgrade; leaving
# that gap until every other site is updated can crash the site.

sudo su -s /bin/bash www-data << 'EOF'
for f in /var/www/html /var/www/sites/*
do
    if [ ! -d "$f" ] ; then
        continue
    fi

    echo Tsugi update $f
    if [ -d "$f/tsugi/.git" ] ; then
        cd "$f/tsugi"
        git pull
    fi

    echo Database upgrade $f
    if [ -d "$f/tsugi/.git" ] ; then
        cd "$f/tsugi/admin"
        php upgrade.php
    fi

    echo Main update $f
    if [ -d "$f/.git" ] ; then
        cd "$f"
        git pull
    fi

    echo Tool update $f
    if [ -d "$f/tsugi/admin/install" ] ; then
        cd "$f/tsugi/admin/install"
        php update.php
    fi
done
EOF
