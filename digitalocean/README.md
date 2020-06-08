
Using Digital Ocean For Moderate Production
-------------------------------------------

**Under Construction**

If you want professional grade hosting, you would be well served
to use Amazon AWS and use all their magical scalable widgets like
Aurora Serverless, ElastiCache, Auto Scaling Groups, and EFS.

But sometimes you just want the equivalent of a simple self-contained
server like the one you used to run under your desk.  DigitalOcean
is much easier than Amazon for that use case.

Making a Tsugi Droplet
----------------------

Log in to Digital Ocean and Create an UBUNTO 18.04  Droplet.

A nice thing about DO is that you can add memory, CPU, or 
disk to your instance pretty easily
as your use grows.  So you could start with the $10/ month system
and expand as needed.

Set your hostname to the ultimate domain name where this will
be hosted - like "ocean.tsugicloud.org".

Make sure to check backup as you make your instance.  The backups
are simple and inexpensive and something you don't worry about.

Installing Tsugi on Your Droplet
--------------------------------

Log in to your droplet as root and check out this build repository:

    ssh root@104.248.56.200
    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git

Install the pre-requisite software for a self-contained "developer" instance:

    cd /root/tsugi-build
    bash ubuntu/build-dev.sh

At this point, you could hand-install Tsugi in `/var/www/html` and set everything
up.  Or you could use the automated Tsugi installation and configuration.

Automated Configuration
-----------------------

    cd /root
    cp tsugi-build/digitalocean/ubuntu-env-ocean.sh ubuntu-env.sh

Edit the `ubuntu-dev.sh` file to reflect your configuration and passwords
and then configure your server.

    source ubuntu-env.sh
    bash /root/tsugi-build/docker/dev/tsugi-dev-configure.sh return

I would also save this file somewhere
