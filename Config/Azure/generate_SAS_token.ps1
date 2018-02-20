$resourceGroup = "ERNIE"
$storageAccountName = "erniediag759"
Login-AzureRmAccount
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
$ctx = $storageAccount.Context
$expiration = [System.DateTime]::Now.AddYears(100)
$accountSAS = New-AzureStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -ExpiryTime $expiration -Context $ctx

echo "Generated SAS token=``$accountSAS``, expiring at $expiration"