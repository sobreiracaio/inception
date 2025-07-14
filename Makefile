NAME		= Inception
USER		= crocha-s


DOCKER_CONFIG 	= $(shell echo $$HOME/.docker)
SYSTEM_USER		= $(shell echo $$USER)

#Volumes
WP_VOL = srcs_wordpress
MDB_VOL = srcs_mariadb


# Colors
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[38;5;81m
RESET = \033[0m

#YML file folder
DOCKER_COMPOSE = ./srcs/docker-compose.yml

all: setup_dirs hosts up
	@echo "\n"
	@echo "${RESET}##############################################################################${NC}"
	@echo "${BLUE}#               ${NAME} is up and running for user:${YELLOW} ${USER}${BLUE}               #${RESET}"
	@echo "${BLUE}#               Wordpress runs at:${YELLOW} ${USER}.42.fr ${BLUE}                           #${RESET}"
	@echo "${BLUE}#              For admin access go to:${YELLOW} ${USER}.42.fr/wp-admin ${BLUE}              #${RESET}"
	@echo "${RESET}##############################################################################${NC}"

setup_dirs:
	sudo mkdir -p /home/$(USER)/data/mariadb
	sudo mkdir -p /home/$(USER)/data/wordpress
	sudo chmod 777 /home/$(USER)/data/mariadb
	sudo chmod 777 /home/$(USER)/data/wordpress  	
		

hosts:
	@echo "\n"
	@echo "${BLUE} Adding domain name to hosts file ${RESET}"
	@if ! grep -qFx "127.0.0.1 ${USER}.42.fr" /etc/hosts; then \
		sudo sed -i '2i\127.0.0.1\t${USER}.42.fr' /etc/hosts; \
	fi
	@echo "${BLUE} Domain name successfully added to hosts file. ${RESET}"

up:
	@echo "${BLUE} Starting docker compose... ${RESET}"
	sudo docker compose -f $(DOCKER_COMPOSE) up -d --build
	@echo "${BLUE}Docker compose up and running ${RESET}"

		
down:
	@echo "${YELLOW} Stopping docker compose... ${RESET}"
	@docker compose -f $(DOCKER_COMPOSE) down
	@echo "${RED}Docker compose stopped!${RESET}"

clean: down
	@echo "${YELLOW} Cleaning docker: Removing volumes and removing domaing from hosts file${RESET}"
	docker volume rm ${WP_VOL}
	docker volume rm ${MDB_VOL}
	sudo sed -i '/127\.0\.0\.1\t${USER}\.42\.fr/d' /etc/hosts
	sudo rm -rf /home/$(USER)
	@echo "${RED}Docker volumes and domain removed!${RESET}"

re: down all

prepare: update

update:
	@echo "${BLUE}Updating System${RESET}"
	sudo apt -y update && sudo apt -y upgrade
			@if [ $$? -eq 0 ]; then \
				echo "${GREEN}System updated${RESET}"; \
				echo "${BLUE}Installing Docker${RESET}"; \
				sudo apt -y install docker.io && sudo apt -y install docker-compose; \
				if [ $$? -eq 0 ]; then \
					echo "${GREEN}Docker and docker-compose installed${RESET}"; \
				else \
					echo "${RED}Docker or docker-compose installation failed${RESET}"; \
				fi \
			else \
				echo "${RED}System update failed${RESET}"; \
			fi


PHONY:	all clean re prepare



