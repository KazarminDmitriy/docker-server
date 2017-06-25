FROM mysql:5.5

MAINTAINER Mahmoud Zalt <mahmoud@zalt.me>

WORKDIR /var/www/backup

ADD dockerfile-55/my.cnf /etc/mysql/my.cnf
COPY dockerfile-55/conf.d/my.cnf /etc/mysql/conf.d/my.cnf

#RUN 'mysql -uroot -proot -e "ALTER DATABASE sitemanager CHARACTER SET utf8 COLLATE utf8_unicode_ci;"'; exit 0
#RUN 'mysql -uroot -proot -e "SET GLOBAL sql_mode = '';"'; exit 0
#RUN 'mysql -uroot -proot -e "SET SESSION sql_mode = '';"'; exit 0
#RUN addgroup www-data && adduser -s /bin/bash -D -G www-data www-data
#RUN chown -R www-data:www-data /var/run/ && chmod -R 775 /var/run
#RUN ln -s /usr/share/ /
#RUN ln -s /usr/share/mysql/errmsg.sys /usr/share/mysql/
#RUN chmod 666 /dev/null*


#COPY docker-entrypoint.sh /usr/local/bin/
#RUN ln -s /usr/local/bin/docker-entrypoint.sh entrypoint.sh # backwards compat
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]


#для начала давайте устраним эту ошибку
#150710  2:57:50 [ERROR] Can't find messagefile '/share/mysql/errmsg.sys
#либо руками сделайте симлинк, либо от рута в терминале выполните команду
#ln -s /usr/share/ /
#и команду
#ln -s /usr/share/mysql/english/errmsg.sys /share/mysql/
#далее давайте посмотрим какие права стоят на /dev/null поскольку у вас на него Permission denied
#ls -l /dev/null

#/usr/share/mysql/errmsg.sys