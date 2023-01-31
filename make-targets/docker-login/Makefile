#################################################################
## SECTION: Install docker unix compatible credentials
#################################################################

DOCKER_OFFICIAL_IMAGE := docker:stable
DOCKER_UNIX_CONFIG_FOLDER := ${HOME}/.docker-unix
DOCKER_UNIX_CONFIG_FILE := $(DOCKER_UNIX_CONFIG_FOLDER)/config.json

docker-login: ## Installs interactively the connection to Docker Hub for UB2
	@echo "Copying Docker credentials into $(DOCKER_UNIX_CONFIG_FOLDER)/config.json"
	docker run -it --rm \
		-v $(DOCKER_UNIX_CONFIG_FOLDER):/root/.docker:rw \
		--entrypoint docker \
		$(DOCKER_OFFICIAL_IMAGE) login
		$(MAKE) check-docker-login

check-docker-login: ## Checks that the connection to Docker Hub is properly configured to be used by UB2

	@if [[ ! -d $(DOCKER_UNIX_CONFIG_FOLDER) || ! -f $(DOCKER_UNIX_CONFIG_FILE) ]]; then \
		echo "Your Docker Hub credentials are not available for UB2!"; \
		echo "Please (re-)run $(bold)make install-docker-hub$(normal)"; \
	else \
		if [[ -z "`grep 'https://index.docker.io/v1/' $(DOCKER_UNIX_CONFIG_FILE)`" ]]; then \
			echo "Your Docker Hub credentials are not properly configured for UB2, fixing..."; \
			cat $(DOCKER_UNIX_CONFIG_FILE) | sed -i "s#\"\":#\"https://index.docker.io/v1/\":#g" $(DOCKER_UNIX_CONFIG_FILE); \
			$(MAKE) check-docker-login; \
		else \
			echo "Your Docker Hub credentials are now properly configured for UB2!"; \
		fi \
	fi
