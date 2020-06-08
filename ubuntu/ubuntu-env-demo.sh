
# Copy to /root/ubuntu-env.sh and edit

# This controls how Tsugi is set up on this server.

# A github repository for the "outer" web site 
export MAIN_REPO=https://www.github.com/learnxp/test-client-web.git 

# If you don't want to have any parent site at all, you can tell "/" to redirect
# Make sure it is not a loop - use only one of MAIN_REPO or MAIN_REDIRECT
# export MAIN_REDIRECT=https://www.tsugi.org/
# If neither MAIN_REPO or MAIN_REDIRECT is set, a single html page will be put in as a placeholder.

export TSUGI_SERVICENAME=Moodle

# The URL that the outside world will use to access this server
export TSUGI_WWWROOT=https://moodle.tsugicloud.org/tsugi
export TSUGI_APPHOME=https://moodle.tsugicloud.org

# Dev / demo instances have a built-in MySQL server installed and configured
export MYSQL_ROOT_PASSWORD=hello_martin_123 

# Automatically update software - cloud style
# This must be enabled for auto-scaling scenarios to keep cluster in sync
# Single servers can leave this *unset* if they want manual updating
export AUTO_UPDATE_ENABLE=true

# Controls the host name that Apache reports - /etc/apache2/sites-available/000-default.conf
# Important when getting a LetsEncrypt certificate
export APACHE_SERVER_NAME=moodle.tsugicloud.org

