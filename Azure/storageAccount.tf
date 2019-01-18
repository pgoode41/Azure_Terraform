resource "azurerm_storage_account" "terraform-storageaccount" {
    name                = "tfstorageaccount6604"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    location            = "eastus"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}