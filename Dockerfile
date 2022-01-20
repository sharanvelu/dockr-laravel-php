FROM php:8.0-apache-buster

LABEL Author="Sharan" "org.opencontainers.image.authors"="Sharan" Description="Image used for Dockr Coantiners." "com.example.vendor"="DockR.in" website="dockr.in"

RUN apt-get update && \
    apt-get install -y \
        git \
        libfreetype6-dev \
        libldap2-dev \
        libgmp-dev \
        libmcrypt-dev \
        libonig-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        netcat \
        npm \
        procps \
        supervisor \
        vim \
        yarn \
        zip \
        zlib1g-dev

RUN docker-php-ext-install bcmath exif gd gmp ldap mbstring mysqli pcntl pdo pdo_mysql sysvmsg zip

# PHP Memory Limit conf
COPY php/mem-limit.ini /usr/local/etc/php/conf.d/dockr-mem-limit.ini

# xDebug
RUN pecl install xdebug
COPY php/xdebug.ini /usr/local/etc/php/conf.d/dockr-xdebug.ini

# DockR Dependencies
RUN mkdir /usr/local/dockr && chmod u+x -R /usr/local/dockr
COPY dockr /usr/local/dockr

# Composer
RUN curl -o- https://raw.githubusercontent.com/sharanvelu/dockr-extras/master/composer-install.sh | bash

WORKDIR /var/www/html

RUN chmod -R 777 /var/www/html && mkdir public

COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf

#supervisor config
COPY dockr/supervisor/supervisor.conf /etc/supervisor/supervisord.conf
COPY dockr/supervisor/supervisor.conf /etc/supervisord.conf

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

RUN a2enmod rewrite \
    && rm -rf public \
    && apt-get clean
