FROM debian:latest

# install nginx and copy the configuration file to the container
RUN apt-get update && apt-get upgrade -y && apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*


#copy nginx conf to the container config directory
COPY ./conf/default.conf /etc/nginx/sites-available/default

COPY tool/get_cert.sh /get_cert.sh
RUN chmod +x /get_cert.sh

EXPOSE 443

ENTRYPOINT [ "/get_cert.sh" ]

#this command is to ensure that nginx runs in the container
CMD ["nginx", "-g", "daemon off;"]