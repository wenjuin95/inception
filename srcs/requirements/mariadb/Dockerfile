FROM debian:latest

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    # clean up the apt cache
    rm -rf /var/lib/apt/lists/*

#copy the config file to container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

#/run/mysqld: store the socket file and the process id file
#/var/lib/mysql: store the database files
#/var/log/mysql: store the log files
#set the ownership to mysql mean the only that user can access it
RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql

#copy the database config to the current directory
COPY tools/create_database.sh .

# make it executable
RUN chmod +x create_database.sh


#this script will run first
ENTRYPOINT [ "./create_database.sh" ]