# IDOML server configuration repository

## Installation

### Requirements

#### Create ssh keys

1. Create ssh keys

    ```ssh-keygen -t ed25519 -f secrets/ssh/idoml_deploy_key```
2. Add ssh keys to github deploy key 

    ```cat secrets/ssh/idoml_deploy_key.pub```
3. Add github to known hosts

    ```ssh-keyscan -t ed25519 github.com >> secrets/ssh/known_hosts```
4. Create environment file
    - .env: airflow uid (Be sure it is in root group) and docker uid
    - .env.idoml: idoml settings

#### Define the following environment variables to .env

```
echo -e "AIRFLOW_UID=$(id -u)" > .env
echo -e "DOCKER_GROUP_ID=$(getent group docker | cut -d ':' -f 3)" >> .env
```

#### Define the following environment variables to .env.idoml

Create a .env.idoml file and add the following content and fill the missing values

```
# MINIO Settings
MINIO_ROOT_USER=
MINIO_ROOT_PASSWORD=

# POSTGRES Settings
POSTGRES_PASSWORD=

# Airflow Settings
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN='postgresql+psycopg2://airflow:${POSTGRES_PASSWORD}@postgres/airflow'
AIRFLOW__CORE__SQL_ALCHEMY_CONN='postgresql+psycopg2://airflow:${POSTGRES_PASSWORD}@postgres/airflow'
AIRFLOW__CELERY__RESULT_BACKEND='db+postgresql://airflow:${POSTGRES_PASSWORD}@postgres/airflow'
AIRFLOW__CORE__FERNET_KEY=''
AIRFLOW__LOGGING__REMOTE_LOGGING='true'
AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER='s3://airflow-logs'
AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID='idoml_minio_conn'
AIRFLOW__LOGGING__ENCRYPT_S3_LOGS='false'


# Airflow Admin User
_AIRFLOW_WWW_USER_USERNAME=
_AIRFLOW_WWW_USER_PASSWORD=
```

