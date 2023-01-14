
Installing Tsugi on AWS
=======================

Go to EC2 Dashboard - Launch new Instance and start building an instance.

Step 1: Name the tag something like "AMI Temp Build" or something else if you are manual
building like "dev-sakai-20-81" or testing something.

Step 2: Choose an Amazon Machine Image (AMI)

    Select "Community AMIs"
    Search for "ubuntu 20.04 amd64-server" under "Community AMIs" and find something like:
    ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220610 - ami-0960ab670c8bb45f3

Step 3: Choose an Instance Type - t2.micro

Step 4: Choose your access key

Step 5: Configure Security Group - You will almost always select an existing security group

    Put this in a wide-open security group (i.e. not the cloudflare-80 group)

Step 6: Add Storage - Accept the defaults (8GB)

Step 7: Advanced details - leave a alone for now

Once your EC2 Instance is up and running and you have an IP address, log in and
run the following sequence:

    ssh ubuntu@18.188.204.195

    sudo bash
    cd /root
    git clone https://github.com/tsugiproject/tsugi-build.git
    cd tsugi-build
    # If testing a new version of tsugi-build, you checkout a branch here
    bash ubuntu/build-prod.sh

    # To build a demo / dev instance instead of prod
    # bash ubuntu/build-dev.sh

    # Navigate to http://18.188.204.195 make sure you see the empty Apache screen...

At this point if you are building a one-off server skip to the 
"Configure a Hand-crafted Production Server" instructions below.

Making an AMI
-------------

    systemctl poweroff

Make an AMI by taking a snapshot of your EC2 instance once it is powered off.
Name it something like:

    tsugi-php-prod-2022-06-16-ubuntu20.04-php8.1

    tsugi-php-demo-2022-06-16-ubuntu20.04-php8.1

Give it a description in the AMI detail screen once it is created - it
is the one thing you can edit.

    This is a production build of Tsugi with Ubuntu 20.04 and PHP 8.1.

    This is a dev/demo build of Tsugi with Ubuntu 20.04 and PHP 8.1.

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

Configure a Hand-crafted Production Server
------------------------------------------

In order to build auto-scaling groups, we need a configuration bootstrap shell
script that we call by convention `user_data.sh`.  In an Autoscaling group, the text
of the shell script is added to the ASG configuration so that each new server

The [README.md] file describes how to configure a `user_data.sh` file.

The bootstrap process to configure a freshly installed but not configured EC2 instance
is as follows:

    cd /root

    # If you have a Tsugi user_data.sh file, copy it into user-data.sh
    cat > user_data.sh
    ...  Paste in the user_data.sh contents

    # Or start with the default and edit it.
    # cp tsugi-build/ami/user_data.sh user_data.sh

    bash user_data.sh

At this point you should have a running Tsugi on port 80.  You can test to see if it came
up at http://18.188.204.195 to see your top page.  Most links will not work until you have
DNS routing requests to the `APPHOME` url from your `user_data.sh`.

You can see how to set your server up behind Cloudflare at:
[../cloudflare/README.md](Cloudflare folder)

If you will just connect this server to the network directly, you can find instructions
to set up a SSL / https certificate at [../ubuntu/README.md](Ubuntu folder).

You should store a copy of the `user_data.sh` data for a particular server in a secure
location once you have a good configuration so you don't have to re-configure and
re-test if you ever need to rebuild the server.

