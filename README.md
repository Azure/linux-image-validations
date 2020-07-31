# Validations for Linux Images on Azure (Vhd Supported)
Use this script/pipeline to check if your custom linux image (Vhd) built works on Azure.

# Table of Contents
1. [Motivation](#motivation)
2. [Requirements](#requirements)
   1. [Linux / macOS / Windows](#linux--macos--windows)
   2. [Azure Pipelines](#azure-pipelines)
   3. [Azure Cloud Shell](#azure-cloud-shell) 
3. [Installation](#installation)
4. [Working](#working)
   1. [Setup](#setup)
      1. [Current Setup](#current-setup)
      2. [Future Setup](#future-setup)
   2. [Output](#output)
      1. [Current Available Output](#currently-available)
      2. [Future Enhancement](#future-support)
      3. [Example](#example)
   3. [Validations](#validations)
      1. [Current Available Validations](#current-validations-performed)
      2. [Future Support / Enhancement](#future-support)
5. [Contributing to the Repository](#contributing)
   1. [Areas of contribution](#areas)
   2. [Feature Request, Issue and Bug Reporting](#issue-and-bug-reporting)
   3. [Code Optimizations / Enhancements](#code-enhancements)
   4. [Microsoft OpenSource code of conduct](#code-of-conduct)
6. [Maintainers](#maintainers)

   

## Motivation
We wish to help our customers and also the community who are using Azure to use their
Linux Virtual Machines with custom images and generalized images with less hassle.
Hence the requirement of this pipeline which the customer/community can fork in their repositories
and run as part of their regular validations.

This can also be used by Support teams across and outside Microsoft to validate incoming customers'
images using [Azure Cloud Shell](https://shell.azure.com)

## Requirements
### Linux / macOS / Windows
1. [Terraform](https://www.terraform.io)
   1. [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html)
2. Azure Account
   1. [Azure AAD Appliation Id Setup](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli)
   2. Currently AAD Application ID and Client Secret is Supported
   3. Ensure that Azure App has contributor access

### Azure Pipelines
1. Ensure that Terraform is available on Azure pipeline
2. Ensure that relevant pipeline variables are set

### Azure Cloud Shell
All requirements are met

## Installation
1. Ensure that [Requirements](#requirements) is met
2. clone the repo using the following command
   ``` bash
   git clone https://github.com/Azure/linux-image-validations
   ```
2. Tar the validations folder using the following command
   ``` bash
   tar -cvzf validations/* validator.tar.gz
   ```
3. Ensure that ```validator.tar.gz``` is present inside an Azure Storage Account.
   ```
   https://storage_account.blob.core.windows.net/container/validator.tar.gz
   ```
4. Create a file called validate_upload.sh with the following details and place it inside the storage account
   ``` bash
   #!/bin/bash -e
   generation=$2
   vhdName=$1
   sudo $(which tar) -xzf validator.tar.gz

   [[ -n "$(uname -a | grep -i $distro)" || -n "$(uname -a | grep -i debian)" ]] && sudo $(which python) validate.py
   [[ -n "$(uname -a | grep -i $redhat)" || -n "$(uname -a | grep -i centos)" ]] && sudo $(which platform_python) validate.py 

   cat logs.json
   
   # Example of a curl call
   echo "https://contoso.com/images/$vhdName/validation/$generation"
   curl --location --request POST "https://contoso.com/images/$vhdName/validation/$generation" \
   --header 'Content-Type: application/json' -d @logs.json

   ```
5. For folks who wish to run from commandline. Do note that this is to be performed after previous steps are in place.
   1. Deploying Resources (Terraform variables / Environment variables can also be used)
   ``` bash 
   cd linux-image-validations/azure
   terraform apply
   ```
   2. Cleanup of Resources
   ```
   cd linux-image-validations/azure
   terraform destroy
   ```

## Working
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

#### Example
``` json
{
  "name": "ImageBuild Validator",
  "generation": "GEN2",
  "hostname": "image-testing-GEN2",
  "imageName": "image",
  "version": "1.0.0",
  "date": "2020-05-28 16:32:37.079351",
  "systemInformation": {
    "kernel": "3.10.0-1062.el7.x86_64",
    "machine": "x86_64",
    "platform": "Linux-3.10.0-1062.el7.x86_64-x86_64-with-redhat-7.7-Maipo",
    "isEfiBooted": true,
    "procCmdline": "BOOT_IMAGE=/vmlinuz-3.10.0-1062.el7.x86_64 root=/dev/mapper/rootvg-rootlv ro crashkernel=auto console=tty1 console=ttyS0 earlyprintk=ttyS0 rootdelay=300 scsi_mod.use_blk_mq=y",
    "disk": [
      {
        "labelType": "gpt",
        "name": "sda",
        "partitions": [
          {
            "fstype": "vfat",
            "name": "sda1",
            "size": "500M"
          },
          {
            "fstype": "xfs",
            "name": "sda2",
            "size": "500M"
          },
          {
            "fstype": "part",
            "name": "sda3",
            "size": "2M"
          },
          {
            "fstype": "LVM2_member",
            "name": "sda4",
            "size": "63G"
          },
          {
            "fstype": "LVM2_member",
            "name": "sda4",
            "size": "63G"
          },
          {
            "fstype": "LVM2_member",
            "name": "sda4",
            "size": "63G"
          },
          {
            "fstype": "LVM2_member",
            "name": "sda4",
            "size": "63G"
          },
          {
            "fstype": "LVM2_member",
            "name": "sda4",
            "size": "63G"
          },
          {
            "fstype": "LVM2_member",
            "name": "sda4",
            "size": "63G"
          }
        ]
      },
      {
        "labelType": "dos",
        "name": "sdb",
        "partitions": [
          {
            "fstype": "ext4",
            "name": "sdb1",
            "size": "7G"
          }
        ]
      }
    ],
    "os": "Red Hat Enterprise Linux Server 7.7 Maipo",
    "processor": "x86_64"
  },
  "updateInformation": {
    "repos": [
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support - Supplementary (Debug RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/debug/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/debug/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/debug/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-supplementary-debuginfo"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support - Optional (Debug RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/debug/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/debug/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/debug/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-optional-debug-rpms"
      },
      {
        "name": "Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": true,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/os/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/os/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/os/"
        ],
        "verify": true,
        "id": "rhui-rhel-server-rhui-rhscl-7-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support - Supplementary (RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": true,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/os/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/os/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/os/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-supplementary-rpms"
      },
      {
        "name": "Red Hat Software Collections Debug RPMs for Red Hat Enterprise Linux 7 Server from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/debug/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/debug/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/debug/"
        ],
        "verify": true,
        "id": "rhui-rhel-server-rhui-rhscl-7-debug-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support - Optional (Source RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/source/SRPMS/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/source/SRPMS/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/source/SRPMS/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-optional-source-rpms"
      },
      {
        "name": "Microsoft Azure RPMs for Red Hat Enterprise Linux 7 (EUS)",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": true,
        "sslclientcert": null,
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/microsoft-azure-rhel7-eus/",
          "https://rhui-2.microsoft.com/pulp/repos/microsoft-azure-rhel7-eus/",
          "https://rhui-3.microsoft.com/pulp/repos/microsoft-azure-rhel7-eus/"
        ],
        "verify": true,
        "id": "rhui-microsoft-azure-rhel7-eus"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support - Optional (RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": true,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/os/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/os/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/optional/os/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-optional-rpms"
      },
      {
        "name": "dotNET on RHEL Debug RPMs for Red Hat Enterprise Linux 7 Server from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/debug/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/debug/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/debug/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-dotnet-rhui-debug-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support - Supplementary (Source RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/source/SRPMS/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/source/SRPMS/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/supplementary/source/SRPMS/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-supplementary-source-rpms"
      },
      {
        "name": "dotNET on RHEL Source RPMs for Red Hat Enterprise Linux 7 Server from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/source/SRPMS/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/source/SRPMS/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/source/SRPMS/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-dotnet-rhui-source-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support (Debug RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/debug/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/debug/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/debug/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-debug-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support (RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": true,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/os/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/os/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/os/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-rpms"
      },
      {
        "name": "Red Hat Software Collections Source RPMs for Red Hat Enterprise Linux 7 Server from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/source/SRPMS/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/source/SRPMS/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rhscl/1/source/SRPMS/"
        ],
        "verify": true,
        "id": "rhui-rhel-server-rhui-rhscl-7-source-rpms"
      },
      {
        "name": "dotNET on RHEL RPMs for Red Hat Enterprise Linux 7 Server from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": true,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/os/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/os/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/dotnet/1/os/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-dotnet-rhui-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - Extended Update Support (Source RPMs) from RHUI",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/source/SRPMS/",
          "https://rhui-2.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/source/SRPMS/",
          "https://rhui-3.microsoft.com/pulp/repos/content/eus/rhel/rhui/server/7/7.7/x86_64/source/SRPMS/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-eus-source-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - RH Common from RHUI (RPMs)",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": true,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/os/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/os/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/os/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-rh-common-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - RH Common from RHUI (Source RPMs)",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/source/SRPMS/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/source/SRPMS/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/source/SRPMS/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-rh-common-source-rpms"
      },
      {
        "name": "Red Hat Enterprise Linux 7 Server - RH Common from RHUI (Debug RPMs)",
        "vars": {
          "releasever": "7.7",
          "basearch": "x86_64",
          "arch": "ia32e",
          "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
        },
        "enabled": false,
        "sslclientcert": "/etc/pki/rhui/product/content-rhel7-eus.crt",
        "baseurl": [
          "https://rhui-1.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/debug/",
          "https://rhui-2.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/debug/",
          "https://rhui-3.microsoft.com/pulp/repos//content/dist/rhel/rhui/server/7/7Server/x86_64/rh-common/debug/"
        ],
        "verify": true,
        "id": "rhui-rhel-7-server-rhui-rh-common-debug-rpms"
      }
    ],
    "yumvar": {
      "arch": "ia32e",
      "basearch": "x86_64",
      "releasever": "7.7",
      "uuid": "760859cc-c8d5-47a2-8499-9f568670333f"
    }
  }
}
```

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
1. **Documentation**
2. **Code Enhancement**
3. **Testing and Bug Reports**


### Issue and Bug Reporting
Issue Template to report Bugs and bugs are tracked on [issues](https://github.com/Azure/linux-image-validations) tab.
This can also be used to propose new feature request. Please turn the ```feature-request``` flag
```
[Issue Occurrence - Optional]
Short one-liner issue statement

[Environment]
1. Linux / Windows / OS X
2. Azure Pipelines
3. CloudShell

[Description]
Provide Detailed Description explaining the issue statement
Add Screenshots / Snippets / Error messages if necessary

[Steps to Reproduce]

[Severity]
```

### Code Enhancement
1. naming convention for terraform scripts - snake_case for variables
2. [PEP-8](https://python.org/dev/peps/pep-0008) for Python is followed
3. Commit Message format.
   ```
   <Repo Name / Work Name>: Short one-liner of the work
   
   Description:
   <Provide your description in brief>
   
   Signed-off-by: 
   ```
   Multiple file changes involving multiple work should be submitted with multiple commits.
   
   
### Code of Conduct

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# Maintainers
 1. [Sriharsha B S](https://github.com/sribs)
 2. [Pankaj Basnal](https://github.com/Pbasnal)
 3. [Abhilash Gopal](https://github.com/abgopal)
