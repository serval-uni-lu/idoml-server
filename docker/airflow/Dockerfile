FROM apache/airflow:2.6.1

USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         gosu git gcc\
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 
  
RUN groupadd docker \
  && newgrp docker 

USER airflow
