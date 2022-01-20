FROM php:7.4-apache-buster

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

# xDebug
RUN pecl install xdebug
COPY php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Php Conf
RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo "upload_max_filesize = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 1000M;" >> /usr/local/etc/php/conf.d/max_size.ini

# DockR Dependencies
RUN mkdir /usr/local/dockr

# DockR scripts
COPY scripts /usr/local/dockr/scripts
RUN chmod u+x -R /usr/local/dockr/scripts

# Composer
RUN curl -o- https://raw.githubusercontent.com/sharanvelu/dockr-extras/master/composer-install.sh | bash

WORKDIR /var/www/html

RUN chmod -R 777 /var/www/html \
    && mkdir public

COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf
ENV DOCKR_SERVER_TYPE="apache"

#supervisor config
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf
COPY supervisor/supervisor.conf /etc/supervisord.conf
COPY supervisor /etc/supervisor/disabled

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

RUN a2enmod rewrite \
    && rm -rf public \
    && apt-get clean
