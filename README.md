# IDOML server configuration repository

## Installation

### Requirements

#### Define the following environment variables

```
echo -e "AIRFLOW_UID=$(id -u)" > .env
echo -e "DOCKER_GROUP_ID=$(getent group docker | cut -d ':' -f 3)" >> .env
```