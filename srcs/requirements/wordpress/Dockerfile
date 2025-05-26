FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
    php7.4-fpm \
    php-mysqli \
    curl
#php7.4-fpm -> php background server
#php-mysqli -> php extension to connect on mariadb
#curl ->  for dowloading Wordpress or testing

EXPOSE 9000

#port used by php-fpm to connect with nginx

RUN mkdir -p /run/php

#socket directory

COPY www.conf /etc/php/7.4/fpm/pool.d/.

#copies conf file for php-fpm(user, port/socket)
COPY tools/setup.sh .

RUN chmod +x setup.sh

ENTRYPOINT ["./setup.sh"]	
    
