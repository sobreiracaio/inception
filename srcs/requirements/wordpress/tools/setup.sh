#!/bin/bash

#installation directory
cd /var/www/html

#check if wp-config is already installed, this avoids unwanted reinstall

if [ -f "wp-config.php" ]; then
    echo -e "WordPress already installed!"
else
    curl -O https:://raw.gitbusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    ./wp-cli.phar core download --allow-root
    #creates wp-config.php with db info
    ./wp-cli.phar config create --dbname="${DB_NAME}" \
                            --dbuser="${DB_USER}" \
                            --dbpass="${DB_PASS}" \
                            --dbhost="${DB_HOST}" \
                            --allow-root
     #install wordpress itself
     ./wp-cli.phar core install --url="${WP_URL}" \
                           --title="${WP_TITLE}" \
                           --admin_user="${WP_ADM_USER}" \
                           --admin_password="${WP_ADM_PASS}" \
                           --admin_email="${WP_ADM_EMAIL}" \
                           --allow-root
      #create an user
      ./wp-cli.phar user create ${WP_USER} \
                          ${WP_USER_EMAIL} \
                          --role="${WP_USER_ROLE}" \
                          --user_pass="${WP_USER_PASS}" \
                          --allow-root
fi

exec php-fpm7.4 -F

      

