
# Copy to /root/ubuntu-env.sh and edit

# This controls how Tsugi is set up on this server.

export TSUGI_SERVICENAME=MyStore

# The URL that the outside world will use to access this server
export TSUGI_APPHOME=http://localhost:8080 

# A github repository for the "outer" web site 
# If omitted a single html page will be put in as a placeholder.
export MAIN_REPO=https://github.com/tsugiproject/tsugi-parent

# Dev / demo instances have a built-in MySQL server installed and configured
export MYSQL_ROOT_PASSWORD=secret 

