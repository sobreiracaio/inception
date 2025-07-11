#Base Image
FROM debian:bullseye

#Update/upgrade system and install components
RUN	apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y \
		wget \
		mariadb-client \
		php7.4-fpm \
		php7.4-mysql \
		php7.4-mysqli \
		php7.4-curl \
		php7.4-gd \
		php7.4-mbstring \
		php7.4-xml \
		php7.4-zip \
		php7.4-json \
		php7.4-intl \
		php7.4-bcmath \
		curl && \
	rm -rf /var/lib/apt/lists/*

#Setup PHP -> Nginx communication
RUN mv /etc/php/7.4/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf.default
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/
RUN ln -s $(find /usr/sbin -name 'php-fpm*') /usr/bin/php-fpm

#Create PID directory for PHP-FPM
RUN mkdir -p /run/php
RUN chmod 755 /run/php

#Create WordPress directory
RUN mkdir -p /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN	mkdir -p /home/${USER_INCEPTION}/data/wordpress
RUN	chmod 755 /home/${USER_INCEPTION}/data/wordpress

#Define environment variables (these will be passed from docker-compose)
ARG	MYSQL_DATABASE

ENV	MYSQL_DATABASE=${MYSQL_DATABASE}

#WordPress init script
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

#Expose Port
EXPOSE 9000

# Run setup script
ENTRYPOINT [ "bash", "/usr/local/bin/setup.sh" ]
