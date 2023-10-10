#!/bin/bash
set -o pipefail

DEFAULT_INSTANCE_CONFIG_FILE_PATH="./instance/nginx.conf"
DEFAULT_MIME_TYPES_FILE_PATH="./instance/mime.types"

print_help() {
  echo "Script to publish a config to instance managed by NIM."
  printf "\n"
  echo "Usage: $0 CTRL_IP AUTH_TOKEN SYSTEM_UID NGINX_UID"
  echo "param CTRL_IP: NIM Public IP"
  echo "param AUTH_TOKEN: Base-64 encoded auth token"
  echo "param SYSTEM_UID: UUID of system managed by NIM"
  echo "param NGINX_UID: UUID of NGINX instance on the system"
}

######
# Create payload for instances
######

publish_config_to_instance() {
    local ctrl_ip=$1
    local auth_token=$2
    local system_uid=$3
    local nginx_uid=$4

    if [ -z "${ctrl_ip}" ]; then
      echo " * variable CTRL_IP not set"
      exit 1
    fi

    if [ -z "${auth_token}" ]; then
      echo " * variable AUTH_TOKEN not set"
      exit 1
    fi

    if [ -z "${system_uid}" ]; then
      echo " * variable SYSTEM_UID not set"
      exit 1
    fi

    if [ -z "${nginx_uid}" ]; then
      echo " * variable NGINX_UID not set"
      exit 1
    fi

    if [ ! -f "${DEFAULT_INSTANCE_CONFIG_FILE_PATH}" ]; then
        echo "${DEFAULT_INSTANCE_CONFIG_FILE_PATH} file doesn't exist."
        exit 1
    fi

    if [ ! -f "${DEFAULT_MIME_TYPES_FILE_PATH}" ]; then
        echo "${DEFAULT_MIME_TYPES_FILE_PATH} file doesn't exist."
        exit 1
    fi

    if [ -z "${CI_COMMIT_SHA}" ]; then
      echo " * GIT environment variable CI_COMMIT_SHA not set"
      exit 1
    fi

    local ic_base64
    local mime_base64
    local update_time
    local version_hash="${CI_COMMIT_SHA}"
    local payload

    ic_base64=$(base64 < "${DEFAULT_INSTANCE_CONFIG_FILE_PATH}" | tr -d '\n')
    mime_base64=$(base64 < "${DEFAULT_MIME_TYPES_FILE_PATH}" | tr -d '\n')
    update_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    payload=$(jq -n \
              --arg versionHash "${version_hash}" \
              --arg updateTime "${update_time}" \
              --arg config "${ic_base64}" \
              --arg mime "${mime_base64}" \
              '{
                  "auxFiles": {
                  "files": [],
                  "rootDir": "/"
                  },
                  "configFiles": {
                  "rootDir": "/etc/nginx",
                  "files": [
                      {
                      "contents": $config,
                      "name": "/etc/nginx/nginx.conf"
                      },
                      {
                      "contents": $mime,
                      "name": "/etc/nginx/mime.types"
                      }
                  ]
                  },
                  "updateTime": $updateTime,
                  "externalId": $versionHash,
                  "externalIdType": "git"
              }'
              )

    echo $payload
    echo "################### Publish the config..."
    # want to do this in the pipeline after updating externalId and type
    echo -e "${payload}" | curl -k \
      -H 'Content-Type: application/json' \
      -H "authorization: Basic $auth_token" \
      --data-binary @- -X POST "https://$ctrl_ip/api/platform/v1/systems/$system_uid/instances/$nginx_uid/config"
}

#MAIN

if [[ $# -lt 4 ]]; then
    print_help
    exit 1
fi

publish_config_to_instance "$@"