#!/bin/bash

# Grants the right permissions in the volume
chown -R mysql:mysql /var/lib/mysql

# Initialize db if it is empty
if [ ! "$(ls -A /var/lib/mysql)" ]; then
    mariadb-install-db > /dev/null
fi

# Initialize MariaDB on background
mysqld_safe & sleep 5

# Execute SQL commands on root
mysql -u root -e "
    CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
    DROP USER IF EXISTS '${MARIADB_USER}'@'%';
    CREATE USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
"

# Ends the temporary processes
mysqladmin -u root shutdown

# Initializes db on foreground
exec mysqld

