#Base image

FROM	debian:bullseye


#Define enviroment variables passed from docker-compose.yml

ARG	DOMAIN_NAME
ARG 	CERTS_KEY
ARG	CERTS_CRT


# Update and upgrade system & install Nginx and OpenSSL (certificate tool)

RUN 	apt -y update && apt -y upgrade
RUN 	apt -y install nginx openssl 


#Generate self-signed certificate

RUN 	openssl req -x509 -sha256 -nodes \
		-newkey rsa:4096 \
		-days 365 \
		-subj "/C=BR/ST=Sao Paulo/L=Sao Paulo/O=42SP/OU=Inception/CN=userlogin.42.fr" \
		-keyout ${CERTS_KEY} \
		-out ${CERTS_CRT} 


#Make sure Nginx is using TSL v1.3 (Security protocol for https preparing the nginx server)

RUN 	sed -i 's/ssl_protocols.*/ssl_protocols TLSv1.3;/' /etc/nginx/nginx.conf


#Setup configuration files (includes certificates paths and domain)
COPY 	./conf/https.conf /etc/nginx/conf.d/
RUN	sed -i "s|INSERT_DOMAIN_NAME_HERE|${DOMAIN_NAME}|g" /etc/nginx/conf.d/https.conf
RUN 	sed -i "s|INSERT_KEY_PATH_HERE|${CERTS_KEY}|g" /etc/nginx/conf.d/https.conf
RUN 	sed -i "s|INSERT_CRT_PATH_HERE|${CERTS_CRT}|g" /etc/nginx/conf.d/https.conf
COPY 	./conf/http.conf /etc/nginx/conf.d/
RUN	sed -i "s|INSERT_DOMAIN_NAME_HERE|${DOMAIN_NAME}|g" /etc/nginx/conf.d/https.conf

#Expose Port

EXPOSE	443

#Execute Nginx (daemon off = do not run in background)

ENTRYPOINT	[ "nginx", "-g", "daemon off;" ]
