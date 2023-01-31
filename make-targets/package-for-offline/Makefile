#################################################################
## SECTION: Packaging targets for offline deployments
#################################################################

packages: download-images package-images ## Generates docker images tarball for offline deployment

download-images: use-local-docker ## Downloads the deployment docker images fron Docker Hub for local availability (requires docker login and an account on HUB)
	docker-compose -f deployer-compose.yml pull
	docker-compose -f deployment/docker-compose.yml pull

# Might need to adapt in case of need of packaging multiple stacks
package-images: use-local-docker ## Packages the deployment docker images into a tarball for offline deployment
	docker save $(shell { docker compose -f deployment/docker-compose.yml config --images & docker compose -f deployer-compose.yml config --images; }) | \
	 pigz - > $(IMAGE_TAR)

load-images-on-dev: use-remote-docker-dev
	docker load -i $(IMAGE_TAR)

load-images-on-prod: use-remote-docker-prod
	docker load -i $(IMAGE_TAR)

package-repo: ## Packages the git repository receipe for offline deployment
	tar --exclude="*.tar.gz" --exclude="*.DS_Store" --exclude=".idea" --exclude=".vscode" -cvzf $(REPO_TAR_WITH_DATE) .

mirror-repo-on-remote-dev-server: ## Upload the repository tarball to the remote dev server
	rsync -azv --delete --progress --stats --filter=':- .gitignore' ./ $(GROUP_CODE)-$(COUNTRY_CODE)-dev:/RIA/$(DELIVERY_REPO_NAME)/

mirror-repo-on-remote-prod-server: ## Upload the repository tarball to the remote prod server
	rsync -azv --delete --progress --stats --filter=':- .gitignore' ./ $(GROUP_CODE)-$(COUNTRY_CODE)-prod:/RIA/$(DELIVERY_REPO_NAME)/

images-package-parallel-upload: ## Uploads the docker images tarball in parallel for faster offline deployments
	./local_assets/scripts/parallel_upload.sh $(IMAGE_TAR) $(GROUP_CODE)-$(COUNTRY_CODE)-dev
