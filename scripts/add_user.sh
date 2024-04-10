#!/bin/bash
while getopts 'fle:v' flag; do
    case "${flag}" in
        f) firstname=${OPTARG};;
        l) lastname=${OPTARG};;
        e) email=${OPTARG};;
        v) verbose='true' ;;
        *) print_usage
            exit 1 ;;
    esac
done

echo "Please specify User First name: "
read FISRTNAME

echo "Please specify User Last name: "
read LASTNAME

echo "Please specify User email address: "
read EMAIL


[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

# Keycloak Admin Credentials
KEYCLOAK_URL="http://keycloak.$IDOML_DOMAIN"
REALM="idoml"
ADMIN_USERNAME=$IDOML_KEYCLOAK_ADMIN
ADMIN_PASSWORD=$IDOML_KEYCLOAK_ADMIN_PASSWORD
# MinIO Admin Credentials
MINIO_ENDPOINT="http://minio.$IDOML_DOMAIN"
MINIO_ACCESS_KEY=$IDOML_MINIO_ROOT_USER
MINIO_SECRET_KEY=$IDOML_MINIO_ROOT_PASSWORD

# # User details
USERNAME=${FISRTNAME:0:1}${LASTNAME}
PASSWORD=$USERNAME
ADMIN_GROUPS='["admin","airflow_admin","jupyterhub_admin","minio_admin"]'
USER_GROUPS='["airflow_user","jupyterhub_admin","minio_admin"]'

# Step 1: Authenticate with Keycloak and get admin token
echo "Step 1: Authenticating with Keycloak..."
TOKEN_RESPONSE=$(curl -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$ADMIN_USERNAME" \
    -d "password=$ADMIN_PASSWORD" \
    -d "grant_type=password" \
    -d "client_id=admin-cli")

# Extract access token from response
ADMIN_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')

# Step 2: Create a new user in Keycloak realm
echo "Step 2: Creating a new user ($USERNAME) in Keycloak..."
CREATE_USER_RESPONSE=$(curl -X POST "$KEYCLOAK_URL/admin/realms/$REALM/users" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"username":"'"$USERNAME"'","enabled":true,"email":"'"$EMAIL"'","lastName":'"$LASTNAME"',"firstName":'"$FIRSTNAME"',"groups":'"$ADMIN_GROUPS"',"attributes":{"AWS_ACCESS_KEY_ID":"default","AWS_SECRET_ACCESS_KEY":"default"},"credentials":[{"type":"password","value":"'"$PASSWORD"'","temporary":false}]}')

echo CREATE_USER_RESPONSE $CREATE_USER_RESPONSE






# # Generate access and secret keys for the user
# docker run --rm 

# echo KEYS $KEYS