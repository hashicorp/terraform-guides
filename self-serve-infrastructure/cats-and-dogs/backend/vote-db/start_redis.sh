#!/bin/bash
# Authenticate against Vault
login_result=$(curl --request POST --data '{"role": "demo", "jwt": "'"${K8S_TOKEN}"'"}' ${VAULT_ADDR}/v1/auth/${VAULT_K8S_BACKEND}login)

# Read cats-and-dogs secret from Vault
vault_token=$(echo $login_result | python3 -c "import sys, json; print(json.load(sys.stdin)['auth']['client_token'])")

cats_and_dogs=$(curl -H "X-Vault-Token:$vault_token" ${VAULT_ADDR}/v1/secret/${VAULT_USER}/kubernetes/cats-and-dogs)

redis_pwd=$(echo $cats_and_dogs | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['redis_pwd'])")
echo "redis_pwd is: $redis_pwd"
redis-server --requirepass $redis_pwd
