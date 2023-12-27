#!/bin/bash

chmod +x /usr/local/dockr/composer-version.sh
/usr/local/dockr/composer-version.sh

php-fpm -D

exec "$@"
