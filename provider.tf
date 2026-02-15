
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
}

resource "azurerm_storage_account" "sa" {
  name                     = "stdevtfstate58943"
  resource_group_name      = azurerm_resource_group.rsg.name
  location                 = azurerm_resource_group.rsg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}
resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}
