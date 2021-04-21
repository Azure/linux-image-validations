## Executes the Azure Table Storage CleanUp script
## with correct parameters and configurations

. ./configurations/set-env-configs.sh
python cleanup-azure-table.py \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -t $TABLE_NAME \
    -in "files/allimages" 