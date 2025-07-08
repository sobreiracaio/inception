#!/bin/bash

# Caminho do WordPress
WP_PATH=/var/www/html

# Se o WordPress já estiver instalado, pula tudo
if [ -f "$WP_PATH/index.php" ]; then
    echo "WordPress já instalado, iniciando php-fpm..."
    exec php-fpm -F
fi




# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
mkdir -p $WP_PATH
mv wordpress/* $WP_PATH
rm -rf latest.tar.gz

# Change ownership of WordPress files
chown -R www-data:www-data $WP_PATH

# Download wp-cli directly to the user's bin directory
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
chmod +x /usr/local/bin/wp

# Configure WordPress
mv $WP_PATH/wp-config-sample.php $WP_PATH/wp-config.php
wp config set DB_NAME $MYSQL_DATABASE --allow-root --path=$WP_PATH
wp config set DB_USER $MYSQL_USER --allow-root --path=$WP_PATH
wp config set DB_PASSWORD $MYSQL_PASSWORD --allow-root --path=$WP_PATH
wp config set DB_HOST mariadb --allow-root --path=$WP_PATH

# Configure WordPress
wp config set WP_CACHE true --add --type=constant --allow-root --path=$WP_PATH

# Start php-fpm
exec php-fpm -F
