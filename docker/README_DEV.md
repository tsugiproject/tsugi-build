Docker Tsugi
------------

These are some highly stylized Docker files so that the scripts
and Dockerfiles can be reused in an three environments:

* Produce docker images that can be used for development,
docker swarm, or Kubernetes

* Scripts that can be run inside of a bare ubuntu distribution
to prepare the instance to run Tsugi.

* Scripts the prepare an AMI image for development and production
that can be uses to mint EC2 nodes and/or an Amazon autoscaling
group

In order to accomplish those reuses, our Dockerfiles are kept to
an absolute minimum and all of the clever work is done in the 
`tusgi-prepare`, `tsugi-software`, and `tsugi-startup` scripts.

The order of the steps is:

* Run all the prepare scripts to get all the software installed.
At this point you have docker images or can snapshot your EC2 to
make an AMI.

* Add configuration information by hand, on a docker command, or
in Amazon startup data area for EC2 Launch or ASG

* Start the instance - which will run all the `startup` scripts
once and do final preparation.  The startup scripts are smart
enough to only run themselves once.

* If then instance restarts - it is OK - the startup scripts don't
rerun themselves and the server just comes back up.

So the best thing to do in this situation is not edit the Dockerfiles
at all and make all your changes in either the `www` folders
or in the `startup` and `prepare` scripts.  If you do edit the 
Docker files - make sure to test all three scenarios carefully.


