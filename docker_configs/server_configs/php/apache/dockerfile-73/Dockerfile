FROM php:7.3-apache

MAINTAINER Kazarmin Dmitriy <phoenix1991@yandex.ru>

RUN apt-get update && apt-get install -y \
    libbz2-dev \
    libpq-dev \
    libmemcached-dev \
    memcached \
    curl \
    wget \
    git \
    ssmtp \
    nano \
    libjpeg-dev \
    libxslt-dev \
    libpng-dev \
    libfreetype6-dev \
    freetype* \
    libssl-dev \
    libmcrypt-dev \
    libldap2-dev \
    mysql-client \
    libxml2-dev \
    libzip-dev \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# configure gd library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
    ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ && \
    docker-php-ext-configure ldap \
        --with-libdir=lib/x86_64-linux-gnu

RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN docker-php-ext-install \
    exif \
    bz2 \
    gettext \
    calendar \
    mbstring \
    zip \
    xsl \
    opcache \
    ldap \
    soap \
    pdo \
    pdo_mysql \
    mysqli \
    sockets

RUN pecl install \
    timezonedb \
    igbinary \
    mcrypt-1.0.2 \
    memcached-3.1.3 \
    && docker-php-ext-enable \
    timezonedb \
    igbinary \
    mcrypt \
    memcached

ARG SITENAME=!domain!
ADD ./site.ini /usr/local/etc/php/conf.d
ADD ./virtual_host_site.conf /etc/apache2/sites-available/${SITENAME}.conf
#COPY ./ssmtp/* /etc/ssmtp/

RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load \
    && usermod -u 1000 www-data \
    && a2ensite ${SITENAME}

WORKDIR /var/www/html

CMD ["apache2-foreground"]

EXPOSE 80