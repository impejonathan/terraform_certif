provider "azurerm" {
  features {}
}

# Vérification si le Resource Group existe
data "azurerm_resource_group" "existing_rg" {
  count = var.check_existing ? 1 : 0
  name  = var.resource_group_name
}

# Création du Resource Group uniquement s'il n'existe pas
resource "azurerm_resource_group" "rg" {
  count    = var.check_existing && length(data.azurerm_resource_group.existing_rg) > 0 ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# Référence au Resource Group (existant ou nouvellement créé)
locals {
  resource_group_name = var.check_existing && length(data.azurerm_resource_group.existing_rg) > 0 ? data.azurerm_resource_group.existing_rg[0].name : try(azurerm_resource_group.rg[0].name, var.resource_group_name)
  resource_group_location = var.check_existing && length(data.azurerm_resource_group.existing_rg) > 0 ? data.azurerm_resource_group.existing_rg[0].location : try(azurerm_resource_group.rg[0].location, var.location)
}

# Vérification si le Storage Account existe
data "azurerm_storage_account" "existing_datalake" {
  count               = var.check_existing ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

# Création du Storage Account uniquement s'il n'existe pas
resource "azurerm_storage_account" "datalake" {
  count                    = var.check_existing && length(data.azurerm_storage_account.existing_datalake) > 0 ? 0 : 1
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

# Référence au Storage Account (existant ou nouvellement créé)
locals {
  storage_account_id = var.check_existing && length(data.azurerm_storage_account.existing_datalake) > 0 ? data.azurerm_storage_account.existing_datalake[0].id : try(azurerm_storage_account.datalake[0].id, "")
}

# Vérification des containers existants
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

# Création des containers uniquement s'ils n'existent pas
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
