FROM apache/airflow:2.6.1

USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         gosu git gcc\
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 
  
ARG DOCKER_GROUP_ID

RUN groupadd --gid ${DOCKER_GROUP_ID} docker \
  && newgrp docker 

USER airflow
