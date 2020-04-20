resource "azurerm_virtual_machine_extension" "gen1_extension" {
    name                 = "hostname"
    virtual_machine_id   = azurerm_linux_virtual_machine.vm_gen1.id
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
        {
            "fileUris": ${jsonencode(var.file_uris)},
            "commandToExecute": "./validate_upload.sh ${var.vhd_name}.vhd gen1"
        }
    SETTINGS


    tags = {
        environment = "Production"
    }
}

resource "azurerm_virtual_machine_extension" "gen2_extension" {
    name                 = "hostname"
    virtual_machine_id   = azurerm_linux_virtual_machine.vm_gen2.id
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
        {
            "fileUris": ${jsonencode(var.file_uris)},
            "commandToExecute": "./validate_upload.sh ${var.vhd_name}.vhd gen2"
        }
    SETTINGS

    tags = {
        environment = "Production"
    }
}