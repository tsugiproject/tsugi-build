
Setting up a Multi Virtual Host Server
--------------------------------------

This instructions could easily be adapted to any hosting environment - ths big
change is where you store blobs and how you set up your database connection.

You can test this process nicely in docker (instructions below) but without
a few DNS tricks - it is easiest to test one virtual host.

For a Production environment in AWS using Ubuntu 20.

Pre-Work for Production (i.e. AWS)
----------------------------------

First make any necessary databases for each vhost.  You will need a blob store area.
On AWS you can use EFS which is efficient and convienent.

    # Make any necessary databases for each vhost
    mysql -h my-serverless.cluster-cd46ksjhdkjh.us-east-2.rds.amazonaws.com -u my_root -p
    CREATE DATABASE ihtspr4ecom DEFAULT CHARACTER SET utf8;
    CREATE USER 'ihtspr4ecomuser'@'localhost' IDENTIFIED BY 'changeme';
    CREATE USER 'ihtspr4ecomuser'@'127.0.0.1' IDENTIFIED BY 'changeme';
    GRANT ALL ON ihtspr4ecom.* TO ihtspr4ecomuser@'localhost';
    GRANT ALL ON ihtspr4ecom.* To ihtspr4ecomuser@'127.0.0.1';

    # Make an EFS volume and have it accessible to your Ubuntu server
    # You can use one /efs volume for many vhosts as the setup makes
    # a subdirectory for each vhost
    # fs-7e3b4987.efs.us-east-2.amazonaws.com

Building your vhost Server
--------------------------

This is a sample setup for one of my AWS servers:

    t2.small

    Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2022-12-12 ami-0cbea92f2377277a4

    Start in the "default" security group - move to "cloudflare-80" security group
    after initial testing is complete

Once you have a server and log in as root or ubuntu and  `sudo bash`

    # Not needed for 20.04.05 - check if you already have git and vim
    apt update ; apt-get install -y git vim

    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git

    cd tsugi-build

    bash ubuntu/build-prod.sh

Copy the `prod-env-dist.sh file` from this folder, adapt it for your needs
and put it into `/root/ubuntu-env.sh`.  This is very minimal and has
no sites in it at all.  Sites and Tsugi are added later.

    cp vhost/prod-env-dist.sh /root/ubuntu-env.sh
    # Edit /root/ubuntu-env.sh and put in real data!
    source /root/ubuntu-env.sh

    # Build the /var/www/html environment
    source /usr/local/bin/tsugi-prod-configure.sh return

Make a copy of kubernetes.docker.internal.sh and adapt
it for each of your vhosts - you should choose a name for each
configuration based on the virtual host domain so you can keep things
reasonable.  This contains some shell variables
used to set up the virtual host and configure your `config.php`.
Upload these files to the server and execute them one at a time.

    bash /root/sites/test.tsugicloud.org.sh
    bash /root/sites/ihts.pr4e.com.sh

Once DNS is properly pointing at this server,
you should be able to test urls like:

    http://test.tsugicloud.org
    http://ihts.pr4e.com

Once these are setup - you can use something like LetsEncrypt
to promote them to https, or you can leave them http and
put a load balancer like CloudFlare or Application Load Balancer
and have the load balancer terminate the https support
and handle things like DDOS.

The install process should have installed the necessary software
to get a certificate from LetsEngrypt so no further `apt` commands
should be necessary.

If you don't have a certificate installed and keep the vhosts
http only, you can edit the scripts like `/root/sites/ihts.pr4e.com.sh`
and re-run them to update them.  Or you can tweak the configurations
in the Apache configuration folder:

    cd /etc/apache2/sites-available/
    ls -l
    -rw-r--r-- 1 root root 1332 Jun  8  2022 000-default.conf
    -rw-r--r-- 1 root root 6340 Jun  8  2022 default-ssl.conf
    -rw-r--r-- 1 root root 1662 Jan 14 16:27 ihts.pr4e.com.conf
    -rw-r--r-- 1 root root  354 Jan 14 16:27 ihts.pr4e.com.config.php
    -rw-r--r-- 1 root root 1662 Jan 14 16:27 test.tsugicloud.org.conf
    -rw-r--r-- 1 root root  354 Jan 14 16:27 test.tsugicloud.org.config.php

Note that both the Apache configuration *and* the Tsugi configuration
for the vhost are here.  The Tsugi `/var/sites/ihts.pr4e.com/tsugi/config.php`
includes the `config.php` in this Apache configuration folder.

Adding a new vhost
------------------

At any time, you can make a new site set up script
and up load it and run it.  You have added a new vhost
and apache has been reloaded.

    # /root/sites/sakai.tsugicloud.org.sh

Once the DNS are pointing at the server, things should
just work.


To test vhost setup in docker
=============================

You can do most of this in a docker container to get a feel
for the process.  Docker sets up a DNS that points
`kubernetes.docker.internal` at the container - so that
is the easiest vhost to set up. You can have multiple
vhosts if you can get the DNS to work from outside
the container.

You will use a local MariaDB server, and the `/efs` folder
will just be stored locally on your root volume which is
fine for testing.

On your host, start Docker and then:

    docker run -p 80:80 --name tsugi -dit ubuntu:20.04
    docker exec -it tsugi bash

In the docker:

    apt update ; apt-get install -y git vim

    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git

    cd tsugi-build
    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"

    bash ubuntu/build-dev.sh

The `build-dev.sh` sets up a local MariaDB server so lets create a
local database in that server (password is root):

    mysql -u root -p
    CREATE DATABASE internal DEFAULT CHARACTER SET utf8;
    create user 'internaluser'@'localhost' IDENTIFIED BY 'internalpass';
    create user 'internaluser'@'127.0.0.1' IDENTIFIED BY 'internalpass';
    grant all on internal.* to internaluser@'localhost';
    grant all on internal.* to internaluser@'127.0.0.1';

    # You can tweak the ubuntu-env.sh if you like
    cp /root/tsugi-build/vhost/docker-env.sh /root/ubuntu-env.sh

    source /root/ubuntu-env.sh
    bash /usr/local/bin/tsugi-dev-configure.sh return

At this point, http://localhost/phpMyAdmin should work.   The next
step is to create the internal virtual host:

    bash /root/tsugi-build/vhost/kubernetes.docker.internal.sh

Once that completes, you can navigate to:

    http://kubernetes.docker.internal

Setting up more virtual hosts is a bit tricky because of DNS
and database considerations.   But it should work with the
right setup.

