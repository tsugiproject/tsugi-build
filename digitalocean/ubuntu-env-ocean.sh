
# Copy to /root/ubuntu-env.sh and edit

# This controls how Tsugi is set up on this server.

# A github repository for the "outer" web site 
export MAIN_REPO=https://github.com/tsugiproject/tsugi-parent.git

# If you don't want to have any parent site at all, you can tell "/" to redirect
# Make sure it is not a loop - use only one of MAIN_REPO or MAIN_REDIRECT
# export MAIN_REDIRECT=https://www.tsugi.org/
# If neither MAIN_REPO or MAIN_REDIRECT is set, a single html page will be put in as a placeholder.

export TSUGI_SERVICENAME=Ocean

# The URL that the outside world will use to access this server
export TSUGI_APPHOME=https://ocean.tsugicloud.org
export TSUGI_WWWROOT=https://ocean.tsugicloud.org/tsugi

export TSUGI_ADMINPW=oceans_ie949e8_42

# Dev / demo instances have a built-in MySQL server installed and configured
export MYSQL_ROOT_PASSWORD=oceans_3ds7s91_42
export TSUGI_USER=oceans_user
export TSUGI_PASSWORD=oceans_94ds932_42

# Controls the host name that Apache reports - /etc/apache2/sites-available/000-default.conf
# Important when getting a LetsEncrypt certificate
export APACHE_SERVER_NAME=ocean.tsugicloud.org

# Automatically update software - cloud style
export AUTO_UPDATE_ENABLE=true

# If you are going to do Google login and/or maps

# export TSUGI_GOOGLE_CLIENT_ID=8675309-7dulj1e8675p09e38pmcm7c3.apps.googleusercontent.com
# export TSUGI_GOOGLE_MAP_API_KEY='AIzaS8675309bFmVe8IH8675309zbr9IGl8'

