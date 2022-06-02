#! /bin/bash

export TSUGI_DOMAIN=kubernetes.docker.internal
export TSUGI_PROTOCOL=http
export MAIN_REPO=https://github.com/tsugicloud/testpublic.git

cat << EOF > /etc/apache2/sites-available/$TSUGI_DOMAIN.config.php
<?php

\$CFG->pdo       = 'mysql:host=localhost;dbname=internal';
\$CFG->dbuser    = 'internaluser';
\$CFG->dbpass    = 'internalpass';
\$CFG->adminpw    = 'vhostAdmin';
\$CFG->memcached = false;

\$CFG->google_client_id = false;
\$CFG->google_client_secret = false;

\$CFG->google_map_api_key = false;

\$CFG->dataroot = '/efs/sites/$TSUGI_DOMAIN';
EOF

source /root/tsugi-build/common/multi-config.sh

