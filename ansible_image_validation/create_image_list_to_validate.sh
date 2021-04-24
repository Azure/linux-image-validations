az vm image list --all --publisher redhat | grep urn | cut -d'"' -f4 | grep -i ':rhel' | grep -v ":6" | grep -v "byos" | grep -v "sig"> files/allimages
