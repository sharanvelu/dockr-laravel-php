#!/bin/bash

RUN chmod -R 777 /var/www/html

a2enmod rewrite

exec "$@"
