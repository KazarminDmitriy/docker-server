FROM mysql:5.5

MAINTAINER Kazarmin Dmitriy <phoenix1991@yandex.ru>

WORKDIR /var/www/backup

ADD dockerfile-55/my.cnf /etc/mysql/my.cnf
ADD dockerfile-55/conf.d/my.cnf /etc/mysql/conf.d/my.cnf

#RUN 'mysql -uroot -proot -e "ALTER DATABASE sitemanager CHARACTER SET utf8 COLLATE utf8_unicode_ci;"'; exit 0
#RUN 'mysql -uroot -proot -e "SET GLOBAL sql_mode = '';"'; exit 0
#RUN 'mysql -uroot -proot -e "SET SESSION sql_mode = '';"'; exit 0

CMD ["mysqld"]

EXPOSE 3306