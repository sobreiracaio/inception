#!/bin/bash

service mariadb start

# Wait for MariaDB to be ready
while ! mysqladmin ping -h localhost --silent; do
    echo "Waiting for MariaDB to initialize..."
    sleep 2
done

# WP database - creation and import
mysql -u root -e "
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
"

# Set Password for root user
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');"
mysql -u root -e "FLUSH PRIVILEGES;"

# Allow root user to login from any host
mysql -u root -p $MYSQL_ROOT_PASSWORD -e "GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -p $MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

service mariadb stop



