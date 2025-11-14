#!/bin/bash

# This script automatically removes the project's domain name from the /etc/hosts file.

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

# Check if the domain is in /etc/hosts
if grep -q "${IP}[[:space:]]*${DOMAIN_WEBSITE}" /etc/hosts; then
    echo "Removing '${DOMAIN_WEBSITE}' from /etc/hosts. Sudo password may be required."
    # Use sed to delete the line containing the domain. The pattern looks for the IP,
    # optional whitespace, and the domain name to ensure the correct line is removed.
    sudo sed -i.bak "/[[:space:]]*${DOMAIN_WEBSITE}/d" /etc/hosts
    echo "'${DOMAIN_WEBSITE}' removed from /etc/hosts."
else
    echo "'${DOMAIN_WEBSITE}' was not found in /etc/hosts."
fi