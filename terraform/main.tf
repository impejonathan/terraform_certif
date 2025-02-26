provider "azurerm" {
  features {}
}

# Vérification de l'existence du Resource Group
data "azurerm_resource_group" "existing_rg" {
  count = var.check_existing ? 1 : 0
  name  = var.resource_group_name
}

# Création du Resource Group seulement s'il n'existe pas
resource "azurerm_resource_group" "rg" {
  # Ne crée pas si le groupe existe déjà et que check_existing est true
  count    = var.check_existing && length(data.azurerm_resource_group.existing_rg) > 0 ? 0 : 1
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

# Référence au Resource Group (qu'il soit nouveau ou existant)
locals {
  resource_group_name = var.check_existing && length(data.azurerm_resource_group.existing_rg) > 0 ? data.azurerm_resource_group.existing_rg[0].name : azurerm_resource_group.rg[0].name
  location            = var.check_existing && length(data.azurerm_resource_group.existing_rg) > 0 ? data.azurerm_resource_group.existing_rg[0].location : azurerm_resource_group.rg[0].location
}

# Vérification de l'existence du Storage Account
data "azurerm_storage_account" "existing_datalake" {
  count               = var.check_existing ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

# Création du Storage Account seulement s'il n'existe pas
resource "azurerm_storage_account" "datalake" {
  count                    = var.check_existing && length(data.azurerm_storage_account.existing_datalake) > 0 ? 0 : 1
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # Data Lake Gen2 activé

  lifecycle {
    prevent_destroy = true
  }
}

# Référence au Storage Account (qu'il soit nouveau ou existant)
locals {
  storage_account_id = var.check_existing && length(data.azurerm_storage_account.existing_datalake) > 0 ? data.azurerm_storage_account.existing_datalake[0].id : azurerm_storage_account.datalake[0].id
}

# Vérification de l'existence des containers
data "azurerm_storage_container" "existing_bronze" {
  count                = var.check_existing ? 1 : 0
  name                 = "bronze-data"
  storage_account_name = var.storage_account_name
}

data "azurerm_storage_container" "existing_datagouv" {
  count                = var.check_existing ? 1 : 0
  name                 = "data-gouv"
  storage_account_name = var.storage_account_name
}

data "azurerm_storage_container" "existing_gold" {
  count                = var.check_existing ? 1 : 0
  name                 = "gold-data"
  storage_account_name = var.storage_account_name
}

# Création des Containers seulement s'ils n'existent pas
resource "azurerm_storage_container" "bronze-data" {
  count                 = var.check_existing && length(data.azurerm_storage_container.existing_bronze) > 0 ? 0 : 1
  name                  = "bronze-data"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
}

resource "azurerm_storage_container" "data-gouv" {
  count                 = var.check_existing && length(data.azurerm_storage_container.existing_datagouv) > 0 ? 0 : 1
  name                  = "data-gouv"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold-data" {
  count                 = var.check_existing && length(data.azurerm_storage_container.existing_gold) > 0 ? 0 : 1
  name                  = "gold-data"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
}
