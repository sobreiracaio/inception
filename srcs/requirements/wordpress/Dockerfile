FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
    php7.4-fpm \
    php-mysqli \
    curl

EXPOSE 9000

RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d.
COPY tools/setup.sh .

RUN chmod +x setup.sh

ENTRYPOINT ["./setup.sh"]
