#################################################################
## SECTION: Targets for configuring local docker client to use deployment's dev and prod environments
#################################################################

setup-docker-context: ## Configures local docker client to use remote docker daemons as targets
	docker context create --description="https://github.com/RealImpactAnalytics/$(DELIVERY_REPO_NAME)" --docker "host=ssh://$(GROUP_CODE)-$(COUNTRY_CODE)-dev" $(GROUP_CODE)-$(COUNTRY_CODE)-dev
	docker context create --description="https://github.com/RealImpactAnalytics/$(DELIVERY_REPO_NAME)" --docker "host=ssh://$(GROUP_CODE)-$(COUNTRY_CODE)-prod" $(GROUP_CODE)-$(COUNTRY_CODE)-prod

use-remote-docker-dev: ## Switch your local docker client to use remote docker daemon on dev server
	docker context use $(GROUP_CODE)-$(COUNTRY_CODE)-dev

use-remote-docker-prod: ## Switch your local docker client to use remote docker daemon on prod server
	docker context use $(GROUP_CODE)-$(COUNTRY_CODE)-prod

use-local-docker: ## Switch your local docker client to use default local running docker daemon
	docker context use default
