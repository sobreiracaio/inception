

DOCKER_COMPOSE = ./srcs/docker-compose.yml

inception: 
	docker-compose -f $(DOCKER_COMPOSE) up -d --build

