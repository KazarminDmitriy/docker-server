#FROM nginx:latest
#
#MAINTAINER Vitams <vmpartner@gmail.com>
#
#ADD nginx.conf /etc/nginx/
#ADD site.conf /etc/nginx/sites-available/
#
#RUN echo "upstream php-upstream { server php-fpm:9000; }" > /etc/nginx/conf.d/upstream.conf
#
#RUN usermod -u 1000 www-data
#
#CMD ["nginx"]
#
#EXPOSE 80 443
FROM nginx:alpine

MAINTAINER Mahmoud Zalt <mahmoud@zalt.me>

ADD nginx.conf /etc/nginx/
ADD site.conf /etc/nginx/sites-available/

ARG PHP_UPSTREAM=php-fpm

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1000 -s /bin/bash www-data \
    && rm /etc/nginx/conf.d/default.conf \
    && echo "upstream php-upstream { server ${PHP_UPSTREAM}:9000; }" > /etc/nginx/conf.d/upstream.conf

CMD ["nginx"]

EXPOSE 80 443