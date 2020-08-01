#!/bin/bash

#** Usage notes are incorporated into online help (-h). The format mimics a manual page.
if [[ $1 == "-h" ]]; then
  cat << 'HEREDOC'
NAME

  deprovision.sh -- Automated de-provisioning of a Spark server

SYNOPSIS

  deprovision.sh -h: display this help

DESCRIPTION

  A new Spark server is provisioned automatically via this script given input variables
		and some accompanying parameter files in JSON format.

ENVIRONMENT
  AZURE_SERVICE_PRINCIPAL_APP_ID
  AZURE_SERVICE_PRINCIPAL_PASSWORD
  AZURE_TENANT_ID
HEREDOC
  exit 1
fi

# Bash 4.3+ is required in order to use nameref-s. We're not quite there yet.
#declare -n env_var
for env_var in AZURE_SERVICE_PRINCIPAL_APP_ID AZURE_SERVICE_PRINCIPAL_PASSWORD AZURE_TENANT_ID; do
  if [[ ! ${!env_var} ]]; then
    echo "Please, define ${env_var}"
    exit 1
  fi
done

az login --service-principal --username "$AZURE_SERVICE_PRINCIPAL_APP_ID" \
  --password "$AZURE_SERVICE_PRINCIPAL_PASSWORD" --tenant "$AZURE_TENANT_ID"

# Deprovision cluster using ID saved in the home directory
az resource delete --ids $(cat ~/spark_cluster_id.txt)
# TODO: ADD GROOVY DEPROVISIONING STEPS FOR HEAD NODES SAVED IN PUBISH OVER SSH CONFIG
#name=${VIRTUAL_MACHINE_NAME}
#sed -i "s/def name = \"\"/def name = \"${VIRTUAL_MACHINE_NAME}\"/g" remove_server_from_config.groovy
