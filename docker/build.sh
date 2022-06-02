#! /bin/bash

echo "Stopping containers..."
docker stop $(docker ps -aq) > /dev/null 2>&1

echo "Cleaning up containers..."
docker rm $(docker ps -aq) > /dev/null 2>&1

echo "Cleaning up images..."
docker rmi $(docker images | grep ^tsugi | awk '{print $1}') > /dev/null 2>&1

echo "Building images..."
cd ubuntu
docker build --tag tsugi_ubuntu .
cd base
docker build --tag tsugi_base .
cd ../prod
docker build --tag tsugi_prod .
cd ../mariadb
docker build --tag tsugi_mariadb .
cd ../dev
docker build --tag tsugi_dev .

