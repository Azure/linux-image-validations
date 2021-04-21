create_image_list_to_validate.sh
==================================
This file queries azure to get the list of images available in the azure marketplace. This file generates the file files/filteredimages. To do that it uses azure-table-data.py 

files/filteredimages
==================================
This file should contain list of images which should get validated. It can be manually created and maintained.

validate-filtered-images.sh
==================================
This script takes the file filteredimages and performs the following operations for each entry in the file.
* Create the VM on azure
* Run yum repolist for each region inside the VM
* Capture logs for yum repolist and copy them to the controller machine
* Run the validate.py script in validations folder [Feature is commented as of now]
* Upload the logs to blob storage
* Create entry with validation status for each VM in Table Storage
* Delete the VM after validation

To do that it uses azure-table-data.py. It also uses the validate-vm-images.yaml playbook to ochestrate all the above mentioned operations.


set_validation_results.sh
==================================
This script creates/updates the entries in the Table Storage. To do that it uses azure-table-data.py 


validate-vm-images.yaml
==================================
This is the main playbook which creates, validates and deletes the VMs.

upload-logs.yaml
==================================
This playbook uploads the logs to blob storage

vm-playbooks
==================================
* create-new-hosts.yaml - This playbook creates a VM in azure
* remove-vm.yaml - This playbook removes the created VM

validation-playbooks
==================================
* per-region-validations.yaml - This playbook will execute validations which should run on a VM for every region. Currently it's used to validate yum repolist for each region.

