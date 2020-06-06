
Build Scripts for Tsugi
-----------------------

This is a series of build scripts that allow you to build various
versions of Tsugi servers on ubuntu instances.

You can build any of the following:

* Scripts that can be run inside of a bare ubuntu distribution
to prepare the instance to run Tsugi (ubuntu/README.md)

* Produce docker images that can be used for development,
docker swarm, or Kubernetes (docker/README.md)

* Scripts that prepare an AMI image for development and production
that can be uses to mint EC2 nodes and/or an Amazon autoscaling
group.  This produced an AMI that can be shared publically.
(ami/README.md)

You have to decide what kind of instance you want:

* A demo / developer instance installs MySQL locally in the instance.  This
shoul dnot be used for production - but it can be used for simple demo servers
where backup and the ability to scale is not critical.

* A production instance expects to have externally provided SQL server,
Memcache, EFS, etc.

In general there are two phases of this process.  

* Prepartion - Install all the software and pre-requisites (scripts names
include 'prepare')

* Startup / Configuration - Customize the instance to be yours - which database
to use, etc. (script names include 'startup')







