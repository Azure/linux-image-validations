# Provider Configuration
provider "azurerm" {
  features {}
}

variable "vm_list" {
  description = "List of VM configurations"
  type = list(object({
    name = string
    publisher = string
    offer = string
    sku = string
    version = string
    upgrade_path = string
    host = string
    dns = string
  }))
  default = []
}


# resource "azurerm_resource_group" "rg" {
#   name     = "example-resource-group-5"
#   location = "East US"
# }

resource "azurerm_public_ip" "publicip" {
  count               = length(var.vm_list)
  name                = "${var.vm_list[count.index].name}_publicip"
  location            = "West US 3"
  resource_group_name = "oldImageTestRG-sisatia"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "example-nsg"
  location            = "West US 3"
  resource_group_name = "oldImageTestRG-sisatia"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "example2-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 3"
  resource_group_name = "oldImageTestRG-sisatia"
}

resource "azurerm_subnet" "subnet" {
  name                 = "example-subnet"
  resource_group_name  = "oldImageTestRG-sisatia"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  #network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  count = length(var.vm_list)

  name                = "${var.vm_list[count.index].name}_NIC"
  location            = "West US 3"
  resource_group_name = "oldImageTestRG-sisatia"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = length(var.vm_list)

  name                = var.vm_list[count.index].name
  location            = "West US 3"
  resource_group_name = "oldImageTestRG-sisatia"
  network_interface_ids = [ azurerm_network_interface.nic[count.index].id,]

  size               = "Standard_D2s_v3"
  admin_username     = "sisatia"
  admin_password     = "Welcome@1234"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.vm_list[count.index].publisher
    offer     = var.vm_list[count.index].offer
    sku       = var.vm_list[count.index].sku
    version   = var.vm_list[count.index].version
  }
}

resource "local_file" "ansible_inventory" {
  count    = length(var.vm_list)
  filename = "${var.vm_list[count.index].name}_inventory.ini"
  content  = "[webservers] \n ${var.vm_list[count.index].name} ansible_host=${azurerm_linux_virtual_machine.vm[count.index].public_ip_address}"
}

resource "null_resource" "ansible_provisioning" {
  count = length(var.vm_list)

  triggers = {
    vm_id = azurerm_linux_virtual_machine.vm[count.index].id
  }

  provisioner "local-exec" {
    command = "ansible-playbook playbook.yml -i ${local_file.ansible_inventory[count.index].filename} -e 'dns=\"${var.vm_list[count.index].dns}\" host=\"${var.vm_list[count.index].host}\" upgrade_path=${var.vm_list[count.index].upgrade_path} ansible_user=sisatia ansible_ssh_pass=Welcome@1234 ansible_sudo_pass=Welcome@1234 ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"'"
  }
}
