FROM debian:latest

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    # clean up the apt cache
    rm -rf /var/lib/apt/lists/*

#copy the config file to container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

#copy the database config to the current directory
COPY tools/create_database.sh .

# make it executable
RUN chmod +x create_database.sh

#/run/mysqld: store the socket file for communication between the server and the client
#set the ownership to mysql mean the only that user can access it
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

#this script will run first
ENTRYPOINT [ "./create_database.sh" ]