# IDOML server configuration repository

## Installation

### Requirements

#### Aiflow dag tracking repository
We use a git repository to track our dags. This repository is mounted in the airflow container. Please create an enpty git repository 

#### Create ssh deploy keys

1. Create ssh keys

    ```ssh-keygen -t ed25519 -f secrets/ssh/idoml_deploy_key```
2. Add ssh keys to github deploy key 

    ```cat secrets/ssh/idoml_deploy_key.pub```
3. Add github to known hosts

    ```ssh-keyscan -t ed25519 github.com >> secrets/ssh/known_hosts```

#### Set up synchronization with git repository
1. Add generated public key to git repository deploy keys

2. Add git repository url and branch to the docker-compose file (git-sync service). Please use the ssh url of the git repository.

    ```
    git-sync:
        image: registry.k8s.io/git-sync/git-sync:v3.6.3
        user: root
        environment:
        GIT_SYNC_REPO: "git@github.com:{account}/{repo}.git"
        GIT_SYNC_BRANCH: "dev"
    ```

### Create environment file
    - .env: airflow uid (Be sure it is in root group) and docker uid
    - .env.idoml: idoml settings



#### Define the following environment variables to .env

```
echo -e "AIRFLOW_UID=$(id -u)" > .env
echo -e "DOCKER_GROUP_ID=$(getent group docker | cut -d ':' -f 3)" >> .env
```

#### Define the following environment variables to .env.idoml

Open the .env.idoml file and add the following content and fill the missing values

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

## Start the server

Execute the following command to start the server

    ```docker-compose up -d```

## Configuration after deployment

### MINIO

#### Create minio bucket for airflow logs
    
    ```docker-compose exec minio sh -c "mc mb minio/airflow-logs"```
    
#### Generate credentials for airflow
    
    ```docker-compose exec minio sh -c "mc admin user add minio airflow ${MINIO_ROOT_PASSWORD} readwrite"```

### Airflow
Once deployed, you can access the airflow webserver and login with the credentials you defined in the .env.idoml file.  

#### Airflow logs
Airflow logs are stored in the minio bucket defined in the .env.idoml file. Add a connection to the airflow webserver with the following settings:
- Conn Id: idoml_minio_conn
- Conn Type: Amazon Web Services
- AWS Access Key ID: create from MINIO
- AWS Secret Access Key: create from MINIO
- extra: 
    ```
        {
        "endpoint_url": "MINIO endpoint url",
        }
    ```
