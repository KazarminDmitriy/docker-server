#!/bin/bash
for argument in ${@}; do
    case $argument in
        -k=* | --domain=* )
            domain=${argument##*=}
            ;;
    esac
    case $argument in
        -k=* | --short-domain=* )
            shortdomain=${argument##*=}
            ;;
    esac
    case $argument in
        -k=* | --php=* )
            php=${argument##*=}
            ;;
    esac
    case $argument in
        -k=* | --webserver=* )
            webserver=${argument##*=}
            ;;
    esac
    case $argument in
        -k=* | --mysql=* )
            mysql=${argument##*=}
            ;;
    esac
    case $argument in
        -k=* | --dbport=* )
            dbport=${argument##*=}
            ;;
    esac
    case $argument in
        -k=* | --restart=* )
            restart=${argument##*=}
            ;;
    esac
    case $argument in
        -k=* | --help* )
            help=1
            ;;
    esac
done

if [ "$help" != "" ]; then
	#echo "                  "
	echo "Пример команды"
	echo "sh create_site.sh --domain=test.ru --short-domain=test --php=70 --webserver=fpm --dbport=33061 --mysql=57"
	echo "\n"
	echo "Параметры"
	echo "\n"
	echo "--domain          обязательный параметр. URL адрес сайта"
	echo "                  Пример: test.ru"	
	echo "\n"
	echo "--short-domain    обязательный параметр. Как правило это название сайта без домена"
	echo "                  Используется для именования контейнеров и папки с конфигами докера"
	echo "                  Пример: test"
	echo "\n"
	echo "--php             необязательный параметр. Номер версии php без точки"
	echo "                  Пример: 70"
	echo "                  Возможные значения: 54, 55, 56, 70"
	echo "                  По умолчанию: 56"
	echo "\n"
	echo "--webserver       необязательный параметр. Тип используемого вебсервера"
	echo "                  Пример: apache"
	echo "                  Возможные значения: apache, fpm"
	echo "                  По умолчанию: apache"
	echo "\n"
	echo "--mysql           необязательный параметр. Номер версии mysql без точки"
	echo "                  Пример: 57"
	echo "                  Возможные значения: 55, 56, 57"
	echo "                  По умолчанию: 57"
	echo "\n"
	echo "--dbport          необязательный параметр. Порт, по которому можно будет получить доступ к БД не из контейнера (например из phpstorm) "
	echo "                  Рекомендую использовать следующий принцип именования: к стандартному порту 3306 добавлять по порядку цифру"
	echo "                  Пример: 33061, 33062, 33063"
	echo "\n"
	echo "--restart         необязательный параметр. Указывает нужно ли запускать веб-сервер при перезагрузке докера или всей машины"
	echo "                  Возможные значения: always, no"
	echo "                  По умолчанию: always"
	echo "\n"
	echo "Смена рабочей директории для вебсервера apache: файл virtual_host_site.conf"
	echo "\n"
	echo "Смена рабочей директории для вебсервера fpm: файл nginx/site.conf"
	echo "\n"
	echo "========================================================================"
	echo "Установка yii"
	echo "После поднятия вебсервера исполняем следующие команды (внутри контейнера)"
	echo "\n"
	echo "composer config --global repo.packagist composer https://packagist.org"
	echo 'composer global require "fxp/composer-asset-plugin:@dev"'
	echo "composer create-project--prefer-dist yiisoft/yii2-app-basic basic"
	echo "\n"
	echo "Если установка yii идет в basic (или в подобную), то переходим в эту папку и вводим команду"
	echo "composer update"
	echo "\n"
	echo "если установка yii идет в текущую папку, то установщик сам произведет composer update"
	echo "\n"
	echo "Github token: 27fa671a2d996c4170c499a2188f0e38be797fed"
	echo "\n"
	echo "Возможно пригодится команда (перед установкой yii)"
	echo "composer config --global repositories.packagist.allow_ssl_downgrade false"
	echo "У меня без неё всё ставилось"
	exit
fi

projectsfolder=$(pwd)"/projects/"
dockerconfigfolder=$(pwd)"/docker_configs/"
dockerserverconfigfoldersimple=$(pwd)"/docker_configs/server_configs/"
dockerserverconfigfolder=$(pwd)"/docker_configs/server_configs/*"

if [ "$domain" = "" ]; then
	echo "Параметр domain обязателен"
	exit
fi

if [ "$shortdomain" = "" ]; then
	echo "Параметр short-domain обязателен"
	exit
fi

