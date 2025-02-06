# azure-aks
WIP

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
* Azure Kubernetes Service 
* Azure Container Registry

## List of referenced modules
All modules used can be found under my jackwesleyroper GitHub account.
* List TBC

## Pre-reqs for setup:

1. Create an Azure Entra Service Principal, give it Owner permissions on the Subscription and under API permission add the Application permission for Microsoft Graph Directory.ReadWrite.All permisssion to enable it to be able to access Entra. Under Certificates & Secrets, Add a credential by selecting 'GitHub Actions Deploying Azure Resources' and fill in the details of your organization name and repo. To have it access the Dev environment for example, the Subsject Identifier in my case is repo:jackwesleyroper/azure-aks:environment:dev, and to enable pushes to the main branch (not recommended directly) it will be repo:jackwesleyroper/azure-aks:ref:refs/heads/main. Note: in this code the service principal is named 'GitHub'.
2. Create an Entra group named `Contributor-KV-<environment_name>` and add users to this that will have AKS access.
3. Create an Entra Service Principal called `aks-nonprod-<environment_name>`.
4. Create a resource group `tf-rg` in the Subscription.
5. Create a storage account in the Subscription with a container named `terraform`.
6. Create GitHub Environments in your repo as needed (e.g. Dev / Prod).
7. Create Secrets in the GitHub environment:
   1. `AZURE_CLIENT_ID`
   2. `AZURE_SUBSCRIPTION_ID`
   3. `AZURE_TENANT_ID`
   4. `TF_STATE_STORAGE_ACCOUNT` (containing storage account name that will hold Terraform State files from step 3)
8. Push the code using the manual workflow dispatch trigger under the actions tab in order, e.g. 001, 002, 003 etc. until all runs have completed. If you change the code in a particular section, the workflows are set to automatically push on updates (CI/CD).

## Build notes / to do

* Add module version constraints after first successful build
* Restict KV access to Github actions listed here: https://api.github.com/meta (currently set to allow public access)
* Add rationale for each stage for resources used and settings
* Is Premium KV needed?
* 