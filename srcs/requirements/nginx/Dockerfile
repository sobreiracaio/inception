FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
    nginx \
    openssl \
    curl \
    && apt clean

EXPOSE 443

COPY conf/default /etc/nginx/sites-available/default

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=BR/L=São Paulo/O=42sp/OU=student/CN=crocha-s.42.fr"

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
