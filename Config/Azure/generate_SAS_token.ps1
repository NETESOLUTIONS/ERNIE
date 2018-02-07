$resourceGroup = "ERNIE"
$storageAccountName = "erniediag759"
Login-AzureRmAccount
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
$ctx = $storageAccount.Context
$accountSAS = New-AzureStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -Context $ctx
echo "Generated SAS token:"
echo $accountSAS