COMPOSE_FILE := ./srcs/docker-compose.yml

blue=\033[0;34m
green=\033[0;32m
reset=\033[0m

all: build up

build:
	@mkdir -p ~/data/mariadb ~/data/wordpress
	@echo "${green}Create volume${reset}"
	@docker compose -f $(COMPOSE_FILE) build --no-cache
	@echo "${green}Build docker containers${reset}"

up:
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "${green}Start docker containers${reset}"

stop:
	@docker compose -f $(COMPOSE_FILE) stop
	@echo "${green}Stop docker containers${reset}"

down:
	@docker compose -f $(COMPOSE_FILE) down
	@echo "${green}Remove docker containers${reset}"

fclean:
	@docker stop $$(docker ps -qa) || true
	@docker rm $$(docker ps -qa) || true
	@docker rmi -f $$(docker images -qa) || true
	@docker volume rm $$(docker volume ls -q) || true
	@docker network rm $$(docker network ls -q) 2>/dev/null || true
	@echo "${green}Remove docker containers, images, network and volumes${reset}"
	@sudo rm -rf ~/data/mariadb ~/data/wordpress
	@echo "${green}Remove volume directories${reset}"

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

ls:
	@docker compose -f $(COMPOSE_FILE) ps
