export AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=pbasnalimagestore;AccountKey=wOBm+H8CSesHdDMMWi15bC82rAqLhQdXOMLB7MROIQajp2SQoPFwt1rF/S/QMc+JCAEt5+GK5t6MSD29LKyZJw==;EndpointSuffix=core.windows.net"
export TABLE_NAME="imagevalidationstatus"

# this will create the entries in the table storage
# this will also generate the filtered image list for which 
# validation should be performed

python create_image_entries.py \
    -m "select-images-to-validate" \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -t $TABLE_NAME \
    -e "1" \
    -in files/allimages \
    -out files/filteredimages

## This playbook will run validations
## Copy logs to blob
## Update table storage entries
ansible-playbook validate-vm-image.yaml