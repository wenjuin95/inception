FROM debian:latest

# handle php script efficiently in web server
# php-fpm        => a PHP-FastCGI Process Manager. It is a PHP language interpreter and manage php requests.
# php-mysql      => allow php to communicate with the mariadb
# mariadb-client => used to connect to the mariadb container for database management
# curl           => to download wp-cli tool
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php8.4-fpm php8.4-mysql mariadb-client curl && \
    rm -rf /var/lib/apt/lists/*

# copy custom php-fpm configuration file to the container
COPY conf/www.conf /etc/php/8.4/fpm/pool.d/.

# wp-cli is a tools to manage wordpress installation from command line
RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

#copy the script to current directory
COPY tools/setup_wordpress.sh .

# make the script executable
RUN chmod +x setup_wordpress.sh

# run the script to setup wordpress
ENTRYPOINT ["./setup_wordpress.sh"]