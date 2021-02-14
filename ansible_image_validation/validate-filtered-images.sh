export AZURE_STORAGE_CONNECTION_STRING="<connection_string>"
export TABLE_NAME="imagevalidationstatus"

# this will create the entries in the table storage
# this will also generate the filtered image list for which 
# validation should be performed

python azure-table-data.py \
    -m "select-images-to-validate" \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -t $TABLE_NAME \
    -e "1" \
    -in files/allimages \
    -out files/filteredimages

## This playbook will run validations
## Copy logs to blob
## Update table storage entries
ansible-playbook validate-vm-images.yaml

#cat files/filteredimages