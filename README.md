
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

* A demo / developer instance installs MySQL locally in the instance.  This
shoul dnot be used for production - but it can be used for simple demo servers
where backup and the ability to scale is not critical.

* A production instance expects to have externally provided SQL server,
Memcache, EFS, etc.

In general there are two phases of this process.  

* Prepartion - Install all the software and pre-requisites (scripts named
include 'prepare')

* Startup / Configuration - Customize the instance to be yours - which database
to use, etc. (script names include 'startup')

Most of the scripts are in the `docker` folder.  We have simple Dockerfile
descriptions of how to prepare and start Tsugi servers that lean heavily
on the `prepare` and `startup` scripts.

The `ubuntu` and `ami` processes actually read the Dockerfile instructions
and run the steps that Docker would run but outside of docker.

This might seem a bit obtuse but the goal was not to have more than one
copy of any of the instructions to make sure that no matter how we built
an instance it could be configured and function correctly.








