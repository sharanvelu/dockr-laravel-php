FROM php:7.2-apache-buster

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
        procps \
        supervisor \
        vim \
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

RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo "upload_max_filesize = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 1000M;" >> /usr/local/etc/php/conf.d/max_size.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer --version=2.1.3

WORKDIR /var/www/html

RUN chmod -R 777 /var/www/html \
    && mkdir public

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

RUN a2enmod rewrite \
    && rm -rf public \
    && apt-get clean
