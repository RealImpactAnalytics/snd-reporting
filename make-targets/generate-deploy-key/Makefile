#################################################################
## SECTION: Targets for configuring local docker client to use deployment's dev and production environments
#################################################################

create-deploy-key: ## Generates a ssh key to upload to github as deploy key
	@ssh-keygen -t ed25519 -f $(CURDIR)/secrets/github_deploy_key/git-deploy-key -C "it@riaktr.com" -q -N ""
