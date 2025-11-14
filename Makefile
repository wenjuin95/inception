COMPOSE_FILE := ./srcs/docker-compose.yml

blue=\033[0;34m
green=\033[0;32m
reset=\033[0m

all: build up

# Build docker images
build:
	@mkdir -p ~/data/mariadb ~/data/wordpress
	@echo "${green}Create volume${reset}"
	@docker compose -f $(COMPOSE_FILE) build
	@bash "modify_host.sh"
	@echo "${green}Build docker containers${reset}"

# Start docker containers in the background ( so you can't see container logs )
up:
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "${green}Start docker containers${reset}"

# Stop docker containers
stop:
	@docker compose -f $(COMPOSE_FILE) stop
	@echo "${green}Stop docker containers${reset}"

#docker stop: stops all running containers
#docker rm: removes all containers
#docker rmi -f: force removes all images
#docker volume rm: removes all volumes
#docker network rm: removes all networks
fclean:
	@docker stop $$(docker ps -qa) || true
	@docker rm $$(docker ps -qa) || true
	@docker rmi -f $$(docker images -qa) || true
	@docker volume rm $$(docker volume ls -q) || true
	@docker network rm $$(docker network ls -q) 2>/dev/null || true
	@echo "${green}Remove docker containers, images, network and volumes${reset}"
	@sudo rm -rf ~/data/mariadb ~/data/wordpress
	@bash "remove_host.sh"
	@echo "${green}Remove volume directories${reset}"

re: fclean all

#show logs of all containers
logs:
	@docker compose -f $(COMPOSE_FILE) logs

#show active containers
ls:
	@docker compose -f $(COMPOSE_FILE) ps
