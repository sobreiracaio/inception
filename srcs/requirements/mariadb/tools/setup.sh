#!/bin/bash

service mariadb start

# WP database - creation and import

mysql -u root -e "
				CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
				CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
				GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
				FLUSH PRIVILEGES;
		 "

# Set Password for root user
mariadb -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');"
mariadb -u root -e "FLUSH PRIVILEGES;"

# Allow root user to login from any host
mariadb -u root -p $MYSQL_ROOT_PASSWORD "GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mariadb -u root -p $MYSQL_ROOT_PASSWORD "FLUSH PRIVILEGES;"

service mariadb stop







