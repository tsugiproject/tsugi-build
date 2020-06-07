
Building the AMI
================

Go to EC2 Dashboard - Launch new Instance and start building an instance.

Step 1: Choose an Amazon Machine Image (AMI)

    Select "Community AMIs"
    Search for "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server" find something like:
    ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408 - ami-07c1207a9d40bc3bd

Step 2: Choose an Instance Type - t2.micro

Step 3: Configure Instance Details - just accept the defaults.

    Don't put user data in for the pre-process

Step 4: Add Storage - Accept the defaults

Step 5: Add Tags - make the name be something like "AMI Temp Build"

Step 6: Configure Security Group - Select an existing security group

    Put this in a wide-open security group (i.e. not the cloudflare-80 group)

Once your EC2 Instance is up and running and you have an IP address, log in and
run the following sequence:

    ssh ubuntu@13.59.45.131

    sudo bash
    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git
    cd tsugi-build
    bash ubuntu/build-prod.sh

    # Navigate to http://13.59.45.131 make sure you see the empty Apache screen...
    systemctl poweroff

Make an AMI by taking a snapshot of your EC2 instance once it is powered off.
Name it something like:

    tsugi-php-2020-06-04-ubuntu18.04-php7.3

Give it a description in the AMI detail screen once it is created - it
is the one thing you can edit.

When you build a server based on an AMI, the `configure` scripts 
check out the latest version of Tsugi so you can keep using the same AMI
for quite a while.  You only need to make a new AMI if you want a new
version of PHP or some other software component or the `prepare`
scripts need to be changed.


Releasing a Community Tsugi AMI
-------------------------------

TBD - This is coming after a bit more testing of this whole AMI process
has been done.



