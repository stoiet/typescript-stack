.PHONY: test

DEBIAN_VERSION				:= `cat ./configs/versions/debian-version`
NODE_VERSION				:= `cat ./configs/versions/node-version`
NPM_VERSION					:= `cat ./configs/versions/npm-version`

DOCKER_COMPOSE_FILE			:= ./configs/docker/docker-compose.yaml

IMAGE_NAME 					:= typescript-stack
IMAGE_TAG					:= $(or ${IMAGE_TAG}, ${IMAGE_TAG}, latest)
CONTAINER_ID				:= $(or ${CONTAINER_ID}, ${CONTAINER_ID}, `date +%s`)

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\):.*##[ \t]*/    \1 ## /' | column -t -s '##'
	@echo


## Docker commands:

build: ## Build project image
	$(call docker_compose) build $(IMAGE_NAME)

destroy: ## Destroy project containers and image
	$(call docker_compose) down --rmi all --remove-orphans

images: ## List project images
	$(call docker_compose) images $(IMAGE_NAME)

containers: ## List project containers
	$(call docker_compose) ps --all

bash: ## Run bash shell
	$(call docker_compose_run) bash


## Check commands

check-node: ## Check NodeJS version
	$(eval CONTAINER_NODE_VERSION := $(call check,node))
	$(eval EXPECTED_NODE_VERSION := $(NODE_VERSION))
	@if [ "$(CONTAINER_NODE_VERSION)" == "$(EXPECTED_NODE_VERSION)" ]; then echo "Ok" && exit 0; else echo "Error" && exit 1; fi

check-npm: ## Check NPM version
	$(eval CONTAINER_NPM_VERSION := $(call check,npm))
	$(eval EXPECTED_NPM_VERSION := $(NPM_VERSION))
	@if [ "$(CONTAINER_NPM_VERSION)" == "$(EXPECTED_NPM_VERSION)" ]; then echo "Ok" && exit 0; else echo "Error" && exit 1; fi

check-install: ## Check NPM package install
	docker run --user user --rm --name $(IMAGE_NAME)$(CONTAINER_ID) $(IMAGE_NAME):$(IMAGE_TAG) bash -c "\
		npm init --yes && \
		npm install typescript@latest ts-node@latest && \
		./node_modules/.bin/ts-node -e 'console.log(\"It works!\")'"


## NPM commands

audit: ## Audit dependencies
	$(call docker_compose_run) npm audit

install: ## Install dependencies
	$(call docker_compose_run) npm ci --ignore-scripts

execute: ## Run application
	$(call docker_compose_run) npm run execute


define check
	$(shell sh -c "$(call docker_compose_run) $(1) --version | tr -d v")
endef

define docker_compose
	$(call docker_compose_file_variables) docker-compose --file $(DOCKER_COMPOSE_FILE) --project-name $(IMAGE_NAME)
endef

define docker_compose_run
	$(call docker_compose) run --name $(IMAGE_NAME)-$(CONTAINER_ID) --user=user --use-aliases --no-deps --rm $(IMAGE_NAME)
endef

define docker_compose_file_variables
	IMAGE_NAME=$(IMAGE_NAME) \
	IMAGE_TAG=$(IMAGE_TAG) \
	CONTAINER_ID=$(CONTAINER_ID) \
	DEBIAN_VERSION=$(DEBIAN_VERSION) \
	NODE_VERSION=$(NODE_VERSION) \
	NPM_VERSION=$(NPM_VERSION)
endef
