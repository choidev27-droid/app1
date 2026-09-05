FROM php:8.2-fpm-alpine

# Install extension lengkap untuk PHP native, CodeIgniter, Laravel, dll
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    bash curl git unzip \
    libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev \
    oniguruma-dev icu-dev postgresql-dev mysql-client \
    imagemagick-dev libwebp-dev libxpm-dev gmp-dev tidyhtml-dev libxml2-dev sqlite-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
    && docker-php-ext-install -j$(nproc) \
        gd pdo pdo_mysql pdo_pgsql pdo_sqlite mysqli zip mbstring intl opcache bcmath gmp tidy soap exif pcntl sockets calendar \
    && pecl install redis imagick \
    && docker-php-ext-enable redis imagick \
    && apk del $PHPIZE_DEPS \
    && rm -rf /var/cache/apk/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "max_execution_time = 120" >> /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

USER www-data
EXPOSE 9000
CMD ["php-fpm"]