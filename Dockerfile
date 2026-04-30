ARG PHP_VERSION=8.3.1

FROM php:${PHP_VERSION}-fpm-alpine AS builder

RUN apk add --no-cache \
        $PHPIZE_DEPS \
        freetype-dev \
        gmp-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        linux-headers \
        oniguruma-dev \
        openldap-dev \
        postgresql-dev \
        zlib-dev \
    && docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        exif \
        gd \
        gmp \
        intl \
        ldap \
        mbstring \
        mysqli \
        pcntl \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        sysvmsg \
        zip \
    && pecl install redis xdebug \
    && docker-php-ext-enable redis

FROM php:${PHP_VERSION}-fpm-alpine AS runtime

LABEL Author="Sharan" \
      "org.opencontainers.image.authors"="Sharan" \
      Description="Image used for Dockr Containers." \
      "com.example.vendor"="DockR.in" \
      website="dockr.in"

RUN apk add --no-cache \
        bash \
        curl \
        freetype \
        git \
        gmp \
        icu-libs \
        libjpeg-turbo \
        libldap \
        libpng \
        libpq \
        libwebp \
        libzip \
        nginx \
        oniguruma \
        zlib \
    && mkdir -p /var/log/nginx /run/nginx \
    && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY php/xdebug.ini /usr/local/etc/php/conf.d/dockr-xdebug.ini
COPY php/mem-limit.ini /usr/local/etc/php/conf.d/dockr-mem-limit.ini

RUN mkdir -p /usr/local/dockr/composer && \
    curl -o- https://raw.githubusercontent.com/sharanvelu/dockr-extras/master/composer-install.sh | bash

RUN curl -fsSL https://raw.githubusercontent.com/sharanvelu/dockr-extras/master/node-npm-install.sh | bash

WORKDIR /var/www/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY composer-version.sh /usr/local/dockr/composer-version.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh /usr/local/dockr/composer-version.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
