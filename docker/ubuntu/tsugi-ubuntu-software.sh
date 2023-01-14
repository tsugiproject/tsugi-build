
# http://jpetazzo.github.io/2013/10/06/policy-rc-d-do-not-start-services-automatically/
cat > /usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 0
EOF

apt update
apt upgrade
apt -y install software-properties-common

env

echo ======= Cleanup Start
df
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
echo ======= Cleanup Done
df
echo ======= Cleanup Done

