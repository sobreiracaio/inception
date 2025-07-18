#!/bin/bash

WP_PATH=/var/www/html
SETUP_FLAG="/tmp/wp_setup_done"
DOMAIN_NAME="userlogin.42.fr"
# If already configured, just start php-fpm
if [ -f "$SETUP_FLAG" ]; then
    echo "WordPress already configured, initializing php-fpm..."
    exec php-fpm -F
fi

echo "Setting up WordPress..."

# Reading from secrets
MYSQL_USER=$(cat /run/secrets/mysql_user)
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
WP_USER=$(cat /run/secrets/wp_user)
WP_ADMIN=$(cat /run/secrets/wp_admin_user)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)

# Waiting MariaDB
echo "Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD --silent; do
    echo "Waiting MariaDB to be ready..."
    sleep 3
done
echo "MariaDB pronto!"

# Download WordPress if it doesn't exist
WP_VERSION=6.5.3
if [ ! -f "$WP_PATH/index.php" ]; then
    echo "Downloading WordPress $WP_VERSION..."
    wget -q https://wordpress.org/wordpress-$WP_VERSION.tar.gz
    tar -xzf wordpress-$WP_VERSION.tar.gz
    mkdir -p $WP_PATH
    cp -r wordpress/* $WP_PATH/
    rm -rf wordpress wordpress-$WP_VERSION.tar.gz
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

chown -R www-data:www-data $WP_PATH
chmod -R 755 $WP_PATH

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

# Change to WordPress directory for WP-CLI commands
cd $WP_PATH

# Check if WordPress is already installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress core..."
    
    # Install WordPress core (creates database tables and initial setup)
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="theboss@example.com" \
        --allow-root
    
    echo "WordPress core installed successfully!"
    
    # Create additional user (non-admin)
    echo "Creating additional user..."
    wp user create "$WP_USER" "user@example.com" \
        --user_pass="$WP_USER_PASS" \
        --role=author \
        --allow-root
    
    echo "Additional user created successfully!"
    
    # Optional: Create some sample content
    echo "Creating sample content..."
    wp post create \
        --post_title="Welcome to Inception Site" \
        --post_content="This is your first post. You can edit or delete it to get started with your website." \
        --post_status=publish \
        --allow-root
    
    echo "Sample content created!"
    
else
    echo "WordPress is already installed, skipping installation..."
fi

# Ensure proper permissions
chown -R www-data:www-data $WP_PATH
chmod -R 755 $WP_PATH

# Mark as concluded
touch "$SETUP_FLAG"

echo "WordPress successfully setup!"
echo "Admin user: $WP_ADMIN"
echo "Regular user: $WP_USER"
echo "Initializing php-fpm..."
exec php-fpm -F
