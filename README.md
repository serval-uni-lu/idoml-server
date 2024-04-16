<!-- Badges -->
<p align="center">
<img src="https://img.shields.io/github/stars/serval-uni-lu/idoml-server?label=%E2%AD%90%20Stars&style=flat-square?branch=master&kill_cache=1">
</p>

# IDOML server configuration repository
Welcome to IDOML server repo!

In this repository you will find the configuration files to deploy the IDOML server. The IDOML server is a docker-compose based deployment of the following services:
- Airflow
  - Git-sync
- Minio
- Keycloak
- Traefik


## Requirements
1. Hardware Requirements:

    - A Linux server with a minimum of 8GB of RAM and 4 CPU cores is required to run the platform efficiently. This configuration ensures optimal performance and scalability for your machine learning tasks.

    - Note that the above requirement is exclusive of resources needed for hosting a JupyterHub server and executing machine learning tasks. The resources for JupyterHub server hosting vary based on the number of users and the size of data they handle. Similarly, resources for machine learning tasks depend on task complexity and data size. Scaling up for ML tasks can be achieved by hosting additional servers to manage [airflow workers](https://github.com/serval-uni-lu/idoml-worker-node).

2. To deploy the IDOML server, ensure your system meets the following requirements:

    - [Docker](https://docs.docker.com/get-docker/): IDOML utilizes Docker for deployment. Refer to the official Docker documentation for installation instructions.

    - [Docker-compose](https://docs.docker.com/compose/install/): Docker-compose is required for orchestrating the deployment process. Follow the installation instructions provided in the official Docker-compose documentation.

3. Before deploying IDOML, update the **.env** file with the necessary configurations:
    - Domain name Configuration:

        We expect that the user dispose a custom domain name. Please redirect all the subdomains to the server's IP address.
        Then update the **.env** file with the variable IDOML_DOMAIN. This domain will be used to access the services deployed on the server.

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

> [!Note]
> If you do not have a custom domain name, you can use the default domain name which is a subdomain of localhost. It should be able accessed from the server itself.

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


## Deployment

Once the requirements are met, the IDOML server can be deployed using the magic command:

```
docker-compose up -d
```

## Try it out
The platform is now accessible via the domain name you have set up. The IDOML dashboard can be accessed at the following URL:

    http://dashboard.{IDOML_DOMAIN}

Where {IDOML_DOMAIN} is the domain name you have set up previously in the **.env** file.


## Adding an idoml platform user to Keycloak

Execute the following command:
```
bash scripts/add_user.sh
```
then follow the instructions (give first name / last name / emails). This will automatically create a user in Keycloak and assign the necessary roles to access the IDOML platform. User's login will be created using the first letter of their name, and last name. And the password will be the same as the login.



--------------------------------------------
## IDOML-related Server

### Jupyterhub server
After deploying the IDOML server, the subsequent step involves configuring the JupyterHub server. JupyterHub is a multi-user server that grants users access to Jupyter notebooks. This server comes pre-configured with extensions and libraries to streamline machine learning tasks and pipeline deployment into the Airflow server.

To set up the JupyterHub server, refer to the instructions provided in the  [idoml jupyterhub repository](https://github.com/serval-uni-lu/idoml-jupyterhub).


### Airflow worker node

The Airflow worker node functions as a server dedicated to executing tasks outlined in the Airflow Directed Acyclic Graphs (DAGs). This node's primary responsibility involves executing machine learning tasks and deploying pipelines.

In the IDOML server, there is already a default worker provided. However, it's recommended to scale up the number of workers based on the number of tasks to be executed. This ensures efficient task execution and improves overall system performance.

To configure the Airflow worker node, please consult the instructions available in the [idoml worker node repository](https://github.com/serval-uni-lu/idoml-worker-node).

<!-- 
## Configuration after deployment

### MINIO

    
#### Generate credentials for airflow
    
```
docker-compose exec minio sh -c "mc admin user add minio airflow ${MINIO_ROOT_PASSWORD} readwrite
```
 -->
