#!/bin/bash
echo "Enter version you want to export (format 5.0.5): "
read VERSION < /dev/tty
# Define the target directory for individual zip files
EXPORT_DIR="image_exports"

# Create the export directory if it doesn't exist
mkdir -p "$EXPORT_DIR"
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock gcr.io/kasten-images/k10offline:$VERSION pull images
# List images that contain "kasten" in their repository name
IMAGES=$(docker images | grep "$VERSION" | awk '{print $1":"$2}')

# Loop through the list of images, export each as a separate zip file, and collect the filenames
zip_files=()
for image in ${IMAGES[@]}; do
    image_name=$(echo "$image" | cut -d'/' -f3-)
    zip_file="${EXPORT_DIR}/${image_name//:/_}.zip"
    docker save -o "$zip_file" "$image"
    zip_files+=("$zip_file")
done
tgz_files=("$EXPORT_DIR"/*.tgz)
# Create a single rolled-up zip file containing all individual zip files
final_zip="kasten_images_$VERSION.zip"
zip -j "$final_zip" "${zip_files[@]}"

# Clean up individual zip files
rm -rf "$EXPORT_DIR"

echo "Images exported as individual zip files and rolled up into '$final_zip'"
echo "Cleaning up images....."
for image in ${IMAGES[@]}; do
    docker rmi -f "$image"
