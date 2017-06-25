FROM mysql:5.6

MAINTAINER Mahmoud Zalt <mahmoud@zalt.me>

WORKDIR /var/www/backup

ADD dockerfile-56/my.cnf /etc/mysql/my.cnf
COPY dockerfile-56/conf.d/my.cnf /etc/mysql/conf.d/my.cnf

#RUN 'mysql -uroot -proot -e "ALTER DATABASE sitemanager CHARACTER SET utf8 COLLATE utf8_unicode_ci;"'; exit 0
#RUN 'mysql -uroot -proot -e "SET GLOBAL sql_mode = '';"'; exit 0
#RUN 'mysql -uroot -proot -e "SET SESSION sql_mode = '';"'; exit 0

#COPY docker-entrypoint.sh /usr/local/bin/
#RUN ln -s /usr/local/bin/docker-entrypoint.sh entrypoint.sh # backwards compat
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]