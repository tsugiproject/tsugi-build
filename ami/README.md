
Building the AMI
================

Make the pre-instance to make the ami

    EC2 Dashboard
    Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-05c1fa8df71875112 (Since 2019-08-11)
    t2.micro
    don't put user data in for the pre-process

Once your EC2 Instance is up and running, log in and run the following sequence:

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

Creating the Necessary Services and Building the User Data
==========================================================

Take a look at the `user_data_sample.sh` file - make your own copy of it.  Once you edit it
do not check it into a public repo.

Make an Aurora instance.  As you create the instance, you set up the master user
name and password (effectively the MySQL root account). When this is done, you
will want to log into an EC2 instance that is in the VPC and run the following
commands to create the table and sub-account:

    mysql -h tsugi-serverless.cluster-ce43983889mk.us-east-2.rds.amazonaws.com -u tsugi_root_account -p
    (Enter the master password you created)
    CREATE DATABASE apps_db DEFAULT CHARACTER SET utf8;
    GRANT ALL ON apps_db.* TO 'apps_db_user'@'172.%' IDENTIFIED BY 'APPS_PW_8973498';

Now you can set up the `user_data` for the database in the `user_data.sh` file.  Look at the
sample `user_data.sh` file in this folder - it has commands like:

    export TSUGI_USER=apps_db_user
    export TSUGI_PASSWORD=APPS_PW_8973498
    export TSUGI_PDO="mysql:host=tsugi-serverless.cluster-ce43983889mk.us-east-2.rds.amazonaws.com;dbname=apps_db"

Make an EFS volume and put its connection information into:

    export TSUGI_NFS_VOLUME=fs-439fd792.efs.us-east-2.amazonaws.com

Make a single-node ElasticCache / Memcache server. I use a t2.small and it has plenty of power
and memory since PHP sessions in Tsugi are pretty small.  Tsugi does not yet like a cluster
of memcache servers - so just make one of the correct size.  Watch things like free memory
on a Cloudwatch dashboard - you will likely find that it is very relaxed.  Configure in
your `user_data.sh` as follows:

    export TSUGI_MEMCACHED=tsugi-memcache.9f8gf8.cfg.use2.cache.amazonaws.com:11211

Setting up Email
================

We need to enable outbound mail using Amazon's Simple Email Service:

Go into SES - Email addresses and verify the address that mail will come
from (i.e. like info@learnxp.com) - this happens quickly.

Go into SES - Domains and setup a new domain.  You will need to put a TXT record
and some CNAMEs into your DNS tables.  It may take up to 72 hours to verify your domain.

Then make an IAM user with this JSON policy:

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "ses:SendRawEmail",
                "Resource": "*"
            }
        ]
    }

Record the Access Key ID and secret for that IAM user.  You can only view
the Secret Access Key at the moment of creation - if you lose it - you must make
a new one.  Put the Access Key ID and Secret in the `SASL_PASSWORD` field below
separated by a space.

Add these records to the `user_data.sh` for the servers.

    export POSTFIX_MAIL_FROM=info@learnxp.com
    export POSTFIX_ORIGIN_DOMAIN=learnxp.com
    export POSTFIX_RELAYHOST='[email-smtp.us-east-1.amazonaws.com]:587'
    export POSTFIX_SASL_PASSWORD="[email-smtp.us-east-1.amazonaws.com]:587 A...KEY.......34XFVQ:A....SECRET...3b7ihyatSEWH0hqnNGRh1sJOUa1fcn"

I think you can use the same IAM user for more than one domain.

Making an EC2 Instance Using the AMI
====================================

To build your EC2 Instance, make a new instance and start with the AMI you created above.  Or start with
one of the official AMIs (if we make them available).

Put in the user data under Advanced - copy everything from the "#! /bin/bash" to the end of the file.
When the EC2 provisioning process sees the hashbang, it runs the user data as a shell script.

To debug the install process, you might find it useful to look at:

After it comes up - you can see the post-ami process output in:

    ssh ubuntu@3.15.21.67
    tail -f /var/log/cloud-init-output.log

Making an Autoscaling Group Using the AMI
=========================================

It is good for testing to intiially make your Launch Configuration and AutoScaling Group without
automatically adding them to your Target Group for your ELB.  This way you can get things
right and verify by going to the IP address in the web browser and SSHing in to look around
before you add it to the Target Group.

First make a Launch Configuration exactly like spinning spinning up an EC2 instance.  Then make
an autoscaling group that uses that launch configuration.  You can't edit a Launch Configuration
but you can copy a Launch Config and make a new one to tweak.

A good testing trick as you make and test new launch configurations is to edit the ASG and
switch from desired=1, min=1, max=1 and desired=0, min=0, max=0 to bring the instances up and
down.  

References
==========

About EFS and /etc/fstab

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot-old.html
https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html#mount-fs-auto-mount-update-fstab

About Verifying a Domain with SES

https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domain-procedure.html

