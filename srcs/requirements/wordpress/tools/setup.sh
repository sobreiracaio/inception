#!/bin/bash

WP_PATH=/var/www/html
SETUP_FLAG="/tmp/wp_setup_done"

# If already configured, just start php-fpm
if [ -f "$SETUP_FLAG" ]; then
    echo "WordPress already configured, initializing php-fpm..."
    exec php-fpm -F
fi

echo "Setting up WordPress..."

# Waiting MariaDB
echo "Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD --silent; do
    echo "Waiting MariaDB to be ready..."
    sleep 3
done
echo "MariaDB ready!"

# Download WordPress if it doesn't exist
if [ ! -f "$WP_PATH/index.php" ]; then
    echo "Downloading WordPress..."
    wget -q https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mkdir -p $WP_PATH
    cp -r wordpress/* $WP_PATH/
    rm -rf wordpress latest.tar.gz
    chown -R www-data:www-data $WP_PATH
fi

# Creating wp-config.php
echo "Creating wp-config.php..."
cat > $WP_PATH/wp-config.php << EOF
<?php
define( 'DB_NAME', '$MYSQL_DATABASE' );
define( 'DB_USER', '$MYSQL_USER' );
define( 'DB_PASSWORD', '$MYSQL_PASSWORD' );
define( 'DB_HOST', 'mariadb' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

chown www-data:www-data $WP_PATH/wp-config.php

# Testing connection
echo "Testing connection with DataBase..."
php -r "
\$link = mysqli_connect('mariadb', '$MYSQL_USER', '$MYSQL_PASSWORD', '$MYSQL_DATABASE');
if (\$link) {
    echo 'Connection OK!';
    mysqli_close(\$link);
} else {
    echo 'Error: ' . mysqli_connect_error();
    exit(1);
}
"

# Mark as concluded
touch "$SETUP_FLAG"

echo "WordPress successfully setup!"
echo "Initializing php-fpm..."
exec php-fpm -F
