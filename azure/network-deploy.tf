resource "azurerm_virtual_network" "image_testing_vnet" {
  name                = var.image_testing_vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azure_rg_temp.location
  resource_group_name = azurerm_resource_group.azure_rg_temp.name
}

resource "azurerm_subnet" "image_testing_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.azure_rg_temp.name
  virtual_network_name = azurerm_virtual_network.image_testing_vnet.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "gen1_nic" {
  name                = "image-gen1-nic"
  location            = azurerm_resource_group.azure_rg_temp.location
  resource_group_name = azurerm_resource_group.azure_rg_temp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.image_testing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "gen2_nic" {
  name                = "image-gen2-nic"
  location            = azurerm_resource_group.azure_rg_temp.location
  resource_group_name = azurerm_resource_group.azure_rg_temp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.image_testing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}