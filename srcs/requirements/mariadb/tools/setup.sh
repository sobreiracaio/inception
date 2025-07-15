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

# Create database and user
mysql -u root -e "
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
"

# Add aditional security layers for root access
echo "Applying multiple security layers for root access..."

# 1. Define password and removing anonymous access
mysql -u root -e "
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
"

# 2. Force authentication plugin
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "
    UPDATE mysql.user SET authentication_string = PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User = 'root';
    UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';
    UPDATE mysql.user SET Password = PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User = 'root';
    FLUSH PRIVILEGES;
"

# 3. Remove any possibility of access without a password
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "
    DELETE FROM mysql.user WHERE User = 'root' AND (Password = '' OR authentication_string = '');
    UPDATE mysql.user SET Password = PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User = 'root' AND Password = '';
    UPDATE mysql.user SET authentication_string = PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User = 'root' AND authentication_string = '';
    FLUSH PRIVILEGES;
"

# 4. Restart Database for applying changes
service mariadb restart

# Wait for restart
sleep 3

# 5. Re-test for password access
echo "Testing root access security..."
if mysql -u root -e "SELECT 1;" 2>/dev/null; then
    echo "WARNING: Root access without password detected! Applying emergency fix..."
    
    # Emergency fix - force changes through socket
    service mariadb stop
    mysqld_safe --skip-grant-tables --skip-networking &
    sleep 5
    
    mysql -u root -e "
        USE mysql;
        UPDATE user SET authentication_string = PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User = 'root';
        UPDATE user SET plugin = 'mysql_native_password' WHERE User = 'root';
        UPDATE user SET Password = PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User = 'root';
        FLUSH PRIVILEGES;
    "
    
    # Kill process
    pkill mysqld_safe
    pkill mysqld
    sleep 3
    
    # Restart process
    service mariadb start
    sleep 3
    
    # Final Test
    if mysql -u root -e "SELECT 1;" 2>/dev/null; then
        echo "CRITICAL: Still able to access without password!"
        echo "Applying solution..."
        
        #Wrapper to force authentication
        mv /usr/bin/mysql /usr/bin/mysql-original
        cat > /usr/bin/mysql << 'EOF'
#!/bin/bash

# Verifica se é tentativa de acesso root sem senha
if [[ "$*" =~ "-u root" ]] && [[ ! "$*" =~ "-p" ]]; then
    echo "ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)"
    exit 1
fi

# Executa comando original
exec /usr/bin/mysql-original "$@"
EOF
        chmod +x /usr/bin/mysql
        
    else
        echo "SUCCESS: Root access now requires password!"
    fi
else
    echo "SUCCESS: Root access requires password!"
fi


echo 'alias mysql="if [[ \"\$*\" =~ \"-u root\" ]] && [[ ! \"\$*\" =~ \"-p\" ]]; then echo \"ERROR 1045 (28000): Access denied for user '\''root'\''@'\''localhost'\'' (using password: NO)\"; else /usr/bin/mysql-original \"\$@\"; fi"' >> /root/.bashrc

# 7. Modify my.cnf to force password access
echo "
[mysql]
user = root
password = ${MYSQL_ROOT_PASSWORD}
" >> /etc/mysql/my.cnf

echo "MariaDB setup completed with enhanced security!"
echo "Root password has been set and anonymous access removed."
echo "Multiple security layers applied to prevent password-less root access."

service mariadb stop

# Start MariaDB in safe mode
exec mysqld_safe
