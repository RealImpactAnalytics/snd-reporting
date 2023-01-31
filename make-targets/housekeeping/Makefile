#################################################################
## SECTION: Housekeeing tasks
#################################################################

DELETE_FILES_OLDER_THAN = 7

airflow_worker_compose_container = $(shell docker ps --filter=name=airflow-worker --format='{{.Names}}')
airflow_scheduler_compose_container = $(shell docker ps --filter=name=airflow-scheduler --format='{{.Names}}')

airflow_worker_swarm_container = $(shell docker service ps --filter=desired-state=running --format='{{.Name}}.{{.ID}}' -q deploy_airflow-worker)
airflow_scheduler_swarm_container = $(shell docker service ps --filter=desired-state=running --format='{{.Name}}.{{.ID}}' -q deploy_airflow-scheduler)

compose-cleanup-airflow-logs: ## In compose mode. Cleanup airflow scheduler and worker logs + spark tmp folder in the airflow-worker
	docker exec $(airflow_worker_compose_container) find /logs -type f -mtime +$(DELETE_FILES_OLDER_THAN) -exec rm {} +
	docker exec $(airflow_worker_compose_container) find /tmp -mtime +$(DELETE_FILES_OLDER_THAN) -type f -exec rm -r {} +
	docker exec $(airflow_scheduler_compose_container) find /logs -type f -mtime +$(DELETE_FILES_OLDER_THAN) -exec rm {} +

swarm-cleanup-airflow-logs: ## In swarm mode. Cleanup airflow scheduler and worker logs + spark tmp folder in the airflow-worker
	docker exec $(airflow_worker_swarm_container) find /logs -type f -mtime +$(DELETE_FILES_OLDER_THAN) -exec rm {} + || true
	docker exec $(airflow_worker_swarm_container) find /tmp -mtime +$(DELETE_FILES_OLDER_THAN) -type f -exec rm -r {} + || true
	docker exec $(airflow_scheduler_swarm_container) find /logs -type f -mtime +$(DELETE_FILES_OLDER_THAN) -exec rm {} + || true
