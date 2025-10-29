#!/bin/bash
set -e

cyan='\033[1;36m'
reset='\033[0m'

# SSL is used to encrypt the communication between server and browser
# without SSL, all data is sent in plain text and can be intercepted by attackers

# create the SSL dir to store the certificate and key
mkdir -p /etc/nginx/ssl

# create self-signed SSL certificate if not exists
if [ ! -f "/etc/nginx/ssl/nginx.crt" ] || [ ! -f "/etc/nginx/ssl/nginx.key" ]; then
    echo -e "${cyan}Generating self-signed SSL certificate${reset}"

    # openssl req      : command to generate SSL cert
    # -x509            : create a self-signed certificate
    # -nodes           : private key will not be encrypted
    # -days 365        : validity of the certificate
    # -newkey rsa:2048 : generate a new RSA key of 2048
    # -keyout          : path to save the private key
    # -out             : path to save the certificate
    # -subj            : subject information for the certificate
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