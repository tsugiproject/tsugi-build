A Set of Docker Images for Tsugi
--------------------------------

These are some docker images for Tsugi.  They live in a hierarchy so you can make
everything from a developer environment on localhost all the way up to an AWS image
that uses Aurora, DynamoDB, and EFS.  Or the nightly servers somewhere in-between.


For now we build three images - the `tsugi_dev:latest` image is a developer instance
with all of the pieces running on one server.

    $ bash build.sh    (Will take some time)

    $ docker images    (make sure they all build)

    REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
    tsugi_dev       latest    3a09a1ad5889   About a minute ago   1.52GB
    tsugi_mariadb   latest    7303816909e4   About a minute ago   1.51GB
    tsugi_prod      latest    f9d2dd49a0a2   2 minutes ago        1.21GB
    tsugi_base      latest    c99202589076   2 minutes ago        1.21GB
    tsugi_ubuntu    latest    91a4461f6747   4 minutes ago        199MB

    $ docker run -p 8080:80 -e TSUGI_SERVICENAME=TSFUN -e MYSQL_ROOT_PASSWORD=secret --name tsugi -dit tsugi_dev:latest

Navigate to http://localhost:8080/

To log in and look around, use:

    $ docker exec -it tsugi bash
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

    docker run -p 80:80 --name tsugi -dit ubuntu:20.04
    docker exec -it tsugi bash

Then in the docker:

    apt update ; apt-get install -y git vim

    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git

    cd tsugi-build
    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"
    # git checkout ubuntu-20-php-8-1
    bash ubuntu/build-dev.sh 

This does all of the docker stuff.  Then to bring it up / configure it:

    # Alternatively use user_data.sh of your choice
    cp ami/user_data_demo.sh  /root/ubuntu-env.sh
    # cp ami/user_data_multi.sh  /root/ubuntu-env.sh
    source /root/ubuntu-env.sh
    bash /usr/local/bin/tsugi-dev-configure.sh return

Debugging commands
------------------

    service --status-all

