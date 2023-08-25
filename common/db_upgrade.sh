#! /bin/bash

for f in /var/www/html /var/www/sites/*
do
    echo Database upgrade $f
    cd $f/tsugi
    if [ -d .git ] ; then
       cd admin
       php upgrade.php
    fi
done

