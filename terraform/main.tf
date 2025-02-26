provider "azurerm" {
  features {}
}

# Data source pour vérifier l'existence du Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Création du Resource Group seulement s'il n'existe pas déjà
resource "azurerm_resource_group" "rg" {
  count    = data.azurerm_resource_group.rg.id == null ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

# Référence au Resource Group
locals {
  resource_group_id   = coalesce(try(data.azurerm_resource_group.rg.id, null), try(azurerm_resource_group.rg[0].id, null))
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Création du Storage Account - sans vérification conditionnelle
resource "azurerm_storage_account" "datalake" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  # Utiliser cette ligne si vous voulez empêcher la destruction
  lifecycle {
    prevent_destroy = true
    # Cette option ignore les changements sur ces attributs
    ignore_changes = [
      tags,
    ]
  }
}

# Création des containers de stockage
resource "azurerm_storage_container" "bronze-data" {
  name                  = "bronze-data"
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"

  # Empêcher la destruction
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
