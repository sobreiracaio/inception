FROM debian:bullseye

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y mariadb-server

EXPOSE 3306

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY tools/setup.sh .

RUN chmod +x setup.sh
RUN mkdir -p /run/mysql

ENTRYPOINT ["./setup.sh"]
