provider "azurerm" {
    skip_provider_registration = true
    features {}
}

resource "azurerm_resource_group" "azure_rg_temp" {
    name = var.testing_rg
    location = "West US"
}

resource "azurerm_image" "gen2_image" {
    name = "${var.image_name}-GEN2"
    location = "West US"
    resource_group_name = azurerm_resource_group.azure_rg_temp.name
    hyper_v_generation = "V2"

    os_disk {
        os_type = "Linux"
        os_state = "generalized"
        blob_uri = var.blob_uri
  }  
}

resource "azurerm_image" "gen1_image" {
    name = "${var.image_name}-GEN1"
    location = "West US"
    resource_group_name = azurerm_resource_group.azure_rg_temp.name

    os_disk {
        os_type = "Linux"
        os_state = "generalized"
        blob_uri = var.blob_uri
  }  
}
