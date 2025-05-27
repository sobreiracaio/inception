

DOCKER_COMPOSE = ./srcs/docker-compose.yml

VOLUMES_FOLDER = /home/crocha-s/data

inception: mkdirs
	docker compose -f $(DOCKER_COMPOSE) up -d --build


install:
	@echo "\033[1;34mUninstalling possible conflicting packages...\033[0m"
	@for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do \
		sudo apt-get remove -y $$pkg; \
	done

	@echo "\033[1;34mUpdating packages and installing prerequisites...\033[0m"
	@sudo apt-get update
	@sudo apt-get install -y ca-certificates curl

	@echo "\033[1;34mAdding Docker's official GPG key...\033[0m"
	@sudo install -m 0755 -d /etc/apt/keyrings
	@sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	@sudo chmod a+r /etc/apt/keyrings/docker.asc

	@echo "\033[1;34mAdding Docker repository to APT sources...\033[0m"
	@echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $$(. /etc/os-release && echo $$VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	@echo "\033[1;34mUpdating package list from Docker repository...\033[0m"
	@sudo apt-get update

	@echo "\033[1;34mInstalling Docker engine and plugins...\033[0m"
	@sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	
	@echo "127.0.0.1 crocha-s.42.fr" | sudo tee -a /etc/hosts

	@echo "\033[1;32mDocker installation complete!\033[0m"

mkdirs:
	@sudo mkdir -p $(VOLUMES_FOLDER)/mariadb
	@sudo mkdir -p $(VOLUMES_FOLDER)/wp_db
