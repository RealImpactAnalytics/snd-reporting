#################################################################
## SECTION: ETL provisioning
#################################################################

git_short_hash = $(shell git rev-parse --short HEAD)
git_branch = $(shell git rev-parse --symbolic-full-name --abbrev-ref HEAD | tr -s "/" "_" | tr -s ":" "_")
CURRENT_WORKDIR = $(if $(LOCAL_WORKSPACE_FOLDER),$(LOCAL_WORKSPACE_FOLDER),$(PWD))

IMAGE_REPO = riaktr/$(GROUP_CODE)-$(COUNTRY_CODE)-provisioning
IMAGE_WITH_COMMIT_TAG = $(IMAGE_REPO):$(git_short_hash)
IMAGE_BRANCH_LATEST = $(IMAGE_REPO):$(git_branch)

build-etl: ## Build etl-provisioning image
	@echo "Building etl provisioning image"
	DOCKER_BUILDKIT=1 docker build -f provisioning/Dockerfile --platform linux/amd64 -t $(IMAGE_WITH_COMMIT_TAG) --progress=plain .

provisioning_envs = -e MINIO_ACCESS_KEY_ID=admin -e MINIO_SECRET_ACCESS_KEY=snd@ria123
provision-etl-locally: build-etl ## Build and runs the provisioning on the local minio instance
	docker run -it --rm --network ria $(provisioning_envs) $(IMAGE_WITH_COMMIT_TAG)

provision-etl-dev-server: build-etl ## Build and runs the provisioning for deploying on the dev server
	rm -rf tmp
	docker run --rm --entrypoint cp -v ${CURRENT_WORKDIR}/tmp:/ria/tmp $(IMAGE_WITH_COMMIT_TAG) -R /ria/{dags,jobs,metadata,flows} /ria/tmp
	rsync -azv --delete --progress --stats tmp/ $(GROUP_CODE)-$(COUNTRY_CODE)-dev:/tmp/etl-provisioning
	ssh $(GROUP_CODE)-$(COUNTRY_CODE)-dev docker run --net ria $(provisioning_envs) -i --rm -v /tmp/etl-provisioning/flows:/ria/flows -v /tmp/etl-provisioning/dags:/ria/dags -v /tmp/etl-provisioning/jobs:/ria/jobs -v /tmp/etl-provisioning/metadata:/ria/metadata $(IMAGE_BRANCH_LATEST)

publish-etl: build-etl ## Build and push etl-provisioning image
	@echo "Publishing image $(IMAGE_WITH_COMMIT_TAG)"
	@docker tag $(IMAGE_WITH_COMMIT_TAG) $(IMAGE_BRANCH_LATEST)
	@docker push $(IMAGE_WITH_COMMIT_TAG)
	@docker push $(IMAGE_BRANCH_LATEST)
