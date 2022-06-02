#! /bin/bash

for f in /var/www/html /var/www/sites/*
do
    echo Tool update $f
    cd $f/tsugi/admin/install
    php update.php
done

