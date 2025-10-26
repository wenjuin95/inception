#!/bin/bash
set -e

cyan='\033[1;36m'
reset='\033[0m'

# create the SSL dir that matches nginx config
mkdir -p /etc/nginx/ssl


if [ ! -f "/etc/nginx/ssl/nginx.crt" ] || [ ! -f "/etc/nginx/ssl/nginx.key" ]; then
    echo -e "${cyan}Generating self-signed SSL certificate${reset}"

    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "/etc/nginx/ssl/nginx.key" \
        -out "/etc/nginx/ssl/nginx.crt" \
        -subj "/C=MY/ST=SELANGOR/L=SUBANGJAYA/O=IT/OU=IT/CN=welow.42.fr"
else
    echo -e "${cyan}SSL certificate already exists.${reset}"
fi

echo -e "${cyan}SSL certificate completed.${reset}"
exec "$@" # Run the CMD (nginx)