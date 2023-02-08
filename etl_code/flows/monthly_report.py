from flows.conf.initialization import job_config
from mjolnir_python.configuration.prefect_configuration import (
    get_prefect_flow_config,
    get_prefect_flow_task_config,
)
from mjolnir_python.operators.spark_consul_task import SparkConsulTask
from mjolnir_python.prefect_utils.parameters import observation_date_parameter
from prefect import Flow

FLOW_NAME = "monthly_report"

COLLECT_PERFORMANCE_TASK_NAME = "collect_metrics"
collect_metrics = SparkConsulTask(
    name=COLLECT_PERFORMANCE_TASK_NAME,
    transformation_import_path="jobs.monthly_report.collect_metrics.CLASSNAME",
    job_config_defaults=job_config,
    **get_prefect_flow_task_config(FLOW_NAME, COLLECT_PERFORMANCE_TASK_NAME),
)


SERVE_TO_MONGO_TASK = "serve_to_mongo"
serve_to_mongo = SparkConsulTask(
    name=SERVE_TO_MONGO_TASK,
    transformation_import_path="jobs.monthly_report.serve_to_mongo.CLASSNAME",
    job_config_defaults=job_config,
    **get_prefect_flow_task_config(FLOW_NAME, SERVE_TO_MONGO_TASK),
)

# define a register flow function
def register_flow(flow_register_kwargs):

    with Flow(FLOW_NAME,**get_prefect_flow_config(FLOW_NAME)) as flow:
        # this is where you'll set up dependencies between your tasks
        collect_metrics_task = collect_metrics(observation_date_parameter)
        serve_to_mongo_task = serve_to_mongo(observation_date_parameter)
        serve_to_mongo_task.set_upstream(collect_metrics_task)
        collect_metrics.set_upstream(serve_to_mongo)

    # Register your flow (unless you know what you are doing, always keep it like this)
    flow.register(**flow_register_kwargs)