# syntax = docker/dockerfile:experimental
FROM riaktr/python-packager:snd-3.10.0 as etl-deps

# Optionnaly add a requirements.txt to install more dependencies
# COPY --chown=ria:ria requirements.txt /ria/packager/custom-etl/requirements.txt
# RUN python lib-packager.py -r custom-etl/requirements.txt

COPY --chown=ria:ria etl_code /ria/packager/custom-etl/etl_code
RUN python src-packager.py -s custom-etl/etl_code

FROM riaktr/etl-provisioning:snd-3.10.0
ENV FLOWS_NAMESPACE="custom-flows"

COPY --chown=ria:ria --from=etl-deps /ria/packager/job_deps /ria/jobs/reporting

# Prefect flows
COPY --chown=ria:ria etl_code/flows /ria/flows
COPY --chown=ria:ria etl_code/metadata /ria/metadata
