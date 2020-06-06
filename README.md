
Build Scripts for Tsugi
-----------------------

This is a series of build scripts that allow you to build various
versions of Tsugi servers on various ubuntu instances.

You can build any of the following:

* Scripts that can be run inside of a bare ubuntu distribution
to prepare the instance to run Tsugi [ubuntu](ubuntu/README.md)

* Produce docker images that can be used for development,
docker swarm, or Kubernetes [Docker](docker/README.md)

* Scripts that prepare an AMI image for development and production
that can be uses to mint EC2 nodes and/or an Amazon autoscaling
group.  This produced an AMI that can be shared publically.
[AMI](ami/README.md)

You have to decide what kind of instance you want:

* A production instance expects to have externally provided SQL server,
Memcache server, NFS, etc.  For Amazon these are typically Aurora Serverless,
Elasticache, and EFS.   For Docker they need to be separately built containers
(i.e. this process does not build a swarm - just one of several images that
make up a swarm)

* A demo / developer instance installs MySQL and phpMyAdmin, locally 
in the instance.  This should not be used for production - but it
can be used for simple demo servers where backup and the ability to
scale is not critical.

At this point I don't run *any* production on docker - I just use Amazon.
Not because of Tsugi - that is easy - the hard part is all of the external
scalable resources Tsugi needs.

If someone with expertise knew how to set up a production grade swarm
with backup and autoscaling - and that worked in on locally owned hardware,
Google Cloud or Azure I would be happy to entertain adding support for that.

The "Outer Site"
----------------

Tsugi is just a collection of tools that you need to organize how to 
expose to your users.   Tsugi will be installed at the "/tsugi" path
in the web hierarchy at:

    /var/www/html/tsugi

You will need to add some documentation that explains what this server is, 
who can use it - why it is here, etc.  It is the web site that wraps Tsugi
and allows you to contextualize Tsugi for your purposes.  This outer site will
be at the "/" path in the browser and reside at:

    /var/www/html

In your server.

Here are some "outer site" samples ranging from the simple to the complex:

* A empty static HMTL shell + documentation - https://github.com/tsugiproject/tsugi-parent

* A Jekyll based site for https://dev1.tsugicloud.org/ - https://github.com/tsugicloud/dev-jekyll

* A Grav based site for https://www.tsugicloud.org/ - https://github.com/tsugicloud/website

* A Koseu-based course for https://www.py4e.com/ - https://github.com/csev/py4e

There is even more flexibility as to where you "embed" Tsugi.

The "outer site" for https://www.learnxp.com is actually a Shopify site that then jumps into
https://apps.learnxp.com in order to do its Tsugi functions.  For https://openochem.org/ooc/ 
the "outer site" is actually WordPress.

If you are just getting started, just use the tsugi-parent site and then once things are working
you can evolve your outer site to make your Ysugi look exactly the way you like it.

Internal Structure
------------------

In general there are two phases of this process.  

* Prepartion - Install all the software and pre-requisites (scripts named
include 'prepare')

* Startup / Configuration - Customize the instance to be yours - which database
to use, etc. (script names include 'startup')

Most of the scripts that do the heavy lifting are in the `docker` folder.
We have simple Dockerfile descriptions of how to prepare and start Tsugi
servers that lean heavily on the `prepare` and `startup` scripts.

The `ubuntu` and `ami` processes actually read the Dockerfile instructions
and extract the steps and data items that Docker would run but
outside of docker.

This might seem a bit obtuse but the goal was not to have more than one
copy of any of the instructions to make sure that no matter how we built
an instance it could be configured and function correctly.

Because of how Docker COPY commands in Dockerfiles copy from the local
drive *into* the docker container, it was easier to make Dockerfiles
that work and then pull out the instructions and do them without 
`docker` in the `ubuntu` and `ami` processes using the "crude-but-effective"
`ubuntu\fake-docker.sh` script.

I would guess some fancy product or service could do this as well - but
the approach I have taken is just to depend on ubuntu and shell scripts.

Notes on Updating this Code
---------------------------

The result of all this is that if you want to make a major change (like 
a new version of PHP).  Get it working and tested in the `docker` folder
and then test the ubuntu version and then the ami version.

Do *not* get too tricky in the Dockerfiles - or you  wll break the 
"highly simplified" way that `fake-docker.sh` extracts information
from the Dockerfile.  In particular `fake-docker.sh` will not handle
multi-line docker commands *at all*.

