
# Copy to /root/ubuntu-env.sh and edit

# This controls how Tsugi is set up on this server.

# A github repository for the "outer" web site 
export MAIN_REPO=https://github.com/csev-es/py4e.git

# If you don't want to have any parent site at all, you can tell "/" to redirect
# Make sure it is not a loop - use only one of MAIN_REPO or MAIN_REDIRECT
# export MAIN_REDIRECT=https://www.tsugi.org/
# If neither MAIN_REPO or MAIN_REDIRECT is set, a single html page will be put in as a placeholder.

export TSUGI_SERVICENAME=PY4E-ES

# Controls the host name that Apache reports - /etc/apache2/sites-available/000-default.conf
# Important when getting a LetsEncrypt certificate
export APACHE_SERVER_NAME=es.py4e.com

# Automatically update software - cloud style
# This must be enabled for auto-scaling scenarios to keep cluster in sync
# Single servers can leave this *unset* if they want manual updating
export AUTO_UPDATE_ENABLE=true

# The URL that the outside world will use to access this server
export TSUGI_APPHOME=https://es.py4e.com
export TSUGI_WWWROOT=https://es.py4e.com/tsugi

export TSUGI_USER=py4e_es_us
export TSUGI_PASSWORD=py4e_es_8675309
export TSUGI_PDO="mysql:host=36.142.42.18;dbname=py4e_es"
export TSUGI_ADMINPW=aprendizaje
export TSUGI_CONTEXT_TITLE='Python para todos'

# In general, if you set a environment variable with a prefix of TSUGI_ it will be copied
# into Tsugi's config.php with the name moved to lower case.

# TSUGI_MEMCACHED -> $CFG->memcached

# If you are going to do Google login and/or maps

# export TSUGI_GOOGLE_CLIENT_ID=8675309-7dulj1e8675p09e38pmcm7c3.apps.googleusercontent.com 
# export TSUGI_GOOGLE_MAP_API_KEY='AIzaS8675309bFmVe8IH8675309zbr9IGl8'

# If you are going to autoscale, if blobs are on disk (which is the only way to go) they need to
# be on NFS and sessions should be in Memcache

# export TSUGI_NFS_VOLUME=fs-8675309.efs.us-east-2.amazonaws.com
# export TSUGI_DATAROOT=/efs/blobs

# export TSUGI_MEMCACHED=tsugi-memcache.8x7p3s.cfg.use2.cache.amazonaws.com:11211

# If you are going to send Mail, there are a number of important fields:

# export POSTFIX_MAIL_FROM=info@learnxp.com
# export POSTFIX_ORIGIN_DOMAIN=learnxp.com
# export POSTFIX_RELAYHOST=...
# export POSTFIX_SASL_PASSWORD=...

