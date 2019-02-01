# Deprovision cluster using ID saved in the home directory
az resource delete --ids $(jq -r ".properties.outputResources[0].id" ~/spark_cluster_id.txt )
# TODO: ADD GROOVY DEPROVISIONING STEPS FOR HEAD NODES SAVED IN PUBISH OVER SSH CONFIG
#name=${VIRTUAL_MACHINE_NAME}
#sed -i "s/def name = \"\"/def name = \"${VIRTUAL_MACHINE_NAME}\"/g" remove_server_from_config.groovy
