#!/usr/bin/env bash
# Set your Azure VM diagnostic parameters correctly below
readonly RESOURCE_GROUP=ERNIE
readonly LINUX_VM=$(hostname)
readonly DIAGNOSTIC_STORAGE_ACCOUNT=ernie0temp
readonly AZURE_SUBSCRIPTION_ID=efbef82a-58a0-4853-bad2-3bdc1236ec8f
readonly LAD_VERSION=3.0
readonly LAD_VERSION_TAG=3_0

usage() {
  cat <<HEREDOC
NAME

    setup_linux_diag_ext.sh -- set up an Azure Linux Diagnostic Extension ${LAD_VERSION} on this machine

SYNOPSIS

    setup_linux_diag_ext.sh
    setup_linux_diag_ext.sh -h: display this help

DESCRIPTION

    Sets up an Azure Linux Diagnostic Extension 3.0 on this machine for:
      * Resource Group=${RESOURCE_GROUP}
      * Diagnostic Storage Account=${DIAGNOSTIC_STORAGE_ACCOUNT}
      * Azure Subscription=${AZURE_SUBSCRIPTION_ID}

ENVIRONMENT

    Requires manual Azure login for the target subscription.

    Uses \`./portal_public_settings.json\` or downloads sample settings if the file does not exist.

AUTHOR(S)

    See https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/diagnostics-linux?toc=/azure/azure-monitor/toc.json.
    Created by Dmitriy "DK" Korobskiy, August 2020
HEREDOC
  exit 1
}

set -e
set -o pipefail

[[ $1 == "-h" ]] && usage

# Get a script directory, same as by $(dirname $0)
#readonly SCRIPT_DIR=${0%/*}
#readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)

#readonly WORK_DIR=${1:-${ABSOLUTE_SCRIPT_DIR}/build} # $1 with the default
#if [[ ! -d "${WORK_DIR}" ]]; then
#  mkdir "${WORK_DIR}"
#  chmod g+w "${WORK_DIR}"
#fi
#cd "${WORK_DIR}"
echo -e "\n## Running under ${USER}@${HOSTNAME} in ${PWD} ##\n"

# Should login to Azure first before anything else
az login

# Select the subscription containing the storage account
az account set --subscription ${AZURE_SUBSCRIPTION_ID}

# Download the sample Public settings. (You could also use curl or any web browser)
readonly SETTINGS=portal_public_settings.json
if [[ ! -f ${SETTINGS} ]]; then
  readonly LATEST_SAMPLE_SETTINGS=https://raw.githubusercontent.com/Azure/azure-linux-extensions/master/\
Diagnostic/tests/lad_${LAD_VERSION_TAG}_compatible_portal_pub_settings.json
  wget ${LATEST_SAMPLE_SETTINGS} -O ${SETTINGS}
fi

# Build the VM resource ID. Replace storage account name and resource ID in the public settings.
readonly VM_RESOURCE_ID=$(az vm show -g $RESOURCE_GROUP -n "$LINUX_VM" --query "id" -o tsv)
sed -i "s#__DIAGNOSTIC_STORAGE_ACCOUNT__#$DIAGNOSTIC_STORAGE_ACCOUNT#g" ${SETTINGS}
sed -i "s#__VM_RESOURCE_ID__#$VM_RESOURCE_ID#g" ${SETTINGS}

# Build the protected settings using the storage account SAS token
readonly DIAGNOSTIC_STORAGE_ACCOUNT_SAS_TOKEN=$(az storage account generate-sas --account-name $DIAGNOSTIC_STORAGE_ACCOUNT --expiry 2037-12-31T23:59:00Z --permissions wlacu --resource-types co --services bt -o tsv)
readonly LAD_PROTECTED_SETTINGS="{'storageAccountName': '$DIAGNOSTIC_STORAGE_ACCOUNT', \
'storageAccountSasToken': '$DIAGNOSTIC_STORAGE_ACCOUNT_SAS_TOKEN'}"

# Finally, tell Azure to install and enable the extension
az vm extension set --publisher Microsoft.Azure.Diagnostics --name LinuxDiagnostic --version ${LAD_VERSION} \
 --resource-group ${RESOURCE_GROUP} --vm-name "${LINUX_VM}" \
 --protected-settings "${LAD_PROTECTED_SETTINGS}" --settings ${SETTINGS}