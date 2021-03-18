#az vm image list --all --publisher redhat | grep urn | cut -d'"' -f4 | grep ':rhel' | grep -v ":6" >> allimages.tmp

. ./configurations/set-env-configs.sh
python cleanup-azure-table.py \
    -c $AZURE_STORAGE_CONNECTION_STRING \
    -t $TABLE_NAME \
    -in "allimages.tmp" 