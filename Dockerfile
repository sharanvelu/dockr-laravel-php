FROM php:7.2-fpm

LABEL Author="Sharan" "org.opencontainers.image.authors"="Sharan" Description="Image used for Dockr Coantiners." "com.example.vendor"="DockR.in" website="dockr.in"

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

RUN pecl install xdebug
COPY php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo "upload_max_filesize = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 1000M;" >> /usr/local/etc/php/conf.d/max_size.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer --version=2.1.3

WORKDIR /var/www/html

RUN mkdir /var/www/html/public

COPY nginx/nginx.conf /etc/nginx/nginx.conf
ENV DOCKR_SERVER_TYPE="nginx"

#supervisor config
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf
COPY supervisor/supervisor.conf /etc/supervisord.conf
COPY supervisor /etc/supervisor/disabled

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

RUN rm -rf /var/www/html/public \
    && apt-get clean
