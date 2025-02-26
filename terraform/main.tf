provider "azurerm" {
  features {}
}

# Vérification de l'existence du Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

# Si le Resource Group n'existe pas, on le crée
resource "azurerm_resource_group" "rg" {
  count    = length(data.azurerm_resource_group.existing_rg.id) > 0 ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# Vérification de l'existence du Storage Account
data "azurerm_storage_account" "existing_sa" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Si le Storage Account n'existe pas, on le crée
resource "azurerm_storage_account" "datalake" {
  count                             = length(data.azurerm_storage_account.existing_sa.id) > 0 ? 0 : 1
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  is_hns_enabled                    = true # Data Lake Gen2 activé
}

# Création des Containers (Blobs) pour le Data Lake
resource "azurerm_storage_container" "bronze-data" {
  name                  = "bronze-data"
  storage_account_id    = azurerm_storage_account.datalake[0].id
  container_access_type = "private"
}

resource "azurerm_storage_container" "data-gouv" {
  name                  = "data-gouv"
  storage_account_id    = azurerm_storage_account.datalake[0].id
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold-data" {
  name                  = "gold-data"
  storage_account_id    = azurerm_storage_account.datalake[0].id
  container_access_type = "private"
}
