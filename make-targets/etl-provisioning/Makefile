#################################################################
## SECTION: ETL provisioning
#################################################################

# Git information
GIT_SHORT_HASH = $(shell git rev-parse --short HEAD)
GIT_BRANCH = $(shell git rev-parse --symbolic-full-name --abbrev-ref HEAD | tr -s "/" "_" | tr -s ":" "_")

# Set current working directory
CURRENT_WORKDIR = $(if $(LOCAL_WORKSPACE_FOLDER),$(LOCAL_WORKSPACE_FOLDER),$(PWD))


# Docker image information
IMAGE_REPO = $(DOCKER_HUB_ORG)/snd-reporting
IMAGE_WITH_COMMIT_TAG = $(IMAGE_REPO):$(GIT_SHORT_HASH)
IMAGE_BRANCH_LATEST = $(IMAGE_REPO):$(GIT_BRANCH)

# MINIO connection
PROVISIONING_ENVS = -e MINIO_ACCESS_KEY_ID=admin -e MINIO_SECRET_ACCESS_KEY=snd@ria123
REPO_NAME = snd-reporting


build-etl: ## Build etl-provisioning image
	@echo "Building etl provisioning image"
	DOCKER_BUILDKIT=1 docker build -f provisioning/Dockerfile --platform linux/amd64 -t $(IMAGE_WITH_COMMIT_TAG) --progress=plain .


provision-etl-dev-server:  build-etl ## Build and runs the provisioning for deploying on the dev server
	$(if $(ssh_cmd),,$(error 'No ssh_cmd specified!'))
	rm -rf tmp
	docker run --rm --entrypoint cp -v ${PWD}/tmp:/ria/tmp $(IMAGE_WITH_COMMIT_TAG) -R /ria/{jobs,metadata,flows} /ria/tmp
	rsync -azv --delete --progress --stats tmp/ $(ssh_cmd):/tmp/$(REPO_NAME)
	ssh $(ssh_cmd) docker run --net ria $(PROVISIONING_ENVS) -i --rm \
		-v /tmp/$(REPO_NAME)/flows:/ria/flows \
		-v /tmp/$(REPO_NAME)/jobs:/ria/jobs \
		-v /tmp/$(REPO_NAME)/metadata:/ria/metadata $(IMAGE_BRANCH_LATEST)

publish-etl: build-etl ## Build and push etl-provisioning image
	@echo "Publishing image $(IMAGE_WITH_COMMIT_TAG)"
	@docker tag $(IMAGE_WITH_COMMIT_TAG) $(IMAGE_BRANCH_LATEST)
	@docker push $(IMAGE_WITH_COMMIT_TAG)
	@docker push $(IMAGE_BRANCH_LATEST)