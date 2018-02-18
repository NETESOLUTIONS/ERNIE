#!/usr/bin/env bash

# Set your Azure VM diagnostic parameters correctly below
RESOURCE_GROUP=ERNIE
LINUX_VM=$(hostname)
DIAGNOSTIC_STORAGE_ACCOUNT=erniediag759
AZURE_SUBSCRIPTION_ID=efbef82a-58a0-4853-bad2-3bdc1236ec8f

if (($# < 1)); then
  cat << END
SYNOPSIS
  $0 diagnostic_storage_account_sas_token

DESCRIPTION
  Sets up an Azure Linux Diagnostic Extension 3.0 on this machine for:
  * Resource Group=${RESOURCE_GROUP}
  * Diagnostic Storage Account=${DIAGNOSTIC_STORAGE_ACCOUNT}
  * Azure Subscription=${AZURE_SUBSCRIPTION_ID}

  diagnostic_storage_account_sastoken must have a valid future expiry date.

  Requires Azure login for the target subscription.
  Uses ./portal_public_settings.json or downloads sample settings if the file does not exist.
END
  exit 1
fi

set -xe
set -o pipefail

# Should login to Azure first before anything else
az login

# Select the subscription containing the storage account
az account set --subscription ${AZURE_SUBSCRIPTION_ID}

# Download the sample Public settings. (You could also use curl or any web browser)
SETTINGS=portal_public_settings.json
if [[ ! -f ${SETTINGS} ]]; then
  LATEST_SAMPLE_SETTINGS=https://raw.githubusercontent.com/Azure/azure-linux-extensions/master/\
Diagnostic/tests/lad_2_3_compatible_portal_pub_settings.json
  wget ${LATEST_SAMPLE_SETTINGS} -O ${SETTINGS}
fi

# Build the VM resource ID. Replace storage account name and resource ID in the public settings.
vm_resource_id=$(az vm show -g $RESOURCE_GROUP -n $LINUX_VM --query "id" -o tsv)
sed -i "s#__DIAGNOSTIC_STORAGE_ACCOUNT__#$DIAGNOSTIC_STORAGE_ACCOUNT#g" ${SETTINGS}
sed -i "s#__VM_RESOURCE_ID__#$vm_resource_id#g" ${SETTINGS}

# Build the protected settings using the storage account SAS token
diagnostic_storage_account_sas_token=$1
lad_protected_settings="{'storageAccountName': '$DIAGNOSTIC_STORAGE_ACCOUNT', \
'storageAccountSasToken': '$diagnostic_storage_account_sas_token'}"

# Finally, tell Azure to install and enable the extension
az vm extension set --publisher Microsoft.Azure.Diagnostics --name LinuxDiagnostic --version 3.0 \
 --resource-group ${RESOURCE_GROUP} --vm-name ${LINUX_VM} \
 --protected-settings "${lad_protected_settings}" --settings ${SETTINGS}