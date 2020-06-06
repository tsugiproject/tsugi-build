
Build Scripts for Tsugi
-----------------------

This is a series of build scripts that allow you to build various
versions of Tsugi servers.  You can build any of the following:

* Produce docker images that can be used for development,
docker swarm, or Kubernetes

* Scripts that can be run inside of a bare ubuntu distribution
to prepare the instance to run Tsugi.

* Scripts that prepare an AMI image for development and production
that can be uses to mint EC2 nodes and/or an Amazon autoscaling
group.  This produced an AMI that can be shared publically.

It is a bit of a rats nest how these work.  The real code is
in the docker folders in the `tsugi-prepare` and `tsugi-startup`
scripts and some highly stylized Dockerfiles.  The ubuntu and 
ami setups pull things out of the docker files and run the scripts
outside of the Docker process.

Even thought the ami and ubuntu processes use the scripts and 
Docker files - docker is not used at all in these environments
and you do not have to build the docker images first or at all
when working in ubuntu or ami.

Building Docker Images
----------------------

It is pretty simple to build the docker images:

    cd docker
    bash build.sh

See `docker/README.md` for details on how to run and work with
the docker images.






