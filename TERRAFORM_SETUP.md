# GitHub Actions Terraform Deployment Setup Guide

## Overview
This guide provides step-by-step instructions to configure the GitHub Actions workflow for deploying Terraform infrastructure to Azure.

## Prerequisites
- GitHub repository with your Terraform code
- Azure subscription
- Azure Service Principal (or use GitHub OpenID Connect)
- Azure CLI installed locally

## Step 1: Create Azure Service Principal

### Option A: Using Azure CLI
```bash
az ad sp create-for-rbac --name "github-terraform-deployer" --role Contributor --scopes /subscriptions/{subscription-id}
```

Replace `{subscription-id}` with your Azure subscription ID.

This command returns:
```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "github-terraform-deployer",
  "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Option B: Using Azure Portal
1. Go to Azure AD > App registrations > New registration
2. Create an app with a name like "github-terraform-deployer"
3. Create a client secret
4. Grant Contributor role to the service principal

## Step 2: Configure GitHub Secrets

In your GitHub repository, navigate to **Settings > Secrets and variables > Actions** and add the following secrets:

| Secret Name | Value |
|------------|-------|
| `AZURE_CLIENT_ID` | The `appId` from the service principal |
| `AZURE_TENANT_ID` | The `tenant` ID from the service principal |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID |
| `AZURE_CLIENT_SECRET` | The `password` from the service principal (if not using OpenID Connect) |

## Step 3: Update Terraform Provider Configuration

### ⚠️ SECURITY WARNING: Hardcoded Credentials
Your current `provider.tf` contains hardcoded credentials. This is a **security risk**. 

Replace `provider.tf` with:

```terraform
terraform {
  required_version = ">=1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0"
    }
  }
}

provider "azurerm" {
  features {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id

  # OR use Azure CLI authentication in local development
  # Just remove the credentials above and authenticate with: az login
}
```

Add to `variable.tf`:

```terraform
variable "azure_client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}
```

## Step 4: Update Workflow Environment Variables (Optional)

If you want to pass Azure credentials via environment variables instead of provider config:

```bash
export ARM_CLIENT_ID=${{ secrets.AZURE_CLIENT_ID }}
export ARM_CLIENT_SECRET=${{ secrets.AZURE_CLIENT_SECRET }}
export ARM_TENANT_ID=${{ secrets.AZURE_TENANT_ID }}
export ARM_SUBSCRIPTION_ID=${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Step 5: Configure Remote State Backend

For team collaboration, update your backend configuration:

```terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "rsg-dev123"
    storage_account_name = "stdevtfstate58943"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

Add this to `main.tf` or a new `backend.tf` file.

## Step 6: Test the Workflow

1. Push changes to the `develop` branch to trigger a plan-only run
2. Review the plan in the PR comments
3. Merge to `main` to trigger the apply

## Workflow Triggers

- **Push to main**: Runs terraform plan + apply (with production approval)
- **Push to develop**: Runs terraform plan only
- **Pull requests**: Runs terraform plan and adds comment to PR
- **Manual trigger**: Use workflow_dispatch in GitHub Actions tab

## Best Practices

### ✅ Security
- ✓ Never commit credentials to the repository
- ✓ Use GitHub Secrets for all sensitive data
- ✓ Use managed identities or OpenID Connect when possible
- ✓ Rotate service principal credentials regularly
- ✓ Use specific resource group scopes instead of subscription-wide access

### ✅ Terraform
- ✓ Always review plan before apply
- ✓ Use terraform format checking
- ✓ Enable state locking (add backend configuration)
- ✓ Use environment separation (dev/qa/prod)
- ✓ Version lock providers and terraform

### ✅ CI/CD
- ✓ Use separate environments for different approval requirements
- ✓ Add status badges to your repository
- ✓ Document infrastructure changes
- ✓ Implement automated testing (tfsec, checkov)

## Advanced: GitHub OpenID Connect (Recommended)

For enhanced security without using client secrets:

```bash
az ad app federated-credential create \
  --id {appId} \
  --parameters credential.json
```

Then use the `azure/login@v1` action with only client-id and tenant-id.

## Troubleshooting

**Error: "Unable to locate credentials"**
- Verify all GitHub Secrets are correctly set
- Check secret values don't have extra spaces
- Ensure service principal has necessary permissions

**Error: "Insufficient permissions"**
- Grant the service principal Contributor role: 
```bash
az role assignment create --assignee {appId} --role Contributor
```

**Terraform state file issues**
- Ensure storage account and container exist
- Verify service principal has access to storage account
- Check storage account firewall settings

## Additional Resources

- [GitHub Actions Azure Login Documentation](https://github.com/Azure/login)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Service Principal Best Practices](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
