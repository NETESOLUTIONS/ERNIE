#!/usr/bin/env bash
set -xe
set -o pipefail

# Set your Azure VM diagnostic parameters correctly below
resource_group=ERNIE
linux_vm=$(hostname)
diagnostic_storage_account=erniediag759
azure_subscription_id=efbef82a-58a0-4853-bad2-3bdc1236ec8f

# Should login to Azure first before anything else
az login

# Select the subscription containing the storage account
az account set --subscription ${azure_subscription_id}

# Download the sample Public settings. (You could also use curl or any web browser)
wget https://raw.githubusercontent.com/Azure/azure-linux-extensions/master/Diagnostic/tests/lad_2_3_compatible_portal_pub_settings.json -O portal_public_settings.json

# Build the VM resource ID. Replace storage account name and resource ID in the public settings.
my_vm_resource_id=$(az vm show -g $resource_group -n $linux_vm --query "id" -o tsv)
sed -i "s#__DIAGNOSTIC_STORAGE_ACCOUNT__#$diagnostic_storage_account#g" portal_public_settings.json
sed -i "s#__VM_RESOURCE_ID__#$my_vm_resource_id#g" portal_public_settings.json

# Build the protected settings using the storage account SAS token
my_diagnostic_storage_account_sastoken='?sv=2017-04-17&sig=evAsX6WkOY5hKSVbPbiaRQD9kzQwAmKSaIRIeQUZFkg%3D&se=2018-02-07T15%3A38%3A53Z&srt=sco&ss=bfqt&sp=racupwdl'
my_lad_protected_settings="{'storageAccountName': '$diagnostic_storage_account', 'storageAccountSasToken': '$my_diagnostic_storage_account_sastoken'}"

# Finally, tell Azure to install and enable the extension
az vm extension set --publisher Microsoft.Azure.Diagnostics --name LinuxDiagnostic --version 3.0 \
   --resource-group $resource_group --vm-name $linux_vm --protected-settings "${my_lad_protected_settings}" \
   --settings portal_public_settings.json