# How to Use
## Environment setup 
**below is just a guideline and not exact steps**
* Ansible
* Azure ansible modules 
    * setuptools_rust with pip
    * install msrestazure with pip
    * install ansible[azure] with pip

## Azure Infra setup
* A Resource group with - 
    * Storage account
        * Storage Table to keep Validation Status
        * Storage Blob Container to keep all the logs from validation
        * Enabled with static page server
* A resource group with - 
    * VNet for host machines - Controller VM should have access to the new VMs which will be created during the process. This is achieved by creating a VNet and having VNet peering between the controller and host VNet.
* Both the Resource groups which have been mentioned above can be same or different.

## Running Validations
* Configure environment variables which are used by the playbooks and scripts by updating the file ./**configurations/set-env-configs.sh**
    This script configures below settings
    * AZURE_STORAGE_CONNECTION_STRING - Connection string for the storage account where table and blobs are present
    * TABLE_NAME - Name of the Storage table where validation results will be uploaded
    * CONTAINER_NAME - Name of the container where log files will be uploaded
    * ACCOUNT_NAME - Storage account name
    * STORAGE_ACCOUNT_RESOURCE_GROUP - Resource group of storage account
    * MAX_VM_TO_VALIDATE - Number of VMs to validate in a single run
    * RESOURCE_GROUP - Resource group where the Host machines will be created
    * ADMIN_USER_NAME - Admin user name with which host machine should be created
    * ADMIN_PASSWORD - Password to be used for the host machines
    * HOST_VNET_NAME - Name of the VNet to be used for the host machines

* Populate the files/allimages file.
    * This is the file which contains list of all images which should get validated. From this list, at max MAX_VM_TO_VALIDATE images will be picked up for validation in every run.
    * This file can be generated with the below command
    ```shell
    $ ./create_image_list_to_validate.sh
    ```

* Run the validate-filtered-images.sh to start validation process
    ```shell
    $ ./validate-filterred-images.sh
    ```

## Run validations on a specific image
* Update the files/filteredimages to contain only the images which need validations
* Set up environment variables manually by configuring ./configurations/set-env-configs.sh and executing it - 
    ```shell
    $ . ./configurations/set-env-configs.sh
    ````
* Then execute the playbook -
    ```shell
    $ ansible-playbook validate-vm-images.yaml
    ````

# Scripts and playbooks 
## create_image_list_to_validate.sh
This file queries azure to get the list of images available in the azure marketplace. This file generates the file files/filteredimages. To do that it uses azure-table-data.py 

## files/allimages
This file should contain list of images which should get validated. It can be manually created and maintained.

## files/filteredimages
This file should contain list of images which should get validated in a single run. It is automatically populated by the validate-filtered-images.sh. It can be configured manually as well as described in the section **Run validations on a specific image**

## validate-filtered-images.sh
This script takes the file filteredimages and performs the following operations for each entry in the file.
* Create the VM on azure
* Run yum repolist for each region inside the VM
* Capture logs for yum repolist and copy them to the controller machine
* Run the validate.py script in validations folder [Feature is commented as of now]
* Upload the logs to blob storage
* Create entry with validation status for each VM in Table Storage
* Delete the VM after validation

To do that it uses azure-table-data.py. It also uses the validate-vm-images.yaml playbook to ochestrate all the above mentioned operations.

## set_validation_results.sh
This script creates/updates the entries in the Table Storage. To do that it uses azure-table-data.py 


## validate-vm-images.yaml
This is the main playbook which creates, validates and deletes the VMs.

## upload-logs.yaml
This playbook uploads the logs to blob storage

## vm-playbooks
* create-new-hosts.yaml - This playbook creates a VM in azure
* remove-vm.yaml - This playbook removes the created VM

## validation-playbooks
* per-region-validations.yaml - This playbook will execute validations which should run on a VM for every region. Currently it's used to validate yum repolist for each region.

