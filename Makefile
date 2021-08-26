.PHONY: test

DEBIAN_VERSION				:= `cat ./configs/versions/debian-version`
NODE_VERSION				:= `cat ./configs/versions/node-version`
NPM_VERSION					:= `cat ./configs/versions/npm-version`

IMAGE_NAME 					:= typescript-stack-image
IMAGE_VERSION				:= $(or ${IMAGE_VERSION}, ${IMAGE_VERSION}, latest)
CONTAINER_ID				:= $(or ${CONTAINER_ID}, ${CONTAINER_ID}, `date +%s`)

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\):.*##[ \t]*/    \1 ## /' | column -t -s '##'
	@echo


## Docker commands:

build: ## Build base docker image
	docker build --force-rm $(call build_arguments) .

destroy: ## Destroy base docker container and image
	-$(call destroy_containers,$(IMAGE_NAME))
	-$(call destroy_images,$(IMAGE_NAME))

images: ## Show base docker images
	docker image ls --all $(IMAGE_NAME)

containers: ## Show running containers
	docker container ls --all --filter name=$(IMAGE_NAME)

bash: ## Run bash shell
	docker run --user user --interactive --tty --rm --name $(IMAGE_NAME)$(CONTAINER_ID) $(IMAGE_NAME):$(IMAGE_VERSION) bash

check-node: ## Check NodeJS version
	$(eval CONTAINER_NODE_VERSION := $(call check,node))
	$(eval EXPECTED_NODE_VERSION := $(NODE_VERSION))
	@if [ "$(CONTAINER_NODE_VERSION)" == "$(EXPECTED_NODE_VERSION)" ]; then echo "Ok" && exit 0; else echo "Error" && exit 1; fi

check-npm: ## Check NPM version
	$(eval CONTAINER_NPM_VERSION := $(call check,npm))
	$(eval EXPECTED_NPM_VERSION := $(NPM_VERSION))
	@if [ "$(CONTAINER_NPM_VERSION)" == "$(EXPECTED_NPM_VERSION)" ]; then echo "Ok" && exit 0; else echo "Error" && exit 1; fi

check-install: ## Check NPM package install
	docker run --user user --rm --name $(IMAGE_NAME)$(CONTAINER_ID) $(IMAGE_NAME):$(IMAGE_VERSION) bash -c "\
		npm init --yes && \
		npm install typescript@latest ts-node@latest && \
		./node_modules/.bin/ts-node -e 'console.log(\"It works!\")'"


define build_arguments
	--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg NPM_VERSION=$(NPM_VERSION) \
	--label debian_version=$(DEBIAN_VERSION) \
	--label node_version=$(NODE_VERSION) \
	--label npm_version=$(NPM_VERSION) \
	--label image_version=$(IMAGE_VERSION) \
	--tag $(IMAGE_NAME):$(IMAGE_VERSION)
endef

define destroy_containers
	docker container rm --force `docker container ls --all --quiet --filter name=$(1)` 2>/dev/null
endef

define destroy_images
	docker image rm --force `docker image ls --all --quiet $(1)` 2>/dev/null
endef

define check
	$(shell sh -c "docker run --user user --rm --name $(IMAGE_NAME)$(CONTAINER_ID) $(IMAGE_NAME):$(IMAGE_VERSION) $(1) --version | tr -d v")
endef

