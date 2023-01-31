.PHONY: *
.DEFAULT_GOAL := help
SHELL := /bin/bash

# Text formating in terminal
underline := \033[4m
bold := \033[1m
normal := \033[0m
red := \033[0;31m
blue := \033[36m
nc := \033[0m # No Color

help:
	@echo -e "\n$(bold)$(underline)Make targets$(normal) (run 'make <target>')"
	@for makefile in $(MAKEFILE_LIST); do\
		echo -e "\n$(bold)`grep -E '^## SECTION:' $${makefile} | cut -d':' -f2`$(normal)"; \
		grep -E '^[a-zA-Z_-]+[%]*:.*?## .*$$' $${makefile} | cut -d":" -f1,2 | awk 'BEGIN {FS = ":.*?## "}; {printf "  * \033[36m%-38s\033[0m  %s\n", $$1, $$2}'; \
	done
	@echo ""

DEPLOYER_COMPOSE := DEPLOYER_VERSION=$(DEPLOYER_VERSION) docker-compose -p deployer -f deployer-compose.yml
DAEMON_DEPLOYER_COMPOSE := DEPLOYER_VERSION=$(DEPLOYER_VERSION) docker-compose -p daemon-deployer -f deployer-compose-daemonized.yml

# For instance mtn or ora
GROUP_CODE := __GROUP_CODE_TO_SETUP__
# For instance ng for nigeria
COUNTRY_CODE := ___CODE_TO_SETUP__

DEV_IP=__DEV_IP_TO_SETUP__
PROD_IP=__PROD_IP_TO_SETUP__

# For instance ce-mtn-gn-delivery or ce-orange-gn-delivery
DELIVERY_REPO_NAME := __REPOSITORY_NAME_TO_SETUP__
DATE := $(shell date +%Y%m%d)

IMAGE_TAR := $(DELIVERY_REPO_NAME)-images-$(DATE).tar.gz
REPO_TAR_WITH_DATE := $(DELIVERY_REPO_NAME)-git-repo-$(DATE).tar.gz
REPO_TAR := $(DELIVERY_REPO_NAME)-git-repo.tar.gz

# For the moment only one value is supported by the make targets
DOCKER_HUB_ORG := riaktr

include ./make-targets/configure-local-docker/Makefile
include ./make-targets/deploy-on-servers/compose_Makefile
include ./make-targets/deploy-on-servers/swarm_Makefile
include ./make-targets/docker-login/Makefile
include ./make-targets/etl-provisioning/Makefile
include ./make-targets/frontend-shortcut/Makefile
include ./make-targets/generate-deploy-key/Makefile
include ./make-targets/housekeeping/Makefile
include ./make-targets/package-for-offline/Makefile
