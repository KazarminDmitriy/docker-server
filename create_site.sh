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
done

projectsfolder=$(pwd)"/projects/"
dockerconfigfolder=$(pwd)"/docker_configs/"
dockerserverconfigfolder=$(pwd)"/docker_configs/server_configs/*"

if [ "$domain" = "" ]; then
	echo "Параметр domain обязателен"
	exit
fi
if [ "$shortdomain" = "" ]; then
	echo "Параметр short-domain обязателен"
	exit
fi
if [ "$php" = "" ]; then
	echo "Параметр php обязателен"
	exit
fi
if [ "$webserver" != 'apache' ] && [ "$webserver" != 'fpm' ]; then
	echo "Параметр webserver должен принимать значения apache или fpm"
	exit
fi
if [ "$mysql" = "" ]; then
	echo "Параметр mysql обязателен"
	exit
fi
if [ "$dbport" = "" ]; then
	echo "Параметр dbport обязателен"
	exit
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

echo "Вы уверены, что хотите запустить установку сайта? (y/n):"
read  AMSURE 
[ "$AMSURE" = "y" ] || exit

echo "Создание директорий..."
mkdir $projectsfolder$domain && mkdir $projectsfolder$domain/$shortdomain"_docker" && mkdir $projectsfolder$domain/www

echo "Копирование конфигурации docker..."
cp -R $dockerserverconfigfolder $projectsfolder$domain/$shortdomain"_docker/"

echo "Копирование index.php..."
cp -n $dockerconfigfolder"php_start/index.php" $projectsfolder$domain/"www/"

echo "Копирование pi.php..."
cp -n $dockerconfigfolder"php_start/pi.php" $projectsfolder$domain/"www/"

echo "Изменение конфигурации: domain..."
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/docker-compose.yml"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/virtual_host_site.conf"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-apache/hosts"

sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/docker-compose.yml"
sed -i 's/!domain!/'$domain'/g' $projectsfolder$domain/$shortdomain"_docker/php-fpm/virtual_host_site.conf"
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
sed -i 's/!dbport!/'$dbport'/g' $projectsfolder$domain/$shortdomain"_docker/docker-compose.yml"

echo "Изменение конфигурации: restart..."
sed -i 's/!restart!/'$restart'/g' $projectsfolder$domain/$shortdomain"_docker/docker-compose.yml"

echo "Изменение hosts..."
sudo sh -c "echo '127.0.0.1 $domain' >> /etc/hosts"

echo "Поднятие веб-сервера"
cd $projectsfolder$domain/$shortdomain"_docker"
docker-compose build && docker-compose up -d

echo "Установка завершена"