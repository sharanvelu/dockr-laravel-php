FROM php:7.2.34-fpm

RUN apt-get update && \
    apt-get install -y \
        git \
        libfreetype6-dev \
        libgmp-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libmcrypt-dev \
        libonig-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        netcat \
        nginx  \
        npm \
        procps \
        supervisor \
        vim \
        yarn \
        zip \
        zlib1g-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/  --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
    bcmath \
    exif \
    gd \
    gmp \
    ldap \
    mbstring \
    mysqli \
    pcntl \
    pdo \
    pdo_mysql \
    sysvmsg \
    zip

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo "upload_max_filesize = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 1000M;" >> /usr/local/etc/php/conf.d/max_size.ini

COPY files/php_conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer --version=2.1.3

WORKDIR /var/www/html

RUN mkdir /var/www/html/public

COPY files/nginx/nginx.conf /etc/nginx/nginx.conf

#supervisor config
COPY files/supervisord.conf /etc/supervisor/supervisord.conf
COPY files/supervisord.conf /etc/supervisord.conf

COPY files/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

RUN rm -rf /var/www/html/public \
    && apt-get clean

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
