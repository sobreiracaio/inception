#!/bin/bash

chown -R mysql:mysql /var/lib/mysql

if [ ! "$(ls -A /var/lib/mysql)" ]; then
	mariadb-install-db
fi

mysqld_safe & sleep 1
mysql -u root -e "
				CREATE DATABASE IF NOT EXISTS ${DB_NAME};
				DROP USER IF EXISTS '${DB_USER}'@'%';
				CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
				GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
				FLUSH PRIVILEGES;
"
mysqladmin -u root shutdown

exec mysqld
