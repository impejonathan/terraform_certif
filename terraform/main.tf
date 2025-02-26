provider "azurerm" {
  features {}
}

# Data source pour vérifier l'existence du Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Création du Resource Group seulement s'il n'existe pas déjà
resource "azurerm_resource_group" "rg" {
  # Création conditionnelle sans détruire l'existant
  count    = try(data.azurerm_resource_group.rg.id, "") == "" ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

# Référence au Resource Group (qu'il soit existant ou créé)
locals {
  resource_group_name = try(data.azurerm_resource_group.rg.name, try(azurerm_resource_group.rg[0].name, var.resource_group_name))
  location            = try(data.azurerm_resource_group.rg.location, try(azurerm_resource_group.rg[0].location, var.location))
}

# Data source pour vérifier l'existence du Storage Account
data "azurerm_storage_account" "datalake" {
  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_resource_group.rg]
}

# Création du Storage Account seulement s'il n'existe pas
resource "azurerm_storage_account" "datalake" {
  count                    = try(data.azurerm_storage_account.datalake.id, "") == "" ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

# Référence au Storage Account
locals {
  storage_account_id = try(data.azurerm_storage_account.datalake.id, try(azurerm_storage_account.datalake[0].id, ""))
}

# Vérification si les containers existent déjà
data "azurerm_storage_container" "bronze" {
  count                = 1
  name                 = "bronze-data"
  storage_account_name = var.storage_account_name
  depends_on           = [data.azurerm_storage_account.datalake, azurerm_storage_account.datalake]
}

data "azurerm_storage_container" "datagouv" {
  count                = 1
  name                 = "data-gouv"
  storage_account_name = var.storage_account_name
  depends_on           = [data.azurerm_storage_account.datalake, azurerm_storage_account.datalake]
}

data "azurerm_storage_container" "gold" {
  count                = 1
  name                 = "gold-data"
  storage_account_name = var.storage_account_name
  depends_on           = [data.azurerm_storage_account.datalake, azurerm_storage_account.datalake]
}

# Création des containers s'ils n'existent pas déjà
resource "azurerm_storage_container" "bronze-data" {
  count                 = try(data.azurerm_storage_container.bronze[0].id, "") == "" ? 1 : 0
  name                  = "bronze-data"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.datalake]
}

resource "azurerm_storage_container" "data-gouv" {
  count                 = try(data.azurerm_storage_container.datagouv[0].id, "") == "" ? 1 : 0
  name                  = "data-gouv"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.datalake]
}

resource "azurerm_storage_container" "gold-data" {
  count                 = try(data.azurerm_storage_container.gold[0].id, "") == "" ? 1 : 0
  name                  = "gold-data"
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.datalake]
}
