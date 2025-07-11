#Base Image

FROM	debian:bullseye


#Update/upgrade system and install mariaDB components

RUN	apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y mariadb-server mariadb-client


#Define enviroment variables passed by docker compose file

ARG	MYSQL_DATABASE
ARG	MYSQL_USER
ARG	MYSQL_PASSWORD
ARG	MYSQL_ROOT_PASSWORD
ARG	USER_INCEPTION

ENV	USER_INCEPTION=${USER_INCEPTION}
ENV	MYSQL_DATABASE=${MYSQL_DATABASE}
ENV	MYSQL_USER=${MYSQL_USER}
ENV	MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV	MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}


#Create essential folders and setup ownership and appropriate privilegies

RUN	mkdir -p /var/lib/mysql
RUN	mkdir -p /var/run/mysqld	
RUN	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN	chmod 777 /var/run/mysqld


# Copy MariaDB conf file to the container

COPY	./conf/mariadb.cnf /etc/mysql/mariadb.conf.d/
RUN	chmod 644 /etc/mysql/mariadb.conf.d/mariadb.cnf
RUN	mkdir -p /home/${USER_INCEPTION}/data/mariadb
RUN	chmod 755 /home/${USER_INCEPTION}/data/mariadb




#MariaDB init script

COPY	./tools/setup.sh /usr/local/bin/
RUN	chmod +x /usr/local/bin/setup.sh
RUN	bash /usr/local/bin/setup.sh


#Port Expose to the host

EXPOSE 3306


#Run MariaDB

ENTRYPOINT ["mysqld_safe"]
