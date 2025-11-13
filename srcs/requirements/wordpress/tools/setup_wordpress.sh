#!/bin/bash

# terminate the script if any command fails
set -e

green='\033[0;32m'
reset='\033[0m'

# a directory to store process id and socket
mkdir -p /run/php

# change ownership of /run/php to www-data
# www-data is the user that php and nginx run as inside container
# var/www/html is the default root directory where wordpress files will be stored
chown -R www-data:www-data /run/php && \
mkdir -p /var/www/html/
cd /var/www/html/

# Wait for MariaDB to be ready
echo -e "${green}waiting for mariadb to be start...${reset}"
while ! mysqladmin ping -h"$MYSQL_DATABASE" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo -e "${green}MariaDB not started yet${reset}"
	sleep 5
done
echo -e "${green}MariaDB started${reset}"


# Check if WordPress is already installed and setup
if [ ! -f wp-config.php ]; then
    # Download WordPress
    # --allow-root is used to run wp-cli commands as root user
    echo -e "${green}WordPress not installed. Installing...${reset}"
    wp core download --allow-root

    # Create wp-config.php file for database connection
    echo -e "${green}creating wp-config.php...${reset}"
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root

    # Install WordPress
    # configure wordpress by creating database tables and setting up admin account
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

# Start PHP-FPM
# -F ensure php-fpm stay running and handle php request continuously and keep container alive
echo -e "${green}starting php-fpm8.4...${reset}"
php-fpm8.4 -F

# https://welow.42.fr/wp-admin => admin panel
