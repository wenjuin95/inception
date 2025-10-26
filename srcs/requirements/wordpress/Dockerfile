FROM debian:latest

# handle php script efficiently in web server
# php-fpm        => FastCGI Process Manager for PHP scripts
# php-mysql      => extension for PHP to interact with mariaDB databases
# php-curl       => extension for PHP to make HTTP requests
# php-xml        => extension for PHP to parse XML documents
# php-mbstring   => extension for PHP to handle multibyte strings
# php-zip        => extension for PHP to handle ZIP files
# php-gd         => extension for PHP to handle image processing
# php-cli        => command line interface for PHP
# mariadb-client => to interact with mariadb databases from command line
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php8.4-fpm php8.4-mysql php8.4-curl php8.4-xml php8.4-mbstring \
    php8.4-zip php8.4-gd php8.4-cli mariadb-client curl wget unzip && \
    rm -rf /var/lib/apt/lists/*

# install wp-cli ( this is a command line tool to manage wordpress installations )
RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

#copy the script to current directory
COPY tools/setup_wordpress.sh .

# make the script executable
RUN chmod +x setup_wordpress.sh

# run the script to setup wordpress
CMD ["./setup_wordpress.sh"]