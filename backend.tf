
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-taskvms"
    storage_account_name = "devtaskvms12216"
    container_name       = "taskvms"
    key                  = "terraform.tfstate"
  }
}