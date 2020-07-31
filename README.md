# Validations for Linux Images on Azure (Vhd Supported)
Use this script/pipeline to check if your custom linux image (Vhd) built works on Azure.

## Motivation
We wish to help our customers and also the community who are using Azure to use their
Linux Virtual Machines with custom images and generalized images with less hassle.
Hence the requirement of this pipeline which the customer/community can fork in their repositories
and run as part of their regular validations.

This can also be used by Support teams across and outside Microsoft to validate incoming customers'
images using [Azure Cloud Shell](https://shell.azure.com)

## Requirements

## Brief Working
[Terraform](https://www.terraform.io) is used in setting up of the infrastructure.
Python is used to run the scripts inside the Virtual Machine using the Azure Custom Script Extension
By doing so will perform the inherent validations such as WALinuxAgent Availability 

### Setup
#### Current Setup
1. Single VM
2. Single nic support
3. Testing of Generation 1 and Generation 2 Virtual Machine.
4. HA Not supported
5. Input is currently the SAS Uri to the Linux VHD.

#### Future Setup
1. High Availability with cluster
2. Multiple NIC support

### Output
Output is currently rendered in JSON
We are currently in the Information Gathering wherein most of the details is not validated rather than displayed directly.
The output details are currently available in logs.json 
#### Currently Available
##### System
1. /proc/cmdline - This is used to check if the VM supports Serial console
2. Grub configuration - This is used to check if the VM supports Serial console
3. OS Release and Kernel Version
4. Disk Usage Report
5. MBR/EFI Boot

##### Package Manager
1. Repo availability - (yum and dnf)

#### Future Support
1. Driver details
2. Cloud-Init details
3. Instance Metadata Service (IMDS)

### Validations
#### Current Validations Performed
1. Generation 1 and Generation 2 VM Bootability
2. WALinuxAgent Availability.
3. Network Connectivity
4. Repo Availability (Currently Yum and dnf supported)

#### Future Validations
1. Azure Site Recovery
2. Cloud-Init validation

## Linux Distribution Supported
### Current
1. RedHat
2. CentOS

### Future Support
1. SLES
2. OpenSUSE
3. Ubuntu - (Works - E2E testing is required)
4. Debian - (Works - E2E testing is required)

## Contributing
We sincerely welcome contributions from our customers and community. Together we believe
that we can make this a better validation system for Linux Images on Azure.

### Areas

### Guidelines

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
