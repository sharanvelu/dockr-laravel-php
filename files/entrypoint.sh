#!/bin/bash

php artisan optimize:clear

chmod -R 777 /var/www/html/storage
chmod -R 777 /var/www/html/storage/logs
chmod -R 777 /var/www/html/bootstrap

echo "Entrypoint.sh execution completed."

exec "$@"
