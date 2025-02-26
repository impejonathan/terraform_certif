terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-impe"
    storage_account_name = "satfstateimpe" 
    container_name       = "tfstate-impe-jonathan"
    key                  = "prod.terraform.tfstate"
  }
}
