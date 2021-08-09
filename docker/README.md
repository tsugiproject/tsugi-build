A Set of Docker Images for Tsugi
--------------------------------

These are some docker images for Tsugi.  They live in a hierarchy so you can make
everything from a developer environment on localhost all the way up to an AWS image
that uses Aurora, DynamoDB, and EFS.  Or the nightly servers somewhere in-between.


For now we build three images - the `tsugi_dev:latest` image is a developer instance
with all of the pieces running on one server.

    $ bash build.sh    (Will take some time)

    $ docker images    (make sure they all build)

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    tsugi_dev           latest              116d2bf50c4e        2 minutes ago       674MB
    tsugi_mysql         latest              90f8d82f7070        2 minutes ago       674MB
    tsugi_base          latest              b7199f92080c        3 minutes ago       585MB
    ubuntu              20.04               a35e70164dfb        13 days ago         222MB

    $ docker run -p 8080:80 -e TSUGI_SERVICENAME=TSFUN -e MYSQL_ROOT_PASSWORD=secret --name ubuntu -dit tsugi_dev:latest

Navigate to http://localhost:8080/

To log in and look around, use:

    $ docker exec -it ubuntu bash
    root@73c370052747:/var/www/html/tsugi/admin# 

To attach and watch the tail logs:

    $ docker attach 73c...e21
    root@73c370052747:/var/www/html/tsugi/admin# 

To detatch press CTRL-p and CRTL-q

To see the entire startup log:

    $ docker logs 73c...e21

Cleaning up

    docker stop 73c3700527470dc10f58b3e6b2a8837b22d3d2b6790cb70346b02a8a64d3ce21
    docker container prune
    docker image prune

Big clean up:

    docker rmi $(docker images -a -q)
    docker image prune

To build one image

    docker build --tag tsugi_base .

To test the ami scripts in a docker container so you can start over and over:

    docker run -p 8080:80 -p 3306:3306 --name ubuntu -dit ubuntu:20.04
    docker exec -it ubuntu bash

Then in the docker:

    apt update
    apt-get install -y git
    apt-get install -y vim
    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"

    cd /root
    git clone https://github.com/tsugiproject/docker-php.git

    cd docker-php
    bash ami/build.sh 

This does all of the docker stuff.  Then to bring it up / configure it:

    cp ami-env-dist.sh  ami-env.sh
    bash /usr/local/bin/tsugi-dev-startup.sh return


