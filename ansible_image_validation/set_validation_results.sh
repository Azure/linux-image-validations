IMAGE_NAME=$1
CURRENT_EPOCH=$2
VALIDATION_TIME=$3

echo "epoch " $CURRENT_EPOCH
echo "time " $VALIDATION_TIME

## Set configurations
. ./configurations/set-env-configs.sh

VALIDATION_RESULT="Success"
files=$(find ./validation_results/$IMAGE_NAME -maxdepth 5 -type f | grep "/err/")
for filename in $files; do
    # check if file has some output
    if [ -s $(echo $filename) ]; then
        VALIDATION_RESULT="Failed"
        echo "failed - $filename"
        break
    fi
done

python azure-table-data.py \
    -m "insert-data" \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -n $CONTAINER_NAME \
    -t $TABLE_NAME \
    -i $IMAGE_NAME \
    -e $CURRENT_EPOCH \
    --validation-time "$VALIDATION_TIME" \
    --validation-result $VALIDATION_RESULT \
    --err-msg-file "./validation_results/$IMAGE_NAME/tmp/err/err_msgs.log"

python azure-table-data.py \
    -m "generate-report" \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -n $CONTAINER_NAME \
    -t $TABLE_NAME \
    -i $IMAGE_NAME \
    -e $CURRENT_EPOCH \
    --validation-time "$VALIDATION_TIME" \
    --validation-result $VALIDATION_RESULT \
    --err-msg-file "./validation_results/$IMAGE_NAME/tmp/err/err_msgs.log"