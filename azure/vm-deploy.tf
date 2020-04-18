resource "azurerm_linux_virtual_machine" "vm_gen1" {
    name                = azurerm_image.gen1_image.name
    resource_group_name = azurerm_resource_group.azure_rg_temp.name
    location            = azurerm_resource_group.azure_rg_temp.location
    size                = "Standard_DS1_v2"
    admin_username      = "adminuser"
    admin_password      = "Welcome@1234"
    computer_name       = "ImageTesting-GEN1"
    source_image_id     = azurerm_image.gen1_image.id
    disable_password_authentication = false

    network_interface_ids = [
        azurerm_network_interface.gen1_nic.id,
    ]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
}

resource "azurerm_linux_virtual_machine" "vm_gen2" {
    name                = azurerm_image.gen2_image.name
    resource_group_name = azurerm_resource_group.azure_rg_temp.name
    location            = azurerm_resource_group.azure_rg_temp.location
    size                = "Standard_DS1_v2"
    admin_username      = "adminuser"
    admin_password      = "Welcome@1234"
    computer_name       = "ImageTesting-GEN2"
    source_image_id     = azurerm_image.gen2_image.id
    disable_password_authentication = false

    network_interface_ids = [
        azurerm_network_interface.gen2_nic.id,
    ]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
}