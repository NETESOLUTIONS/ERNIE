#!/bin/bash
#** Usage notes are incorporated into online help (-h). The format mimics a manual page.
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME
  provision.sh -- Automated provisioning of a Solr server

SYNOPSIS
  Usage:
  provision.sh -h: display this help

DESCRIPTION
  A new Solr server is provisioned automatically via this script given input variables
		and some accompanying parameter files in JSON format.

NOTE
  Success of this job is dependent upon pre-established Azure privileges and a saved connection via cli

ENVIRONMENT
  ADMIN_USERNAME
  ADMIN_PASSWD
  HEAD_NODE_VIRTUAL_MACHINE_SIZE
  WORKER_NODE_VIRTUAL_MACHINE_SIZE
  WORKER_NODE_COUNT
  HEAD_NODE_COUNT
  CLUSTER_NAME
  RESOURCE_GROUP_NAME
  RESOURCE_GROUP_LOCATION
  AZURE_SUBSCRIPTION_ID
HEREDOC
  exit 1
fi

#** Failing the script on the first error (-e + -o pipefail)
#** Echoing lines (-x)
set -x
set -e
set -o pipefail

# TemplateFile Path - template file to be used
templateFilePath="template.json"
if [ ! -f "$templateFilePath" ]; then
	echo "$templateFilePath not found"
	exit 1
fi
# Parameter file path
parametersFilePath="parameters.json"
if [ ! -f "$parametersFilePath" ]; then
	echo "$parametersFilePath not found"
	exit 1
fi

# Add the cluster specific parameters to the parameters JSON file using jq and successive pipes
cat parameters.json > temp.json
cat temp.json | jq ".parameters.clusterLoginPassword.value =\"${ADMIN_PASSWD}\""\
 | jq ".parameters.sshPassword.value =\"${ADMIN_PASSWD}\""\
 | jq ".parameters.sshUserName.value =\"${ADMIN_USERNAME}\""\
 | jq ".parameters.clusterName.value =\"${CLUSTER_NAME}\""\
 | jq ".parameters.location.value =\"${RESOURCE_GROUP_LOCATION}\""\
 | jq ".parameters.clusterHeadNodeSize.value =\"${HEAD_NODE_VIRTUAL_MACHINE_SIZE}\""\
 | jq ".parameters.clusterWorkerNodeSize.value =\"${WORKER_NODE_VIRTUAL_MACHINE_SIZE}\""\
 | jq ".parameters.clusterWorkerNodeCount.value = ${WORKER_NODE_COUNT}"\
 | jq ".parameters.clusterHeadNodeCount.value = ${HEAD_NODE_COUNT}"  > parameters.json

echo "***THE FOLLOWING PARAMETERS ARE SET***"
cat parameters.json
echo "**************************************"

# Login to azure using saved credentials
az account show 1> /dev/null
if [ $? != 0 ];
then
	az login
fi
# Set the default subscription id
az account set --subscription "${AZURE_SUBSCRIPTION_ID}"
set +e

#Start deployment
echo "Starting deployment..."
(
	set -x
	az group deployment create --name "${CLUSTER_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --template-file "${templateFilePath}" --parameters "@${parametersFilePath}" > deployment.json
)
if [ $?  == 0 ];
 then
	echo "Template has been successfully deployed"
fi

cat deployment.json


#server_id=$(jq -r ".properties.outputResources[0].id" deployment.json)

# Collect Private IP address for provisioned server (head node address), swap keys
#private_ip=$(jq -r ".properties.outputs.privateIPAddress.value" deployment.json)
#sed -i "/^${private_ip}.*$/d" ~/.ssh/known_hosts
#sshpass -p "${ADMIN_PASSWD}" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no ${ADMIN_USERNAME}@${private_ip}
#PRIVATE=~/.ssh/id_rsa

# Add the information for the server to PublishOverSSH configuration
#sed -i "s/def name = \"\"/def name = \"${VIRTUAL_MACHINE_NAME}\"/g" add_server_to_config.groovy
#sed -i "s/def username = \"\"/def username = \"${ADMIN_USERNAME}\"/g" add_server_to_config.groovy
#sed -i "s/def hostname = \"\"/def hostname = \"${private_ip}\"/g" add_server_to_config.groovy
#sed -i "s|def keyPath = \"\"|def keyPath = \"${PRIVATE}\"|g" add_server_to_config.groovy

# Save miscellaneous information to file for a later deprovision job
#solr_directory=~/solr_$(date +%Y%m%d_%H%M)UTC
#mkdir $solr_directory
#chmod 700 $solr_directory
#cp deployment.json $solr_directory/deployment.json
