NAME		= Inception
USER		= crocha-s


DOCKER_COMPOSE = ./srcs/docker-compose.yml

all: hosts up
	

hosts:
	@if ! grep -qFx "127.0.0.1 ${USER}.42.fr" /etc/hosts; then \
		sudo sed -i '2i\127.0.0.1\t${USER}.42.fr' /etc/hosts; \
	fi
up:
	sudo docker compose -f $(DOCKER_COMPOSE) up -d --build

down:
	@docker compose -f $(DOCKER_COMPOSE) down

