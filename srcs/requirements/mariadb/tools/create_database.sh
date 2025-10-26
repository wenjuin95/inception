#!/bin/bash

yellow='\033[0;33m'
reset='\033[0m'

# create a folder for initialization scripts
# Create socket dir
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# check if the mysql system database is initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${yellow}Initializing database${reset}"
    mysqld_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

#start the mysql server in the background with no networking
# "$!" captures the process ID of the last command run in the background
echo -e "${yellow}start MariaDb with no networking${reset}"
mysqld --skip-networking & pid="$!"

# wait for the mysql server to start
echo -e "${yellow}Waiting for MariaDb to start${reset}"
until mysqladmin ping --silent; do
    sleep 1
done

echo -e "${yellow}create database and user${reset}"
mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
echo -e "${yellow}Successfully created${reset}"

#stop the mysql server
echo -e "${yellow}Stopping MariaDb${reset}"
mysqladmin -u root -p"${MYSQL_PASSWORD}" shutdown
wait "$pid"

exec mysqld --user=mysql --bind-address=0.0.0.0

#test for successful database creation
#docker exec -it mariadb mysql -uwpuser -ppassword -e "SHOW DATABASES;"