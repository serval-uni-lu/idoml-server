# IDOML server configuration repository
Welcome to IDOML server repo!

In this repository you will find the configuration files to deploy the IDOML server. The IDOML server is a docker-compose based deployment of the following services:
- Airflow
  - Git-sync
- Minio
- Keycloak
- Traefik


## Requirements
1. A linux server with at least 16GB of RAM and 4 CPU cores.

2. To deploy the IDOML server, ensure your system meets the following requirements:

    - [Docker](https://docs.docker.com/get-docker/): IDOML utilizes Docker for deployment. Refer to the official Docker documentation for installation instructions.

    - [Docker-compose](https://docs.docker.com/compose/install/): Docker-compose is required for orchestrating the deployment process. Follow the installation instructions provided in the official Docker-compose documentation.

3. Before deploying IDOML, update the **.env** file with the necessary configurations:
    - Domain name Configuration:

        We expect that the user dispose a custom domain name. Please redirect all the subdomains to the server's IP address.
        Then update the **.env** file with the variable IDOML_DOMAIN. This domain will be used to access the services deployed on the server.

        > [!Note]
        > If you do not have a custom domain name, you can use the default domain name which is a subdomain of localhost. It should be able accessed from the server itself.

    -   Credentials setup:

        Please update the credential settings section of the **.env** file.

    -   User ID Configuration:

        To ensure proper permissions, the current user ID needs to be passed to the Docker-compose file for Airflow. According to the Airflow official [documentation](https://airflow.apache.org/docs/docker-stack/entrypoint.html), the user should be in the root group to access the required folders.
        
        Run the following command to update the .env file:

        ```
        echo -e "AIRFLOW_UID=$(id -u)" >> .env
        ```

    - Docker Group ID Configuration:

        The Docker group ID must be passed to the Docker-compose file for Airflow to enable the Docker operator.
        
        Run the following command to update the **.env** file:
    
        ```
        echo -e "DOCKER_GROUP_ID=$(getent group docker | cut -d ':' -f 3)" >> .env
        ```

4. Establish a Git repository to monitor the Airflow DAGs. Kindly initiate an empty Git repository.

    - If you opt for a public repository, please update the **.env** file with the repository URL and branch name.
        
        ```
        GIT_SYNC_REPO=https://github.com/{account}/{repo}.git
        GIT_SYNC_BRANCH=main
        ```

    -   However, if a private repository is preferred, please use a SSH connection for the repository. For instance:
        ```
        GIT_SYNC_REPO=git@github.com:{account}/{repo}.git
        ```

        As we are using SSH for the private repository, we need to create an SSH key pair and add the public key to the repository's deploy keys. Additionally, the repository must be added to the known hosts. This can be achieved by following the steps below:
        - Create an SSH key pair:
    
            ```
            ssh-keygen -t ed25519 -f secrets/ssh/idoml_deploy_key
            ```

        - Add the SSH key to the repository's deploy keys:

            ```
            cat secrets/ssh/idoml_deploy_key.pub
            ```

        - Add the repository to the known hosts:

            ```
            ssh-keyscan -t ed25519 github.com >> secrets/ssh/known_hosts
            ```

        Finally, uncomment the **docker-compose.yml** file the following environment variables from the git-sync service:

        ```
        # GIT_SYNC_SSH: true
        # GIT_SSH_KEY_FILE: "/etc/git-secret/idoml_deploy_key"
        ```


## Installation

Once the requirements are met, the IDOML server can be deployed using the magic command:

```
docker-compose up -d
```

## Post deployment configuration
We will now configure the airflow connections to access the minio bucket for logs. 

```
source .env
source .env.idoml
JSON_FMT='{"endpoint_url":"%s"}\n'
JSON_STRING=$(printf "$JSON_FMT" "http://minio.${IDOML_DOMAIN}")
docker compose run --rm airflow-cli connections add 'idoml_minio_conn' --conn-type 'aws' --conn-login "${MINIO_ROOT_USER}" --conn-password "${MINIO_ROOT_PASSWORD}" --conn-extra "${JSON_STRING}"
```







## Configuration after deployment

### MINIO

#### Create minio bucket for airflow logs
    
    ```docker-compose exec minio sh -c "mc mb minio/airflow-logs```
    
#### Generate credentials for airflow
    
```
docker-compose exec minio sh -c "mc admin user add minio airflow ${MINIO_ROOT_PASSWORD} readwrite
```

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


docker compose run --rm airflow-cli connections add 'idoml_minio_conn' --conn-type 'aws' --conn-login 'idoml-minio' --conn-password 'idoml-minio' --conn-extra '{"endpoint_url": "http://minio.idoml.precision.uni.lux"}'


source .env
source .env.idoml
JSON_FMT='{"endpoint_url":"%s"}\n'
JSON_STRING=$(printf "$JSON_FMT" "http://minio.${IDOML_DOMAIN}")
docker compose run --rm airflow-cli connections add 'idoml_minio_conn' --conn-type 'aws' --conn-login "${MINIO_ROOT_USER}" --conn-password "${MINIO_ROOT_PASSWORD}" --conn-extra "${JSON_STRING}"

docker compose run --rm airflow-cli connections add 'idoml_minio_conn' --conn-type 'aws' --conn-login "${MINIO_ROOT_USER}" --conn-password "${MINIO_ROOT_PASSWORD}" --conn-extra '{"endpoint_url": "http://minio.idoml.precision.uni.lux"}'