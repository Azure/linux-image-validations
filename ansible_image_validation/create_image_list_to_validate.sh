az vm image list --all --publisher redhat | grep urn | cut -d'"' -f4 | grep ':rhel' | grep -v ":6" >> files/allimages
