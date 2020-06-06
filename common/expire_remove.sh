#! /bin/bash

cd /var/www/html/tsugi/admin/expire

php login-batch.php user remove
php login-batch.php context remove
php login-batch.php tenant remove
php pii-batch.php remove

