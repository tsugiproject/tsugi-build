
Using Digital Ocean For Moderate Production
-------------------------------------------

If you want professional grade hosting, you would be well served
to use Amazon AWS and use all their magical scalable widgets like
Aurora Serverless, ElastiCache, Auto Scaling Groups, and EFS.

But sometimes you just want the equivalent of a simple self-contained
Ubuntu server like the one you used to run under your desk.  DigitalOcean
is much easier than Amazon for that use case.

Making a Tsugi Droplet
----------------------

Log in to Digital Ocean and Create an UBUNTU 20.04  Droplet.

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

    ssh root@104.248.55.73
    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git

Install the pre-requisite software for a self-contained "developer" instance:

    cd /root/tsugi-build
    bash ubuntu/build-dev.sh

At this point, you could hand-install Tsugi in `/var/www/html` and set everything
up and edit yout `config.php`.
Or you could use the automated Tsugi installation and configuration below.

Automated Configuration
-----------------------

    cd /root
    cp tsugi-build/digitalocean/ubuntu-env-ocean.sh ubuntu-env.sh

Edit the `ubuntu-dev.sh` file to reflect your configuration and passwords
and then configure your server.  You might want to save a copy of the file
somewhere secure outside of the server.

    source ubuntu-env.sh
    bash /root/tsugi-build/docker/dev/tsugi-dev-configure.sh return

Don't worry - we are not using docker - the script we need is just shared
between the docker and non-docker processes.
When this script finishes your server should be up and running try these urls:

* Top page - http://104.248.55.73/  (<a href="images/05-server-up-ip.png" target="_blank">Example</a>)
* Tsugi admin - http://104.248.55.73/tsugi
* PHPMyAdmin - http://104.248.55.73/phpMyAdmin

You can remove phpMyAdmin if you feel it is a security problem by:

    rm -rf /var/www/html/phpMyAdmin

Or perhaps moving it somewhere else.

At this point you can manage your server by hand.  You can fine tune things
in config.php, install tools, run scripts, etc.  Some of the scripts
in `/root/tsugi-build/common` are designed to be run by hand in your server.

Connecting to a Domain Name
---------------------------

To connect this with a domain name, you can either route your domain to the IP
address or use __Cloudflare__.   Cloudflare is a great way to go as it solves
several problems at once:

* It gives you an https certificate automatically.

* It does DDOS (Distributed Denial of Service) protection

* It adds a caching layer for things like static assets

If you want to use Cloudflare, see the instructions in
[../cloudflare/README.md](Cloudflare folder).

Getting a LetsEncrypt Certificate
---------------------------------

If you are not using Cloudflare, you will need to update your DNS entry
for the server to point to the IP address of your DigitalOcean instance.
It takes a while for DNS to propagate so you should wait before proceeding
until you can access the server by domain name instead of IP address:

http://ocean.tsugicloud.org/ (<a href="images/06-server-up-dns.png" target="_blank">Example</a>)

Once that works, and assuming that your `ubuntu-env.sh` had the right 
setting for `APACHE_SERVER_NAME`, you should be ready to get a LetsEncrypt
certificate using the following commands:

    cd /root
    certbot --apache

Give it a real email address, answer the questions, and enter your domain name.
The certbot will automaticall create and install a certificate and then it will ask you:

    Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    1: No redirect - Make no further changes to the webserver configuration.
    2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
    new sites, or if you're confident your site works on HTTPS. You can undo this
    change by editing your web server's configuration.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 

The correct answer is **2** - once you enter this things should complete and you should be able
to access your site at

https://ocean.tsugicloud.org/ (<a href="images/07-server-up-https.png" target="_blank">Example</a>)

Viola!  

You will have to set up the auto-renewal process for your certificate using cron.  See
the LetsEncrypt documentation for details.  All the software you need to renew is
already installed.




