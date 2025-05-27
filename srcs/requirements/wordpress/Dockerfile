FROM debian:bullseye

# Instalar PHP-FPM e extensões necessárias para WordPress
# php7.4-gd: Para manipulação de imagens
# php7.4-xml: Para RSS feeds e outras funcionalidades XML  
# php7.4-zip: Para instalação de plugins/temas
# php7.4-curl: Para requisições HTTP externas
# php7.4-mbstring: Para manipulação de strings multibyte

RUN apt update -y && apt upgrade -y && apt install -y \
    php7.4-fpm \
    php7.4-mysqli \
    php7.4-gd \      
    php7.4-xml \     
    php7.4-zip \     
    php7.4-curl \    
    php7.4-mbstring \
    default-mysql-client \ 
    curl \
    && apt clean

EXPOSE 9000

#Cria diretórios necessários
RUN mkdir -p /run/php
RUN mkdir -p /var/www/html

#Define ownership correto
RUN chown -R www-data:www-data /var/www/html

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup.sh .

#Torna o setup executavel
RUN chmod +x setup.sh

ENTRYPOINT ["./setup.sh"]
