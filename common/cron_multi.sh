# /bin/bash

sudo su -s "/home/www-data/tsugi-build/common/html_update.sh" www-data

sudo su -s "/home/www-data/tsugi-build/common/tsugi_update.sh" www-data

sudo su -s "/home/www-data/tsugi-build/common/tool_update.sh" www-data

sudo su -s "/home/www-data/tsugi-build/common/db_upgrade.sh" www-data

