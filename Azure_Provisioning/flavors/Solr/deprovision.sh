# Deprovision cluster using ID saved in the home directory
solr_dir=~/solr_*
az resource delete --ids $(jq -r ".properties.outputResources[0].id" ${solr_dir}/deployment.json)
rm -rf ${solr_dir}
name=${VIRTUAL_MACHINE_NAME}
sed -i "s/def name = \"\"/def name = \"${VIRTUAL_MACHINE_NAME}\"/g" remove_server_from_config.groovy
