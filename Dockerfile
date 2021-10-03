FROM php:8.0-apache-buster

RUN apt-get update && \
    apt-get install -y \
        libonig-dev \
        libzip-dev \
        libpng-dev \
        zlib1g-dev \
        libmcrypt-dev \
        vim \
        git \
        supervisor \
        zip \
        procps \
        libfreetype6-dev \
        libwebp-dev \
        libpng-dev \
        libgmp-dev \
        libldap2-dev \
        netcat \
        apache2

RUN docker-php-ext-install gmp pcntl ldap sysvmsg exif mbstring zip gd bcmath mysqli pdo pdo_mysql

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
