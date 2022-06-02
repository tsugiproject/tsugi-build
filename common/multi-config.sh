#! /bin/bash

echo " --------- STARTING multi_config.sh $TSUGI_DOMAIN ---------------"

mkdir /efs
mkdir /efs/sites
mkdir /efs/sites/$TSUGI_DOMAIN
chown www-data.www-data /efs/sites
chown -R www-data.www-data /efs/sites/$TSUGI_DOMAIN

mkdir /var/www/sites
cd /var/www/sites
git clone $MAIN_REPO $TSUGI_DOMAIN
cd $TSUGI_DOMAIN
git clone https://github.com/tsugiproject/tsugi.git
cd tsugi

if [ -z ${TSUGI_PROTOCOL} ]; then
   export TSUGI_PROTOCOL=https
fi

sed -f - config-dist.php > config.php << EOF
s@apphome = false@apphome = '$TSUGI_PROTOCOL://$TSUGI_DOMAIN'@
s@extra_settings = false@extra_settings = '/etc/apache2/sites-available/$TSUGI_DOMAIN.config.php'@
EOF

chown www-data.www-data /var/www/sites
chown -R www-data.www-data /var/www/sites/$TSUGI_DOMAIN

a2dissite $TSUGI_DOMAIN
apache2ctl restart

cat << EOF > /etc/apache2/sites-available/$TSUGI_DOMAIN.conf
<VirtualHost *:80>
	# The ServerName directive sets the request scheme, hostname and port that
	# the server uses to identify itself. This is used when creating
	# redirection URLs. In the context of virtual hosts, the ServerName
	# specifies what hostname must appear in the request's Host: header to
	# match this virtual host. For the default virtual host (this file) this
	# value is not decisive as it is used as a last resort host regardless.
	# However, you must set it for any further virtual host explicitly.
	#ServerName www.example.com

   	ServerName $TSUGI_DOMAIN
	ServerAdmin drchuck@learnxp.com
	DocumentRoot  /var/www/sites/$TSUGI_DOMAIN

	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

	# For most configuration files from conf-available/, which are
	# enabled or disabled at a global level, it is possible to
	# include a line for only one particular virtual host. For example the
	# following line enables the CGI configuration for this host only
	# after it has been globally disabled with "a2disconf".
	#Include conf-available/serve-cgi-bin.conf

   <Directory  /var/www/sites/test.tsugicloud.org>
      Options Indexes FollowSymLinks
      AllowOverride All
      Order allow,deny
      allow from all
   </Directory>

   <Directory  ~ "vendor">
     Order allow,deny
     Deny from all
   </Directory>

</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

# Create/update the Tsugi database tables
cd /var/www/sites/$TSUGI_DOMAIN/tsugi/admin/
php upgrade.php

 # Checkout necessary mods
cd /var/www/sites/$TSUGI_DOMAIN/tsugi/admin/install/
php update.php

# Get ownership right
chown www-data.www-data /var/www/sites
chown -R www-data.www-data /var/www/sites/$TSUGI_DOMAIN

a2ensite $TSUGI_DOMAIN
apache2ctl restart

echo
echo New Configuration
echo
apache2ctl -S

echo " --------- FINISHING multi_config.sh $TSUGI_DOMAIN ---------------"

