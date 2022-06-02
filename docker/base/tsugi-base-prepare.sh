
# Another repo designed to only build an AMI using similar approaches is available in

echo ======= Installing Postfix
echo "postfix postfix/mailname string example.com" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt-get install -y mailutils

echo ====== Check out build scripts if they are not already there
if [ ! -d "/root/tsugi-build" ]; then
    git clone https://github.com/tsugiproject/tsugi-build.git /root/tsugi-build
fi

if [ -d "/root/tsugi-build" ]; then
    if [ ! -f /home/ubuntu/ami-sql ]
    then
        echo "Setting up user_data.sh compatibility patch in /home/ubuntu/ami-sql"
        ln -s /root/tsugi-build/ami/ami-sql /home/ubuntu/ami-sql
    fi
fi
echo ======= Cleanup Start
df
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
echo ======= Cleanup Done
df
echo ======= Cleanup Done
