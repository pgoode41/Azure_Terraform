resource "azurerm_image" "test" {
  name                = "test"
  location            = "West US"
  resource_group_name = "myResourceGroup"

}
