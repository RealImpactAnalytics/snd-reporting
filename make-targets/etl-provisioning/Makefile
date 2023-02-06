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
IMAGE_WITH_COMMIT_TAG = $(IMAGE_REPO):$(git_short_hash)
IMAGE_BRANCH_LATEST = $(IMAGE_REPO):$(git_branch)

# MINIO connection
PROVISIONING_ENVS = -e MINIO_ACCESS_KEY_ID=admin -e MINIO_SECRET_ACCESS_KEY=snd@ria123


build-etl: ## Build etl-provisioning image
	@echo "Building etl provisioning image"
	DOCKER_BUILDKIT=1 docker build -f provisioning/Dockerfile --platform linux/amd64 -t $(IMAGE_WITH_COMMIT_TAG) --progress=plain .


provision-etl-dev-server: build-etl ## Build and runs the provisioning for deploying on the dev server
	$(if $(ssh_cmd),,$(error 'No ssh_cmd specified!'))
	rm -rf tmp
	docker run --rm --entrypoint cp -v ${CURRENT_WORKDIR}/tmp:/ria/tmp $(IMAGE_WITH_COMMIT_TAG) -R /ria/{dags,jobs,metadata,flows} /ria/tmp
	rsync -azv --delete --progress --stats tmp/ $(GROUP_CODE)-$(COUNTRY_CODE)-dev:/tmp/etl-provisioning
	ssh $(ssh_cmd) docker run --net ria $(PROVISIONING_ENVS) -i --rm -v /tmp/etl-provisioning/flows:/ria/flows -v /tmp/etl-provisioning/dags:/ria/dags -v /tmp/etl-provisioning/jobs:/ria/jobs -v /tmp/etl-provisioning/metadata:/ria/metadata $(IMAGE_BRANCH_LATEST)

