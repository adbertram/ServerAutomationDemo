#region Var setup
$resourceGroupName = 'ServerAutomationDemo'
$region = 'XXXXXXX'
$localVMAdminPw = 'I like azure.' ## a single password for demo purposes
$projectName = 'ServerAutomationDemo' ## common term used through set up

$subscriptionName = 'XXXXXXXXXX'
$subscriptionId = 'XXXXXXXX'
$tenantId = 'XXXXXXX'
$orgName = 'adbertram'
$gitHubRepoUrl = "https://github.com/$orgName/<repo name>"

#endregion

#region Login
az login
az account set --subscription $subscriptionName
#endregion

#region Install the Azure CLI DevOps extension
az devops configure --defaults organization=https://dev.azure.com/$orgName
#endregion

#region Create the resource group to put everything in
az group create --location $region --name $resourceGroupName
#endregion

#region Create the service principal
$spIdUri = "http://$projectName"
$sp = az ad sp create-for-rbac --name $spIdUri | ConvertFrom-Json
#endregion

#region Key vault

## Create the key vault. Enabling for template deployment because we'll be using it during an ARM deployment
## via an Azure DevOps pipeline later
$kvName = "$projectName-KV"
$keyVault = az keyvault create --location $region --name $kvName --resource-group $resourceGroupName --enabled-for-template-deployment true | ConvertFrom-Json

# ## Create the key vault secrets
az keyvault secret set --name "$projectName-AppPw" --value $sp.password --vault-name $kvName
az keyvault secret set --name StandardVmAdminPassword --value $localVMAdminPw --vault-name $kvName

## Give service principal created earlier access to secrets. This allows the steps in the pipeline to read the AD application's pw and the default VM password
$null = az keyvault set-policy --name $kvName --spn $spIdUri --secret-permissions get list
#endregion

#region Instal the Pester test runner extension in the org
az devops extension install --extension-id PesterRunner --publisher-id Pester
#endregion

#region Create the Azure DevOps project
az devops project create --name $projectName
az devops configure --defaults project=$projectName
#endregion

#region Create the service connections
## Run $sp.password and copy it to the clipboard
$sp.Password
az devops service-endpoint azurerm create --azure-rm-service-principal-id $sp.appId --azure-rm-subscription-id $subscriptionId --azure-rm-subscription-name $subscriptionName --azure-rm-tenant-id $tenantId --name 'ARM'

## Create service connection for GitHub for CI process in pipeline
$gitHubServiceEndpoint = az devops service-endpoint github create --github-url $gitHubRepoUrl --name 'GitHub' | ConvertFrom-Json
## paste in the GitHub token when prompted 
## when prompted, use the value of $sp.password for the Azure RM service principal key
#endregion

#region Create the variable group
$varGroup = az pipelines variable-group create --name $projectName --authorize true --variables foo=bar | ConvertFrom-Json ## dummy variable because it won't allow creation without it

Read-Host "Now link the key vault $kvName to the variable group $projectName in the DevOps web portal and create a '$projectName-AppPw' and StandardVmAdminPassword variables with a password of your choosing."
#endregion

## Create the pipeline

## set the PAT to avoid getting prompted --doesn't work...
# export AZURE_DEVOPS_EXT_GITHUB_PAT=$gitHubAccessToken ## in CMD??
### [System.Environment]::SetEnvironmentVariable("AZURE_DEVOPS_EXT_GITHUB_PAT", $gitHubAccessToken ,"Machine") ???
az pipelines create --name $projectName --repository $gitHubRepoUrl --branch master --service-connection $gitHubServiceEndpoint.id --skip-run

## Add the GitHub PAT here interactively

## Replace the application ID generated in YAML
$sp.appId
##   - name: application_id
##    value: "REMEMBERTOFILLTHISIN"

#region Cleanup

## Remove the SP
$spId = ((az ad sp list --all | ConvertFrom-Json) | ? { $spIdUri -in $_.serviceprincipalnames }).objectId
az ad sp delete --id $spId

## Remove the resource group
az group delete --name $resourceGroupName --yes --no-wait

## remove project
$projectId = ((az devops project list | convertfrom-json).value | where { $_.name -eq $projectName }).id
az devops project delete --id $projectId --yes 

#endregion