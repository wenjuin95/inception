#!/bin/bash

set -e

green='\033[0;32m'
reset='\033[0m'

# Ensure the PHP session directory exists
mkdir -p /run/php

# Wait for MariaDB to be ready
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
	sleep 1
done
echo -e "${green}MariaDB server started${reset}"

# Set ownership of WordPress files (for ownership by www-data)
chown -R www-data:www-data /var/www/html/
cd /var/www/html/

# Check if WordPress is already installed and setup
if [ ! -f wp-config.php ]; then
    # Download WordPress
    echo -e "${green}downloading wordpress...${reset}"
    wp core download --allow-root

    # Create wp-config.php (for database connection)
    echo -e "${green}creating wp-config.php...${reset}"
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root

    # Install WordPress
    echo -e "${green}installing wordpress and set up admin...${reset}"
    wp core install \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Create WordPress user
    echo -e "${green}creating wordpress user...${reset}"
    wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" \
    --user_pass="${WORDPRESS_USER_PASSWORD}" \
    --role=subscriber \
    --allow-root
fi

# Modify PHP-FPM to listen on all interfaces at port 9000
sed -i 's|listen = /run/php/php8.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/8.4/fpm/pool.d/www.conf

# Start PHP-FPM
php-fpm8.4 -F

# https://welow.42.fr/wp-admin => admin panel
