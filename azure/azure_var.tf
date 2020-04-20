variable "image_name" {
  type        = string
  description = "Image Name on Azure"
}

variable "blob_uri" {
  type        = string
  description = "Blob URI of the vhd"
}

variable "linux_hostname" {
    type = string
    description = "Linux Host name (Optional)"
    default = "image-testing"
}

variable "testing_rg" {
    type = string
    description = "Testing RG to create temporary resources (Optional)"
    default = "image-testing"
}

variable "vm_size" {
    type = string
    description = "Linux VM Size ensuring both GEN1 and GEN2 compatibility. Defaults to 'Standard_DS1_v2'. (Optional)"
    default = "Standard_DS1_v2"
}

variable "admin_username" {
    type = string
    description = "adminusername of the Linux VM. Defaults to 'adminuser'"
    default = "adminuser"
}

variable "admin_password" {
    type = string
    description = "Linux Host name (Optional). Defaults to 'Welcome@1234'"
    default = "Welcome@1234"
}

variable "image_testing_vnet" {
    type = string
    description = "--vnet-name for image_testing. Defaults to 'image-testing-vnet'"
    default = "image-testing-vnet"
}

variable "file_uris" {
    type = string
    description = "List of file_uris passed"
}

variable "vhd_name" {
    type = string
    description = "Name of the VHD that is used for Terraform Deployment"
}
