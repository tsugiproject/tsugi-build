#! /bin/bash

for f in /var/www/html /var/www/sites/*
do
    echo Tsugi update $f
    cd $f/tsugi
    if [ -d .git ] ; then
       git pull
    fi
done

