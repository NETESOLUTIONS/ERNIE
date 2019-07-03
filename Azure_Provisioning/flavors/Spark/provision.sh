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
  A new Spark server is provisioned automatically via this script given input variables
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


# Extract the necessary values from the JSON - get the IPs for all the nodes
cluster_id=$(jq -r ".properties.outputResources[0].id" deployment.json)
echo $cluster_id > ~/spark_cluster_id.txt # Save this for later deprovisioning
az resource show --ids $cluster_id > cluster.json
nodes_subnet=$(jq -r ".properties.computeProfile.roles[0].virtualNetworkProfile.subnet" cluster.json)
az resource show --ids $nodes_subnet > nodes.json
>ips.txt
while read node ; do
   ntype=$( echo $node | grep -q "headnode" && echo "headnode" || echo "other")
   ip=$(az resource show --ids $node | jq -r ".properties.privateIPAddress")
   echo "${ip}|${ntype}" >> ips.txt
done < <(jq -r ".properties.ipConfigurations[].id" nodes.json)

#TODO: INCORPORATE AUTOMATED ADDITION TO JENKINS PUBLISH OVER SSH WITH GROOVY

echo "*** THE FOLLOWING NODES HAVE BEEN CREATED AND ARE NOW ACCESSIBLE WITHIN THE PRIVATE IP RANGE ***"
cat ips.txt
