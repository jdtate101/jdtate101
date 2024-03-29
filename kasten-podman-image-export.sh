#!/bin/bash
echo "This script will download the requested k10 version images as zip files, unify them into a split zip file and download the offline helm chart."
echo "It assumes you have podman installed and also HELM, if you don't, please cntl-x and install those components.."
echo "Enter kasten k10 version you want to export (format 5.0.5): "
read VERSION < /dev/tty
# Define the target directory for individual zip files
EXPORT_DIR="image_exports"

# Create the export directory if it doesn't exist
mkdir -p "$EXPORT_DIR"
export PODMAN_SYSTEMD_CGROUP=true
podman pull gcr.io/kasten-images/k10offline:$VERSION
IMAGES=$(podman run --rm -it gcr.io/kasten-images/k10offline:$VERSION list-images | tr -d '\r')
for i in $IMAGES
do
    podman pull $i
done

# Loop through the list of images, export each as a separate zip file, and collect the filenames
zip_files=()
for image in ${IMAGES[@]}; do
    image_name=$(echo "$image" | cut -d'/' -f3-)
    zip_file="${EXPORT_DIR}/${image_name//:/_}.zip"
    podman save -o "$zip_file" "$image"
    zip_files+=("$zip_file")
done

# Create a single rolled-up zip file containing all individual zip files
final_zip="kasten_images_$VERSION.zip"
zip -s=2G -j "$final_zip" "${zip_files[@]}"

# Clean up individual zip files
rm -rf "$EXPORT_DIR"

echo "Images exported as individual zip files and rolled up into '$final_zip'"
echo "Cleaning up images in local docker registry....."
for image in ${IMAGES[@]}; do
    podman rmi -f "$image"
done
helm repo add kasten https://charts.kasten.io/
helm repo update
helm fetch kasten/k10 --version=$VERSION
