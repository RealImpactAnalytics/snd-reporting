#!/bin/sh

query_condition="state = 'failed' and start_date > current_date - interval '7' day"
airflow_db_name=$(docker ps --filter=name=airflow-db --format='{{.Names}}')
airflow_worker_name=$(docker ps --filter=name=airflow-worker --format='{{.Names}}')
#check which dags have been running in the past 7 days but failed
for dag_id in $(sudo docker exec -i $(airflow_db_name) psql -U postgres -d airflow  -c  "select distinct dag_id from dag_run where '${query_condition}';" --tuples-only)
do
	#for every failed dag we look for the min execution date within the last 7 days
	exec_date=$(sudo docker exec -i $(airflow_db_name) psql -U postgres -d airflow  -c  "select to_char(min(execution_date), 'YYYY-MM-DD') from dag_run where dag_id = '${dag_id}' and '${query_condition}';"  --tuples-only)

	echo $exec_date $dag_id

	#clear failed dag with min execution date that will clear all failed dags starting from this execution date
	sudo docker exec -i $(airflow_worker_name) airflow clear $dag_id -c -f -s $exec_date

done;
