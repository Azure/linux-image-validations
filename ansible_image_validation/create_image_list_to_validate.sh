## This script gets all the RedHat images published to marketplace and adds them to the
## allimages file. These are the images which will eventually get validated
az vm image list --all --publisher redhat | grep urn | cut -d'"' -f4 | grep ':rhel' | grep -v ":6" | grep -v "byos" > files/allimages
