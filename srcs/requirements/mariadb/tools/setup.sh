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


# Primeiro acesso sem senha (funciona só porque ainda não tem senha definida)
mysql -u root -e "
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
"

# Agora definimos a senha para o usuário root (localhost apenas)
mysql -u root -e "
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
"

# Reforça o acesso do root apenas localmente (evita login remoto sem senha)
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
    REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'root'@'%';
    FLUSH PRIVILEGES;
"

# Opcional: bloquear totalmente acesso remoto de root (boa prática)
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
    DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost');
    FLUSH PRIVILEGES;
"

# Finaliza a configuração
service mariadb stop
exec mysqld_safe




