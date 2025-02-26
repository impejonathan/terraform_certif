provider "azurerm" {
  features {}
}

# Data source pour vérifier l'existence du Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Pas besoin de créer le Resource Group, nous utilisons l'existant
# Référence au Resource Group existant
locals {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

# Création du Storage Account avec lifecycle protection
resource "azurerm_storage_account" "datalake" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  lifecycle {
    prevent_destroy = true
  }
}

# Création des containers
resource "azurerm_storage_container" "bronze-data" {
  name                  = "bronze-data"
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "data-gouv" {
  name                  = "data-gouv"
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "gold-data" {
  name                  = "gold-data"
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}
