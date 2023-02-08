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

# For the moment only one value is supported by the make targets
DOCKER_HUB_ORG := riaktr

include ./make-targets/etl-provisioning/Makefile

