resource "azurerm_resource_group" "azy_network" {
	location = "West US"
	name = "testresourcegroup"	
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.azy_network.name}"

    


    resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name = "${azurerm_resource_group.azy_network.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.2.0/24"
}

    tags {
      environment = "Terraform Demo"
    }
}