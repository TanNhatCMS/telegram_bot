
# Self-Documented Makefile
.PHONY: help
help:
	@grep -E '^[a-zA-Z_0-9-]+(-%)?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

ENV_FILE = config/config.env
# Định nghĩa tên container
CONTAINER_MONGO_PRIMARY=mongo-primary
CONTAINER_MONGO_SECONDARY=mongo-secondary
CONTAINER_MONGO_INIT_REPLICA=mongo-init-replica
# Định nghĩa volumes
VOLUME_MONGODB=mongodb-volume
VOLUME_APP=app-volume
$(shell if [ ! -e "$(ENV_FILE)" ]; then cp -a config/config.example.env config/config.env; fi)

.PHONY: setup
setup: ## Build the container
	$(MAKE) build

.PHONY: build
build: ## Build the container
	docker compose down
	docker-compose --env-file $(ENV_FILE) up -d --build
	@echo "Containers are up and running."

.PHONY: logs
logs: ## Show logs
	docker-compose logs -f

.PHONY: stop
stop: ## Stop the container
	   docker-compose down
	   @echo "Containers have been stopped."

.PHONY: restart
restart: ## Restart the container
	   docker-compose restart
	   @echo "Containers have been restarted."

.PHONY: status
status: ## Check the status of the container
	   docker ps -a

.PHONY: shell-primary
shell-primary: ## Access the primary mongo shell
	   docker exec -it $(CONTAINER_MONGO_PRIMARY) mongo -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin

.PHONY: shell-secondary
shell-secondary: ## Access the secondary mongo shell
	   docker exec -it $(CONTAINER_MONGO_SECONDARY) mongo -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin

.PHONY: recreate
recreate: ## Recreate the MongoDB
	   docker-compose down && docker-compose up -d --build
	   @echo "Containers have been recreated and are running."