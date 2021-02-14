IMAGE_NAME=$1
CURRENT_EPOCH=$2
VALIDATION_TIME=$3
VALIDATION_RESULT=$4

AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=pbasnalimagestore;AccountKey=wOBm+H8CSesHdDMMWi15bC82rAqLhQdXOMLB7MROIQajp2SQoPFwt1rF/S/QMc+JCAEt5+GK5t6MSD29LKyZJw==;EndpointSuffix=core.windows.net"
CONTAINER_NAME="imagevalidations"
ACCOUNT_NAME="pbasnalimagestore"
TABLE_NAME="imagevalidationstatus"


python create_image_entries.py \
    -c  $AZURE_STORAGE_CONNECTION_STRING \
    -n $CONTAINER_NAME \
    -t $TABLE_NAME \
    -i $IMAGE_NAME \
    -e $CURRENT_EPOCH \
    --validation-time $VALIDATION_TIME \
    --validation-result $VALIDATION_RESULT