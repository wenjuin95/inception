#!/bin/bash

# This script automatically adds the project's domain name to the /etc/hosts file.
# It allows you to access your local Docker services using a custom domain
# instead of just 'localhost' or '127.0.0.1'.

# Set the path to your .env file
# Assuming this script is run from the 'srcs' directory
ENV_FILE="./srcs/.env"

# Check if the .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found in the current directory."
    exit 1
fi

# Source the .env file to load environment variables
export $(grep -v '^#' $ENV_FILE | xargs)

IP="127.0.0.1"

# Check if the domain is already in /etc/hosts
if grep -q "${IP}[[:space:]]*${DOMAIN_WEBSITE}" /etc/hosts; then
    echo "${DOMAIN_WEBSITE} is already in /etc/hosts."
else
    echo "Adding ${DOMAIN_WEBSITE} to /etc/hosts. Sudo password may be required."
    echo "${IP} ${DOMAIN_WEBSITE}" | sudo tee -a /etc/hosts > /dev/null
fi