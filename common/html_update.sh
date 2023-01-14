#! /bin/bash

for f in /var/www/html /var/www/sites/*
do
    echo Main update $f
    cd $f
    if [ -d .git ] ; then
       git pull
    fi
done

