terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-JImpe"
    storage_account_name = "saterraformstate-JImpe"
    container_name       = "tfstate-JImpe"
    key                  = "prod.terraform.tfstate"
  }
}
