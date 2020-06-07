
Building the AMI
================

Make the pre-instance to make the ami

    EC2 Dashboard
    Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-05c1fa8df71875112 (Since 2019-08-11)
    t2.micro
    don't put user data in for the pre-process

Once your EC2 Instance is up and running and you have an IP address, log in and
run the following sequence:

    ssh ubuntu@13.59.45.131
    sudo bash
    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git
    cd ami-sql
    bash ubuntu/build-prod.sh
    # Navigate to http://13.59.45.131 make sure you see the empty Apache screen...
    systemctl poweroff

Make an AMI by taking a snapshot of your EC2 instance once it is powered off.
Name it something like:

    tsugi-ubuntu18.04-php7.3-2020-06-04

When you build a server based on an AMI, the `configure` scripts 
check out the latest version of Tsugi so you can keep using the same AMI
for quite a while.  You only need to make a new AMI if
you want a new version of PHP or some other software component.

Releasing a Community Tsugi AMI
-------------------------------

TBD

