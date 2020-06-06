Bringing Tsugi Up on Ubuntu
===========================

This documents how to manually build a Tsugi developer or production server
on an ubuntu 18.04 instance.  You have to decide what kind of instance you
want:

* A demo / developer instance installs MySQL locally in the instance.  This
shoul dnot be used for production - but it can be used for simple demo servers
where backup and the ability to scale is not critical.

* A production instance expects to have externally provided SQL server,
Memcache, EFS, etc.

Doing this on an EC2
--------------------

Create your instance from an Ubuntu `18_04` or later AMI and log in to your instance.

Testing this using a Docker container
-------------------------------------

If you don't want to make an EC2 instance - you can install docker and do all this
locally.  To be clear we are not *making* docker images in this process - instead we
are *using* docker to give us a fresh ubuntu install.

    docker run -p 8080:80 -p 5000:5432 -p 8001:8001 --name ubuntu -dit ubuntu:18.04

The log in to your instance:

    docker exec -it ubuntu bash

Ubuntu Setup
------------

Common commands after you are logged in as root:

    apt-get update
    apt-get install -y git vim

Check out this repository:

    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git

If you want a developer/demo instance (fully self-contained):

    cd /root/tsugi-build
    bash ubuntu/build-dev.sh

If you want a production instance dependent on outside resources:

    cd /root/tsugi-build
    bash ubuntu/build-prod.sh

At this point if you are in an ECS and want to snapshot an AMI for an autoscaling group
or something - do it now.  Or perhaps take a docker snapshot to come back to this point:

    docker commit d6c36062e38b tsugi:snap

Configuration and Startup
-------------------------

The rest is configuration and startup.  This file only covers the non-AMI setup.
See the `ami` folder for the more complex AMI setup.

    cd /root/tsugi-build
    cp ubuntu-dev-dist.sh  ubuntu-env.sh
    cp ubuntu-prod-dist.sh  ubuntu-env.sh

Edit the config if you are building a production box:

    export APACHE_SERVER_NAME=www.dj4e.com
    export TSUGI_APPHOME=https://www.dj4e.com

Then complete install and configure:

    source ubuntu-env.sh
    bash /usr/local/bin/tsugi-pg4e-startup.sh return


LDSLHJLKJSDLKJSDLKJSDKLJDSLKJSDLKJDSLKJDSLKJDSLJDSLJ FIX THIS

The `pg4e-startup` script will run all the Tsugi scripts in the right order.

If you are going to code  and make commits on this instance you might want
to configure git.

    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"

Getting a LetsEncrypt Certificate
----------------------------------

If you are running a real server, you will want a SSL certificate.

    root@ip-172-31-2-126:/root/tsugi-build# certbot --apache
    Saving debug log to /var/log/letsencrypt/letsencrypt.log
    Plugins selected: Authenticator apache, Installer apache
    Enter email address (used for urgent renewal and security notices) (Enter 'c' to
    cancel): csev@umich.edu

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Please read the Terms of Service at
    https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
    agree in order to register with the ACME server at
    https://acme-v02.api.letsencrypt.org/directory
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    (A)gree/(C)ancel: A

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Would you be willing to share your email address with the Electronic Frontier
    Foundation, a founding partner of the Let's Encrypt project and the non-profit
    organization that develops Certbot? We'd like to send you email about our work
    encrypting the web, EFF news, campaigns, and ways to support digital freedom.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    (Y)es/(N)o: Y
    No names were found in your configuration files. Please enter in your domain
    name(s) (comma and/or space separated)  (Enter 'c' to cancel): www.pg4e.com
    Obtaining a new certificate
    Performing the following challenges:
    http-01 challenge for www.pg4e.com
    Waiting for verification...
    Cleaning up challenges
    Created an SSL vhost at /etc/apache2/sites-available/000-default-le-ssl.conf
    Enabled Apache socache_shmcb module
    Enabled Apache ssl module
    Deploying Certificate to VirtualHost /etc/apache2/sites-available/000-default-le-ssl.conf
    Enabling available site: /etc/apache2/sites-available/000-default-le-ssl.conf

    Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    1: No redirect - Make no further changes to the webserver configuration.
    2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
    new sites, or if you're confident your site works on HTTPS. You can undo this
    change by editing your web server's configuration.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 2
    Redirecting vhost in /etc/apache2/sites-enabled/000-default.conf to ssl vhost in /etc/apache2/sites-available/000-default-le-ssl.conf

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Congratulations! You have successfully enabled https://www.pg4e.com

    You should test your configuration at:
    https://www.ssllabs.com/ssltest/analyze.html?d=www.pg4e.com
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    IMPORTANT NOTES:
     - Congratulations! Your certificate and chain have been saved at:
       /etc/letsencrypt/live/www.pg4e.com/fullchain.pem
       Your key file has been saved at:
       /etc/letsencrypt/live/www.pg4e.com/privkey.pem
       Your cert will expire on 2020-07-15. To obtain a new or tweaked
       version of this certificate in the future, simply run certbot again
       with the "certonly" option. To non-interactively renew *all* of
       your certificates, run "certbot renew"

