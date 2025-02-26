provider "azurerm" {
  features {}
}

# Utiliser une data source pour vérifier si le Resource Group existe déjà
data "azurerm_resource_group" "existing_rg" {
  count = var.check_existing_resources ? 1 : 0
  name  = var.resource_group_name
}

# Création du Resource Group seulement s'il n'existe pas
resource "azurerm_resource_group" "rg" {
  count    = var.check_existing_resources && length(data.azurerm_resource_group.existing_rg) > 0 ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# Référence au Resource Group (existant ou nouvellement créé)
locals {
  resource_group_name = var.check_existing_resources && length(data.azurerm_resource_group.existing_rg) > 0 ? data.azurerm_resource_group.existing_rg[0].name : azurerm_resource_group.rg[0].name
  resource_group_location = var.check_existing_resources && length(data.azurerm_resource_group.existing_rg) > 0 ? data.azurerm_resource_group.existing_rg[0].location : azurerm_resource_group.rg[0].location
}

# Vérifier si le Storage Account existe déjà
data "azurerm_storage_account" "existing_datalake" {
  count               = var.check_existing_resources ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

# Création du Storage Account (Data Lake Gen2) seulement s'il n'existe pas
resource "azurerm_storage_account" "datalake" {
  count                    = var.check_existing_resources && length(data.azurerm_storage_account.existing_datalake) > 0 ? 0 : 1
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # Data Lake Gen2 activé
}

# Référence au Storage Account (existant ou nouvellement créé)
locals {
  storage_account_id = var.check_existing_resources && length(data.azurerm_storage_account.existing_datalake) > 0 ? data.azurerm_storage_account.existing_datalake[0].id : azurerm_storage_account.datalake[0].id
}

# Vérification de l'existence des containers avant création
resource "azurerm_storage_container" "bronze-data" {
  name                  = "bronze-data"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"

  # Cette approche ne crée pas de duplicatas car Terraform détecte les containers existants
  # et les gère comme "déjà existants" dans son état
}

resource "azurerm_storage_container" "data-gouv" {
  name                  = "data-gouv"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold-data" {
  name                  = "gold-data"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
}
