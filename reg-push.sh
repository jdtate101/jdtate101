#!/bin/bash

# Define the target registry
echo "Enter version you want to pull (format 5.0.5): "
read VERSION < /dev/tty
TARGET_REGISTRY="registry.example.com"
IMAGES=$(docker images | grep "$VERSION" | awk '{print $1":"$2}')
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock gcr.io/kasten-images/k10offline:$VERSION pull images
# Loop through the list of images and push them to the target registry
for image in ${IMAGES[@]}; do
    target_image="${TARGET_REGISTRY}/kasten/$(echo $image | cut -d'/' -f3-)"  # Modify the image name for the target registry

    # Tag the image for the target registry
    docker tag "$image" "$target_image"

    # Push the image to the target registry
    docker push "$target_image"

    # Optionally, you can remove the source image from the local system
    docker rmi -f "$image"
done
