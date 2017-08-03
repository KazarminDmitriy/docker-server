FROM php:7.0-apache

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
    libjpeg-dev \
    libxslt-dev \
    libpng12-dev \
    libfreetype6-dev \
    freetype* \
    libssl-dev \
    libmcrypt-dev \
    libldap2-dev \
    mysql-client \
    libxml2-dev \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

#Install memcache
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends unzip libpcre3 libpcre3-dev \
    && cd /tmp \
    && curl -sSL -o php7.zip https://github.com/websupport-sk/pecl-memcache/archive/php7.zip \
    && unzip php7 \
    && cd pecl-memcache-php7 \
    && /usr/local/bin/phpize \
    && ./configure --with-php-config=/usr/local/bin/php-config \
    && make \
    && make install \
    && echo "extension=memcache.so" > /usr/local/etc/php/conf.d/ext-memcache.ini \
    && rm -rf /tmp/pecl-memcache-php7 php7.zip

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
    zip \
    xsl \
    opcache \
    ldap \
    soap \
    pdo \
    pdo_mysql \
    sockets \
    mcrypt \
    mysqli

RUN pecl install \
    timezonedb \
    igbinary

RUN docker-php-ext-enable \
    timezonedb \
    igbinary

# Install Memcached
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p memcached \
    && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && ( \
        cd memcached \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r memcached \
    && rm /tmp/memcached.tar.gz \
    && docker-php-ext-enable memcached

RUN apt-get update && apt-get install -y memcached

#######
ARG SITENAME=!domain!
ADD ./site.ini /usr/local/etc/php/conf.d
ADD ./site.pool.conf /usr/local/etc/php-fpm.d/
ADD ./virtual_host_site.conf /etc/apache2/sites-available/${SITENAME}.conf
COPY ssmtp/* /etc/ssmtp/

RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

RUN usermod -u 1000 www-data
RUN a2ensite ${SITENAME}

WORKDIR /var/www/html

CMD ["apache2-foreground"]

EXPOSE 80