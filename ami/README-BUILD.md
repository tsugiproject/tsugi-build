
Building the AMI
================

Go to EC2 Dashboard - Launch new Instance and start building an instance.

Step 1: Choose an Amazon Machine Image (AMI)

    Select "Community AMIs"
    Search for "ubuntu/images/hvm-ssd/ubuntu-bionic-20.04-amd64-server" find something like:
    ubuntu/images/hvm-ssd/ubuntu-bionic-20.04-amd64-server-20200408 - ami-07c1207a9d40bc3bd

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
    bash ubuntu/build-dev.sh    # To build a demo / dev instance

    # Navigate to http://13.59.45.131 make sure you see the empty Apache screen...
    systemctl poweroff

Make an AMI by taking a snapshot of your EC2 instance once it is powered off.
Name it something like:

    tsugi-php-prod-2020-06-07-ubuntu20.04-php8.0

    tsugi-php-demo-2020-06-07-ubuntu20.04-php8.0

Give it a description in the AMI detail screen once it is created - it
is the one thing you can edit.

    This is a production build of Tsugi with Ubuntu 20.04 and PHP 8.0.

    This is a dev/demo build of Tsugi with Ubuntu 20.04 and PHP 8.0.

When you build a server based on an AMI, the `configure` scripts 
check out the latest version of Tsugi so you can keep using the same AMI
for quite a while.  You only need to make a new AMI if you want a new
version of PHP or some other software component or the `prepare`
scripts need to be changed.


Releasing a Community Tsugi AMI
-------------------------------

This is a pretty simple proces.  Make sure the name and description are suitable
and set permissions to public.  It takes about five minutes to show up in the
"Community AMIs".

Please don't release any Tsugi APIs with the same naming pattern of "tsugi-php" 
as the prefix.



