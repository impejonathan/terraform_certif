terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-impe-jonathan"
    storage_account_name = "saterraformstate-impe-jonathan"
    container_name       = "tfstate-impe-jonathan"
    key                  = "prod.terraform.tfstate"
  }
}
