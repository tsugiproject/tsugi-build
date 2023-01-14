#! /bin/bash

# Put this in /root/ubuntu-env.sh

echo ================= PLEASE PUT REAL DATA IN THIS FILE AND DELETE THIS LINE

export MAIN_REDIRECT=https://www.tsugi.org/
export TSUGI_NFS_VOLUME=fs-7e3b4987.efs.us-east-2.amazonaws.com

export POSTFIX_MAIL_FROM=info@tsugicloud.org
export POSTFIX_ORIGIN_DOMAIN=tsugicloud.org
export POSTFIX_RELAYHOST='[email-smtp.us-east-1.amazonaws.com]:587'

# See IAM Users ses-smtp-user.20180209-181037 Security credentials
# /etc/postfix/sasl_passwd
export POSTFIX_SASL_PASSWORD="[email-smtp.us-east-1.amazonaws.com]:587 ALKJSD4X5LJ7LH34XFVQ:AhHzQ6sdkjhdkjhksjdyatSEWH0dfkjKJHKJHOUa1fcn";



