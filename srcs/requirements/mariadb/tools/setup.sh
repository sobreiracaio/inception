#!/bin/bash

service mariadb start

# Wait for MariaDB to be ready
while ! mysqladmin ping -h localhost --silent; do
    echo "Waiting for MariaDB to initialize..."
    sleep 2
done

# Reading data from secrets
MYSQL_USER=$(cat /run/secrets/mysql_user)
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
WP_USER=$(cat /run/secrets/wp_user)
WP_ADMIN=$(cat /run/secrets/wp_admin_user)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)


# WP database - creation and import
mysql -u root -e "
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' INDENTIFIED BY '${MYSQL_PASSWORD}';
    FLUSH PRIVILEGES;
"

# Set Password for root user
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');"
mysql -u root -e "FLUSH PRIVILEGES;"

# Allow root user to login from any host
mysql -u root -p $MYSQL_ROOT_PASSWORD -e "GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -p $MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

service mariadb stop

mysqld_safe



