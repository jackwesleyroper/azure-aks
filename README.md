# azure-aks

Creates an Azure Kubernetes service and supporting infrastructure using GitHub Actions CICD.

All Terraform modules are hosted in public repositorys and can be fully controlled independantly. 

GitHub connection uses Workload Identity Federation OIDC connection for authentication.

Diagram TBC.

## Infrastructure
The project contains the folowing resources:

* Resource Groups
* VNETS
* Subnets
* Route Tables
* NSGS
* Private DNS Zones
* Private DNS Zone Links
* Azure Monitor Private Link Scope (AMPLS)
* Log Analytics Workspace
* Key Vault
* Key Vault Access Policies
* Key Vault Keys
* User Assigned Identities
* Storage Account
* Monitor Diagnostic Settings
* Network Flow Logs
* Azure Kubernetes Service
* Azure Container Registry

## List of referenced modules
All modules used can be found under my jackwesleyroper GitHub account.
* List TBC

## Pre-reqs for setup:

1. Create an Azure Entra Service Principal, give it Owner permissions on the Subscription and under API permission add the following Application permissions to enable it to be able to access Entra:
   1. Application.ReadWrite.All
   2. Directory.ReadWrite.All
   3. Group.ReadWrite.All
   4. GroupMember.ReadWrite.All
   5. RoleManagement.ReadWrite.Directory 
2. Under Certificates & Secrets, Add a credential by selecting 'GitHub Actions Deploying Azure Resources' and fill in the details of your organization name and repo. To have it access the Dev environment for example, the Subsject Identifier in my case is repo:jackwesleyroper/azure-aks:environment:dev, and to enable pushes to the main branch (not recommended directly) it will be repo:jackwesleyroper/azure-aks:ref:refs/heads/main. Note: in this code the service principal is named 'GitHub'.
3. Create an Entra group named `Contributor-KV-<environment_name>` and add users to this that will have Key Vault access.
4. Create an Entra group named `AKS-Admin-<environment_name>` and add users to this that will have AKS Admin access.
5. Create an Entra Service Principal called `aks-nonprod-<environment_name>`.
6. To create an Azure Kubernetes Service cluster with API Server VNet Integration - we need to register for the preview extension. Using Azure CLI, run: `az extension add --name aks-preview` and then update `az extension update --name aks-preview` - then register the Register the 'EnableAPIServerVnetIntegrationPreview' feature flag using `az feature register --namespace "Microsoft.ContainerService" --name "EnableAPIServerVnetIntegrationPreview"`. It takes a few minutes for the status to show Registered, check using `az feature show --namespace "Microsoft.ContainerService" --name "EnableAPIServerVnetIntegrationPreview"`, then refresh the registration of the Microsoft.ContainerService resource provider using the az provider register command `az provider register --namespace Microsoft.ContainerService`.
7. Check Quotas on your subscription for `Standard BS Family vCPUs` - default is 20 and with the code settings you will need to request additonal (25 in total to handle scaling). Just search for Quotas in the portal and request the increase.
8. Create a resource group `tf-rg` in the Subscription.
9.  Create a storage account in the Subscription with a container named `terraform`.
10. Create GitHub Environments in your repo as needed (e.g. Dev / Prod).
11. Create Secrets in the GitHub environment:
   1. `AZURE_CLIENT_ID`
   2. `AZURE_SUBSCRIPTION_ID`
   3. `AZURE_TENANT_ID`
   4. `TF_STATE_STORAGE_ACCOUNT` (containing storage account name that will hold Terraform State files from step 3)
12. Push the code using the manual workflow dispatch trigger under the actions tab in order, e.g. 001, 002, 003 etc. until all runs have completed. If you change the code in a particular section, the workflows are set to automatically push on updates (CI/CD). Lastly run the Deploy Manifest pipeline to deploy the container to the cluster.

## Testing

To connect to your Nginx instance deployed on Azure Kubernetes Service (AKS) and check if it's working, you can follow these steps:

Get the External IP Address: After deploying the Nginx instance, you need to get the external IP address of the service. You can do this by running the following command:

`kubectl get services nginx-service`
Look for the EXTERNAL-IP column in the output. It might take a few minutes for the external IP to be assigned.

Access the Nginx Instance: Once you have the external IP address, you can open a web browser and navigate to `http://<EXTERNAL-IP>`. You should see the default Nginx welcome page if everything is working correctly.

Verify the Deployment: You can also verify the deployment by checking the pods' status. Run the following command to see the status of the pods:

`kubectl get pods`
Ensure that the Nginx pod is in the Running state.

## Build notes / to do

* Restict KV access to Github actions listed here: https://api.github.com/meta (currently set to allow public access and default action is allow)
* Add rationale for each stage for resources used and settings
* Is Premium KV needed?