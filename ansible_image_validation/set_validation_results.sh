IMAGE_NAME=$1
CURRENT_EPOCH=$2
VALIDATION_TIME=$3

## Set configurations
. ./configurations/set-env-configs.sh

VALIDATION_RESULT="Success"
files=$(find ./validation_results -maxdepth 5 -type f | grep "/err/")
for filename in $files; do
    # not empty
    if [ -s $filename ]; then
        VALIDATION_RESULT="Failed"
        break
    fi
done

python azure-table-data.py \
    -m "insert_data" \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -n $CONTAINER_NAME \
    -t $TABLE_NAME \
    -i $IMAGE_NAME \
    -e $CURRENT_EPOCH \
    --validation-time $VALIDATION_TIME \
    --validation-result $VALIDATION_RESULT