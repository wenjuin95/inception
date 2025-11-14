FROM debian:latest

# install nginx and copy the configuration file to the container
RUN apt-get update && apt-get upgrade -y && apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*


#copy nginx conf to the container config directory
COPY ./conf/default.conf /etc/nginx/sites-available/default

COPY tool/get_cert.sh /get_cert.sh
RUN chmod +x /get_cert.sh

# expose 443 for other containers to be able to connect to nginx
EXPOSE 443

RUN /get_cert.sh

#this command is to ensure that nginx runs in the container
ENTRYPOINT ["nginx", "-g", "daemon off;"]