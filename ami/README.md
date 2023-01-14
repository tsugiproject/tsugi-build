
Building a Tsugi Instance from an AMI
=====================================

To run this process, you first need to build an AMI with all the Tsugi software
installed or use a Tsugi Public AMI.

When you build a server based on an AMI, the `configure` scripts
check out the latest version of Tsugi so you can keep using the same AMI
for quite a while.  You only need to make a new AMI if
you want a new version of PHP or some other software component or the `prepare`
scripts need to be changed.

Cloudflare
----------

Make sure to look through the `cloudflare` folder and do any necessary setup to
use Cloudflare.  Tsugi loves to work behind Cloudflare.   It saves bandwidth,
decreases load times for users around the world, and provides excellent protection
agains Distributed Denial of Servce (DDOS) attacks is you put your servers in
an AWS security group that only accepts connections from Cloudflare.

Creating the Necessary Services and Building the User Data
----------------------------------------------------------

Take a look at the `user_data_prod.sh` file - make your own copy of it.  Once you edit it
do not check it into a public repo.

Make an Aurora instance.
(<a href="images/01-aurora-tsugi-serverless.png" target="_blank">Example</a>)
As you create the instance, you set up the master user
name and password (effectively the MySQL root account). When this is done, you
will want to log into an EC2 instance that is in the VPC and run the following
commands to create the table and sub-account:

    mysql -h tsugi-serverless.cluster-ce43mk.us-east-2.rds.amazonaws.com -u tsugi_root_account -p
    (Enter the master password you created)
    CREATE DATABASE apps_db DEFAULT CHARACTER SET utf8;
    GRANT ALL ON apps_db.* TO 'apps_db_user'@'172.%' IDENTIFIED BY 'APPS_PW_8973498';

Now you can set up the `user_data` for the database in the `user_data.sh` file.  Look at the
sample `user_data.sh` file in this folder - it has commands like:

    export TSUGI_USER=apps_db_user
    export TSUGI_PASSWORD=APPS_PW_8973498
    export TSUGI_PDO="mysql:host=tsugi-serverless.cluster-ce43983889mk.us-east-2.rds.amazonaws.com;dbname=apps_db"

Since you do not want store database blobs in the database and you do not want to run your
EC2 instances out of disk and because you might make an autoscaling groups right away or later,
make an EFS volume 
(<a href="images/01-efs-config.png" target="_blank">Example</a>)
that can be mounted on your EC2 instance:

    AWS-> EFS -> File Systems
    Create New File System
    Make sure to add cloudflare-80 as the security group if you use it for your EC2s
    Check Enable Lifecycle Management (research this)

Put the hostname of your newly minted EFS volume in your `user_data.sh` as follows:

    export TSUGI_NFS_VOLUME=fs-439fd792.efs.us-east-2.amazonaws.com

Make a single-node ElasticCache / Memcache server. 
(<a href="images/01-memcache-config.png" target="_blank">Example</a>)
I use a t2.small and it has plenty of power
and memory since PHP sessions in Tsugi are pretty small.  
Tsugi does not yet understand a cluster
of memcache servers - so just make one of the correct size.  Watch things like free memory
on the dashboard 
(<a href="images/02-memcache-stats.png" target="_blank">Example</a>) - you
will likely find that it is very relaxed and nowhere
near running out of memory.  Configure in your `user_data.sh` as follows:

    export TSUGI_MEMCACHED=tsugi-memcache.9f8gf8.cfg.use2.cache.amazonaws.com:11211

Note that at the end of the `user_data_prod.sh` there is a place where you
can add commands to install more software, or set up additional configurations.   There
are also two shell scripts you can write which are executed regularly by the cron process.
See comments in `user_data_prod.sh` for more detail.

Setting up Email
----------------

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
------------------------------------

To build your EC2 Instance, make a new instance and start with the AMI you created above.  Or start with
one of the official AMIs (if we make them available).

**Step 1: Choose an Amazon Machine Image (AMI)**

_Using a Public AMI_ - Select "Community APIs" and search for "tsugi-php-prod"
and pick the latest version.
(<a href="images/01-tsugi-prod-community-ami.png" target="_blank">Example</a>)
These AMIs are produced using the scripts
https://github.com/tsugicloud/ami-sql

_Using your AMI_ - Select "My AMIs", find your AMI and select it.

**Step 2: Choose an Instance Type**

I use a t2.micro if this will be a medium to low server
or if I am going to use an Auto Scaling Group.  If I thing this might get a bit more traffic,
but I don't want to use an ASG, use t2.small or t2.medium.  The nice thing is that it is easy to
change the instance type in a pinch - but if you want to keep costs low and handle a wide range
of load - using t2.micros and an ASG is the best way to go.

**Step 3: Configure Instance Details**

Most of the defaults are OK on this screen.  But we need to configure the instance.
Scroll down to "Advanced Details" and "User Data".
Select "As Text" and paste in the entire contents of your `user_data.sh` configuration.
Copy everything from the "#! /bin/bash" to the end of the file.
When the EC2 provisioning process sees the hashbang, it runs the user data as a shell script.

**Step 4: Add Storage**

Keep the default 8GB - every bit of data that grows except logs is stored outside the server.

**Step 5: Add Tags**

Make sure to add a name tag

**Step 6: Configure Security Group**

Make sure to "Select an existing security group" and pick
the right security group.  For example if you are only accepting connections from Cloudflare
then pick your `cloudflare-80` security group or whatever you named it.   Sometimes it is
easier to select a more open security group at this point and swithc to the `cloudflare-80`
security group later.

After the provisioning is complete, the tsugi-build configure processes will run.  If you want to see
them in action while provisioning is running, login and watch the log file.

    ssh ubuntu@3.15.21.67
    tail -f /var/log/cloud-init-output.log

Once the server is all the way up, you can check to see if it is working.  Remember if you used the
Cloudflare only security group, you can't just go to the IP address in the browser:

http://3.15.21.67/

See the `cloudflare` instructions on how to temporarily sneak by the security group for initial testing.

Single (non-autoscaled) Server in Cloudflare
--------------------------------------------

Once you have an IP address simply log into your Cloudflare configuration and route the www subdomain
to that IP address

Making an Autoscaling Group Using the AMI
-----------------------------------------

It is good for testing to initially make your Launch Configuration and AutoScaling Group without
automatically adding them to your Target Group for your ELB.  This way you can get things
right and verify by going to the IP address in the web browser and SSHing in to look around
before you add it to the Target Group.

First make a Launch Configuration exactly like spinning spinning up an EC2 instance.  Then make
an autoscaling group that uses that launch configuration.  You can't edit a Launch Configuration
but you can copy a Launch Config and make a new one to tweak.

Once you have a new launch configuration, go into your Target Group and edit it to point to the
new launch configuration.   Then go into Auto Scaling Group -> Instance Management and detatch
instances running the old configuration and have Amazon build a replacement instance.  The replacement
instances should come up with the new configuration.

You can ssh into those new instances to poke around and verify things like PHP version, etc.

References
----------

About EFS and /etc/fstab

https://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html

https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot-old.html

https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html#mount-fs-auto-mount-update-fstab

About Verifying a Domain with SES

https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domain-procedure.html

