#! /bin/bash
echo Running user-data from `pwd` on `date "+%F-%T"`
echo `pwd` > /tmp/user-data-`date "+%F-%T"`

cat << EOF > /root/ubuntu-env.sh
export MAIN_REPO=https://github.com/tsugicloud/website.git

export TSUGI_USER=tsugicloud
export TSUGI_PASSWORD=N5reoiui_OIUEROT
export TSUGI_PDO="mysql:host=tsugi-serverless.cluster-ce51lfgjgflj.us-east-2.rds.amazonaws.com;dbname=tsugicloud"
export TSUGI_NFS_VOLUME=fs-802398f9.efs.us-east-2.amazonaws.com
export TSUGI_ADMINPW=tsugiFun

export TSUGI_OWNERNAME=Learning Experiences
export TSUGI_OWNEREMAIL=drchuck@learnxp.com
export TSUGI_PROVIDEKEYS=true
export TSUGI_AUTOAPPROVEKEYS='/.+@.+\\.edu/'

export TSUGI_SETUP_GIT=yes
export TSUGI_MAILDOMAIN=www.tsugicloud.org
export TSUGI_APPHOME=https://www.tsugicloud.org
export TSUGI_WWWROOT=https://www.tsugicloud.org/tsugi
export TSUGI_SERVICENAME=TsugiCloud

export TSUGI_PRIVACY_URL=https://www.tsugicloud.org/about/policies/privacy
export TSUGI_SLA_URL=https://www.tsugicloud.org/about/policies/service-level-agreement
export TSUGI_LOGO_URL=https://www.tsugicloud.org/user/miniCloud_blackBack.png
export TSUGI_PRIVACY_URL=https://www.tsugicloud.org/about/policies/privacy
export TSUGI_SLA_URL=https://www.tsugicloud.org/about/policies/service-level-agreement
export TSUGI_LOGO_URL=https://www.tsugicloud.org/user/miniCloud_blackBack.png

export TSUGI_WEBSOCKET_SECRET=xyzzy
export TSUGI_WEBSOCKET_URL=wss://socket.tsugicloud.org:443

export TSUGI_GOOGLE_CLIENT_ID=1015059281328498ljdfhldfkhk45987fdkhjr.apps.googleusercontent.com
export TSUGI_GOOGLE_CLIENT_SECRET=uFhjdffdhkhjdfkjhfddfkjh
export TSUGI_MAP_API_KEY=AIkdkjhfdkjhdkUHASkjasIUHSAKJDHXjtPvtSM

export TSUGI_GOOGLE_CLASSROOM_SECRET=609403direiudskj8398dsjdskh94

export TSUGI_MEMCACHED=tsugi-memcache.9f8gf8.cfg.use2.cache.amazonaws.com:11211

# This matters because of Amazon Simple Mail Service
export POSTFIX_MAIL_FROM=info@tsugicloud.org
export POSTFIX_ORIGIN_DOMAIN=tsugicloud.org
export POSTFIX_RELAYHOST='[email-smtp.us-east-1.amazonaws.com]:587'
export POSTFIX_SASL_PASSWORD="[email-smtp.us-east-1.amazonaws.com]:587 AKIKJHDSKJHSDKJHXFVQ:Ahfdkjfdjkfdhjxh450980548n";

EOF

source /root/ubuntu-env.sh

# Get the latest build scripts
cd /root/tsugi-build
git pull

# Here you can add commands that will run once when the system is being configured after
# being created from the AMI.

# apt-get update
# apt-get -y install zip
# which zip

# If you like, you can also create two scripts that will be run by cron

# cat << EOF > /root/cron_extra_root.sh
# echo This script runs as root from cron at least once per hour after all the other cron jobs have run
# EOF

# cat << EOF > /root/cron_extra.sh
# echo This script runs as www-data from cron at least once per hour after all the other cron jobs have run
# echo and after cron_extra_root.sh has run
# EOF

bash /usr/local/bin/tsugi-prod-configure.sh return