if [ "$php" != '' ] && [ "$php" != '54' ] && [ "$php" != '55' ] && [ "$php" != '56' ] && [ "$php" != '70' ]; then
	echo "Параметр php задан не правильно"
	exit
fi
if [ "$php" = "" ]; then
	php="56"
fi

if [ "$webserver" != '' ] && [ "$webserver" != 'apache' ] && [ "$webserver" != 'fpm' ]; then
	echo "Параметр webserver задан не правильно"
	exit
fi
if [ "$webserver" = "" ]; then
	webserver="apache"
fi

if [ "$mysql" != '' ] && [ "$mysql" != '55' ] && [ "$mysql" != '56' ] && [ "$mysql" != '57' ]; then
	echo "Параметр mysql задан не правильно"
	exit
fi
if [ "$mysql" = "" ]; then
	mysql="57"
fi

if [ "$restart" = "" ]; then
	restart="always"
fi
if [ "$restart" != 'always' ] && [ "$restart" != 'no' ]; then
	echo "Параметр restart должен принимать значения always или no"
	exit
fi

echo "Выбранные параметры для установки"
echo "Домен: "$domain
echo "Короткий домен: "$shortdomain
echo "Версия PHP: "$php
echo "Вебсервер: "$webserver
echo "Версия MYSQL: "$mysql
echo "MYSQL порт: "$dbport
echo "Параметр restart: "$restart

if [ "$dbport" != "" ]; then
	dbport=$dbport":"
fi

echo "Вы уверены, что хотите запустить установку сайта? (y/n):"
read  AMSURE 
[ "$AMSURE" = "y" ] || exit

echo "Создание директорий..."
mkdir $projectsfolder$domain && mkdir $projectsfolder$domain/$shortdomain"_docker" && mkdir $projectsfolder$domain/www

echo "Копирование конфигурации docker..."
cp -R $dockerserverconfigfolder $projectsfolder$domain/$shortdomain"_docker/"
cp -R $dockerserverconfigfoldersimple"ssmtp/" $projectsfolder$domain/$shortdomain"_docker/php-apache/"
cp -R $dockerserverconfigfoldersimple"ssmtp/" $projectsfolder$domain/$shortdomain"_docker/php-fpm/"
rm -rf $projectsfolder$domain/$shortdomain"_docker/ssmtp"

echo "Копирование index.php..."
cp -n $dockerconfigfolder"php_start/index.php" $projectsfolder$domain/"www/"

echo "Копирование pi.php..."
cp -n $dockerconfigfolder"php_start/pi.php" $projectsfolder$domain/"www/"

echo "Изменение конфигурации: domain..."
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/docker-compose.yml"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/virtual_host_site.conf"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/hosts"

sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/docker-compose.yml"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/hosts"

echo "Изменение конфигурации: php..."
sed -i 's/!php!/'$php'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/docker-compose.yml"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/dockerfile-54/Dockerfile"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/dockerfile-55/Dockerfile"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/dockerfile-56/Dockerfile"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/dockerfile-70/Dockerfile"

sed -i 's/!php!/'$php'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/docker-compose.yml"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/dockerfile-54/Dockerfile"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/dockerfile-55/Dockerfile"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/dockerfile-56/Dockerfile"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/dockerfile-70/Dockerfile"

echo "Копирование docker-compose.yml соответствующего веб-сервера"
if [ "$webserver" = "apache" ]; then
	cp $projectsfolder$domain/$shortdomain"_docker/php-apache/docker-compose.yml" $projectsfolder$domain/$shortdomain"_docker/docker-compose.yml"
fi
if [ "$webserver" = "fpm" ]; then
	cp $projectsfolder$domain/$shortdomain"_docker/php-fpm/docker-compose.yml" $projectsfolder$domain/$shortdomain"_docker/docker-compose.yml"
fi

echo "Изменение конфигурации: mysql..."
sed -i 's/!mysql!/'$mysql'/g' $projectsfolder$domain/$shortdomain"_docker/docker-compose.yml"
sed -i 's/!dbport!:/'$dbport'/g' $projectsfolder$domain/$shortdomain"_docker/docker-compose.yml"

echo "Изменение конфигурации: restart..."
sed -i 's/!restart!/'$restart'/g' $projectsfolder$domain/$shortdomain"_docker/docker-compose.yml"

echo "Изменение hosts..."
sudo sh -c "echo '127.0.0.1 $domain' >> /etc/hosts"

echo "Поднятие веб-сервера"
cd $projectsfolder$domain/$shortdomain"_docker"
docker-compose build && docker-compose up -d

echo "Установка завершена"