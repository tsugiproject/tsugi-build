#! /bin/bash

cd /var/www/html
if [ -d .git ] ; then
  git pull
fi

