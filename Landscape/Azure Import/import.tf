resource "azurerm_resource_group" "nwrg" {
 name = "RG_Compute"
 location = "South India"
  }
  resource "azurerm_virtual_network" "nw" {
    name = "RG_Compute-vnet"
    resource_group_name = azurerm_resource_group.nwrg
    location = "centralindia"
  }
  resource "azurerm_subnet" "subnet" {
    name = "default"
    virtual_network_name = azurerm_virtual_network.nw
    resource_group_name = azurerm_resource_group.nwrg
  }
