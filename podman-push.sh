#!/bin/bash
echo "This script will download the requested k10 version images as zip files, unify them into a split zip file and download the offline helm chart."
echo "It assumes you have podman installed and also HELM, if you don't, please cntl-x and install those components.."
echo "Enter kasten k10 version you want to export (format 5.0.5): "
read VERSION < /dev/tty
echo "Enter FQDN of private registry: "
read REG < /dev/tty
# Create the export directory if it doesn't exist
podman pull gcr.io/kasten-images/k10offline:$VERSION
PULL=$(podman run --rm -it gcr.io/kasten-images/k10offline:$VERSION list-images | tr -d '\r')
for i in $PULL
do
    podman pull $i
done

images=$(podman images |grep 6.5.4 | sed 's/gcr.io//' | cut -c2- | awk '{ print $3,$1,$2 }' | sed 's/ 6.5.4/:6.5.4/' |sed s"|kasten-images|$REG/kasten-images|g")
# Loop through the list of images, export each as a separate zip file, and collect the filenames
IFS=$'\n' read -rd '' -a array <<< "$images"

for image in "${array[@]}"; do
    podman push --tls-verify=false $image
done
