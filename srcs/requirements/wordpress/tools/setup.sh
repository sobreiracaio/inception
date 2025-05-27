#!/bin/bash

cd /var/www/html

echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --silent; do
    echo "Waiting for database connection..."
    sleep 2
done

echo "Database is ready!"

# - Check if WordPress is already installed
if [ -f "wp-config.php" ]; then
    echo -e "\e[34mWordPress is already installed.\e[0m"
else
    # - Fetches the wp-cli.phar file, which is the WordPress command-line tool.
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # - Downloads the latest WordPress files
    wp core download --allow-root

    # - Create the wp-config.php file, which contains WordPress’s
    #       database connection settings.
    wp config create --dbname="${DB_NAME}" \
                                --dbuser="${DB_USER}" \
                                --dbpass="${DB_PASS}" \
                                --dbhost="${DB_HOST}" \
                                --allow-root

    # - Install WordPress and sets up an admin user
    wp core install --url="${WP_URL}" \
                               --title="${WP_TITLE}" \
                               --admin_user="${WP_ADM_USER}" \
                               --admin_password="${WP_ADM_PASS}" \
                               --admin_email="${WP_ADM_EMAIL}" \
                               --allow-root
 
    # - Create a new user
    wp user create ${WP_USER} \
                              ${WP_USER_EMAIL} \
                              --role="${WP_USER_ROLE}" \
                              --user_pass="${WP_USER_PASS}" \
                              --allow-root
 
   echo "WordPress installation completed!"
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

exec php-fpm7.4 -F
