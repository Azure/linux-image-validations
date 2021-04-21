## This script start the validation process.
## It generates a list of images which should get validated
## and then runs the playbook which validates all the images.

## Set configurations
CURR_DIR=$(pwd)
BASEDIR=$(dirname "$0")
cd $BASEDIR

echo "" > /var/log/validation.log 

. ./configurations/set-env-configs.sh

# this will create the entries in the table storage
# this will also generate the filtered image list for which 
# validation should be performed
python azure-table-data.py \
    -m "select-images-to-validate" \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -t $TABLE_NAME \
    -e "1" \
    -in files/allimages \
    -out files/filteredimages \
    --max-vm-to-validate $MAX_VM_TO_VALIDATE \
    --validation-period $VALIDATION_PERIOD

## This playbook will run validations
## Copy logs to blob
## Update table storage entries
/home/pbasnal/.local/bin/ansible-playbook validate-vm-images.yaml

cd $CURR_DIR

