#!/bin/bash

set -e

yellow='\033[0;33m'
reset='\033[0m'

# set default database inside the /var/lib/mysql directory
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${yellow}Initializing database${reset}"
    mysqld_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

#start the mysql server in the background with no networking
# "$!" captures the process ID of the last command run in the background
echo -e "${yellow}start MariaDb with no networking${reset}"
mysqld --skip-networking & pid="$!"

# check if the mysql server is up and running
echo -e "${yellow}starting mariadb...${reset}"
while ! mysqladmin ping --silent; do
    echo -e "${yellow}waiting mariadb to start...${reset}"
    sleep 1
done
echo -e "${yellow}mariadb started${reset}"

# Secure root and create DB/user only if not already done
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo -e "${yellow}create database and user${reset}"

    # First run: root has no password yet
    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL
    echo -e "${yellow}database and user created${reset}"
else
    echo -e "${yellow}database already exists, skipping creation${reset}"
fi

#stop the mysql server
echo -e "${yellow}Stopping MariaDb${reset}"
if ! mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown 2>/dev/null; then
    # if shutdown command fails (password wrong or other), kill the background process
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
fi

#start the mysql server with networking enabled ( any IP can connect )
exec mysqld --user=mysql --bind-address=0.0.0.0

# To connect to the mariadb container and check databases

# -it : interactive terminal
#docker exec -it mariadb bash

# To check databases inside the mariadb container
# mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SHOW DATABASES;"