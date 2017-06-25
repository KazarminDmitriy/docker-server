FROM alpine:latest

MAINTAINER Vitams <vmpartner@gmail.com>

WORKDIR /var/www/html

RUN addgroup www-data && adduser -s /bin/bash -D -G www-data www-data
RUN chown -R www-data:www-data /var/www/html/ && chmod -R 775 /var/www/html

CMD ["true"]