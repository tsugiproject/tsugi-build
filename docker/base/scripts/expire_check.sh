#! /bin/bash

cd /var/www/html/tsugi/admin/expire

php login-batch.php user
php login-batch.php context
php login-batch.php tenant
php pii-batch.php

