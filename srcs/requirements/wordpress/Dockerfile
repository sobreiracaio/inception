#Base Image

FROM debian:bullseye


#Update/upgrade system and install mariaDB client, php-fpm(process manager for php), php-mysql(for communication mysql/mariadb) and wget(download files tool) components

RUN	apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y wget mariadb-client php7.4-fpm php7.4-mysql


#Setup PHP -> Nginx communication

RUN         mv /etc/php/7.4/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf.default   #Replaces default setup for a customized one
COPY        ./conf/www.conf /etc/php/7.4/fpm/pool.d/
RUN         ln -s $(find /usr/sbin -name 'php-fpm*') /usr/bin/php-fpm                      #creates a simbolic link just in case the php-fpm path is not in the $PATH


#Create PID directory for PHP-FPM (used to store de the PID file - its needed to run properly, if there is no pid folder php-fpm fails)

RUN         mkdir -p /run/php
RUN         chmod 755 /run/php

#Wordpress init script

COPY        ./tools/setup.sh /usr/local/bin/
RUN         chmod 755 /usr/local/bin/setup.sh

#Expose Port

EXPOSE 9000

# Run php-fpm
ENTRYPOINT  [ "bash", "/usr/local/bin/setup.sh" ]


