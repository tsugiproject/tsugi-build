Bringing Tsugi Up on Ubuntu
===========================

This documents how to manually build a Tsugi developer or production server
on an ubuntu 20.04 instance.  You have to decide what kind of instance you
want:

* A demo / developer instance installs MySQL locally in the instance.  This
shoul dnot be used for production - but it can be used for simple demo servers
where backup and the ability to scale is not critical.

* A production instance expects to have externally provided SQL server,
Memcache, EFS, etc.

Doing this on an AWS/EC2
------------------------

See the instructions in [../ami/README.md](AMI folder).

Testing the non-Docker build using a Docker container
-----------------------------------------------------

If you don't want to make an EC2 instance or buy your own Ubuntu server and just want to
see how this process works - or if you are making changes and want to easily test,
you can install docker and do all this locally.

To be clear we are not *making* docker images in this process - instead we
are *using* docker to give us a fresh ubuntu install so we can test the non-docker
build processes - make a container:

    docker run -p 8080:80 -p 3308:3306 --name ubuntu -dit ubuntu:20.04

You can pick ports other than 8080 and 3308 to access your web server and MySQL
server running inside of docker.

Once it starts, log in to your instance:

    docker exec -it ubuntu bash

Ubuntu Setup
------------

After you have an Ubuntu and are logged in as root we start with the basics:

    apt update
    apt-get install -y git vim

Then check out this build repository:

    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git

If you want a developer/demo instance (fully self-contained):

    cd /root/tsugi-build
    bash ubuntu/build-dev.sh

If you want a production instance that is dependent on outside resources:

    cd /root/tsugi-build
    bash ubuntu/build-prod.sh

Once the script completes successfully, all the pre-reqsuisite software
 is installed and you have a generic Tsugi server ready for configuration.

Your Ubuntu disk is ready to backed up as
a pre-configuration snapshot.  In a sense your manualy built running Ubuntu image
is equivalent to either the `tsugi_dev` or `tsugi_prod` docker images if you
have done the Docker builds.

* If you are doing this on your own server - it is a good time to take a backup

* If you are testing this process in ubuntu running on docker - you can take a
snapshot in case you want to do additional installations of your software or add
your own stuff.  The snapshot command is:

        docker commit d6c36062e38b tsugi:preconfig

* If you are an an Amazon EC2 node, you can stop the instance and make copy of it
to create a pre-configured AMI.

Of course you can tag it any way you like.

Adding Your Custom Software
---------------------------

Let say you want to make a custom image with software that is beyond a stock
Tsugi install.  You would be well served to break that setup into two phases:

* Installation

* Configuration

It would be a great idea to follow the patterns in this repo to have exactly one
shell script that handles each of the steps.  Reproducability is nice.

Understanding Configuration
---------------------------

It is important to note that configuring a Tsugi server is a one time operation.
Once the configuration is complete Tsugi, Apache, MySQL (if installed) are fully
configured and set to auto-start at each boot.  The configure process is only needed
at first boot and before first use.  As a matter of fact the configure the
configuration scripts create files in `/usr/local/bin` after they run successfully
so they know not to run a second time if a server reboots or a configuration
process is re-attempted.

If you want to tweak your server configuration after this process runs - just go
in and type ubuntu commands to edit your `/etc/apache2` configuration files.  Of course,
the more you do manually, the harder it is to rebuild an identical server later.

The configure process creates folders, checks out code, creates databases,
edits Tsugi's `config.php` and a whole host of tasks to make Tsugi ready to
run.  If you access the server before or during the configuration process it
will break in subtle ways because it is not set up.  But once the process
completes the server will work.

If you made a backup of your "golden image" at the end of the prepare step
and you create a new server from that backup - you will have to run the configure
process once on that fresh copy of a "complete but unconfigured" Tsugi server.

This may initially seem counter intutitive - but once you start setting Tsugi up
with autoscaling or starting an instance using Docker, you will greatly appreciate
this process of "mint a new server from a backup, configure it, and put it into
production".

Configure a Developer Server
----------------------------

The rest is configuration and startup.  This file only covers the non-AMI setup.
See the `ami` folder for the more complex AMI setup.

Developer setup is prettty simple because there are no external servers:

    cd /root
    cp tsugi-build/ubuntu/ubuntu-env-dev.sh ubuntu-env.sh
    source ubuntu-env.sh
    bash /usr/local/bin/tsugi-dev-configure.sh return

Configure a Demo Server
------------------------

Demo setup requires that you edit your configuration but there are no external
servers needed:

    cd /root

    # If you have a Tsugi user_data.sh file, copy it into ubuntu-env, otherwise
    # copy the default file and edit it with your values
    cp tsugi-build/ubuntu/ubuntu-demo-dev.sh ubuntu-env.sh

    source ubuntu-env.sh
    bash /usr/local/bin/tsugi-dev-configure.sh return

It is correct that the configure script for both dev and demo is 'dev'.  The only
difference is the configuration.

Configure a Hand-crafted Production Server
------------------------------------------

This is not a complete set of instructions becuase there are so many different setups.
It depends on external resources.  At minumum you need a MySQL server.  If you are
autoscaling or using multple App Servers you need a Memcache server to store sessions.
If your system will use a lot of blobs - they should be on Disk and if you are using
multiple app servers they need to be on an NFS server.

So you need to set up all the needed pre-requisites and add them to the configuration.

The general outline is:

    cd /root

    # If you have a Tsugi user_data.sh file, copy it into ubuntu-env, otherwise
    # copy the default file and edit it with your values
    cp tsugi-build/ubuntu/ubuntu-prod-dev.sh ubuntu-env.sh

    source ubuntu-env.sh
    bash /usr/local/bin/tsugi-prod-configure.sh return

This pattern of hand-minting an ubuntu server and hand-minting all of the pre-requisites
is __difficult__ - If you are running production and want more of a cookie-cutter approach
take a look at the instructions under the `ami` folder.  It is far more specific and
much easier to do.

Getting a LetsEncrypt Certificate
----------------------------------

If you want to use Cloudflare it can provice your certificate, see the instructions in
[../cloudflare/README.md](Cloudflare folder).

If you are running a demo or production server, and not running behind Cloudflare
or some other proxy that provides a certification, you will want to install
a SSL certificate in your Apache server.

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

When Your Server Reboots
------------------------

After the configuration process is done once, everything you need is sitting on
the disk of your server in folders like `/etc` and `/var`.  And everything is
setup to restart on reboot - so if your server goes down or you take it down,
just bring it back up and Tsugi should just re-appear and work.

