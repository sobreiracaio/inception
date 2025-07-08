#Base Image

FROM	debian:bullseye


#Update/upgrade system and install mariaDB components

RUN	apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y mariadb-server mariadb-client


#Define arguments passed by docker compose file

ARG	MYSQL_DATABASE
ARG	MYSQL_USER
ARG	MYSQL_PASSWORD
ARG	MYSQL_ROOT_PASSWORD


#Create essential folders and setup ownership and appropriate privilegies

RUN	mkdir -p /var/lib/mysql
RUN	mkdir -p /var/run/mysql	
RUN	chown -R mysql:mysql /var/lib/mysql /var/run/mysql
RUN	chmod 777 /var/run/mysql


# Copy MariaDB conf file and and dump.sql file to the container

COPY	./conf/mariadb.cnf /etc/mysql/mariadb.conf.d/
RUN	chmod 644 /etc/mysql/mariadb.conf.d/mariadb.cnf


#MariaDB init script

COPY	./tools/setup.sh /usr/local/bin/
RUN	bash /usr/local/bin/setup.sh


#Port Expose to the host

EXPOSE 3306


#Run MariaDB

ENTRYPOINT ["mysqld_safe"]
