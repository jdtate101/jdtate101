#!/bin/bash
#script to get the commands for pull, re-tag and push K10 images to the private repo
# COLOR CONSTANTS
GREEN='\033[0;32m'
RED='\033[1;31m'
LIGHT_BLUE='\033[1;34m'
BOLD='\033[1m'
NC='\033[0m'

set -euo pipefail

#requirements
#podman or docker


#helpFunction with the usage details
helpFunction()
{
   # Display Help
   echo -e $LIGHT_BLUE "USAGE." $NC
   echo -e $RED "Use the below options to input the target image registry and K10 version details"
   echo -e "   Syntax: ./imagePush.sh [-t|v|h]" $NC
   echo -e "   options:"
   echo -e "   -t     Target image registry to which the images needs to be pushed."
   echo -e "   -v     K10 version."
   echo -e "   -c     Client used to push/pull images - Supported arguments are docker & podman(defaults to podman"
   echo -e "   -h     Print this Help."
   exit 1
}

#default client to use podman if the option is not provided while running the script
CLIENT=podman

while getopts "t:v:h:c:" opt
do
   case "$opt" in
      t ) TARGET_REGISTRY="$OPTARG" ;;
      v ) K10_VERSION="$OPTARG" ;;
      c ) CLIENT="$OPTARG" ;;
      h ) helpFunction ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [[ -z ${TARGET_REGISTRY} || -z ${K10_VERSION} ]]
then
    helpFunction
fi

IMAGES=$(${CLIENT} run --rm -it gcr.io/kasten-images/k10offline:${K10_VERSION} list-images | tr -d '\r')

echo
echo -e $GREEN $BOLD =====Commands to pull the images locally=============== $NC
echo

for i in ${IMAGES}
do
    #configmap-reloader image from the k10offline tool is without the prefix `docker.io` and errors if docker.io is not listed as unqualified search registry. Hack to add docker.io to the configmap-reloaded image
    if [[ ${i} == jimmidyson* ]]
    then
        echo ${CLIENT} pull docker.io\/$i
    else
        echo ${CLIENT} pull $i
    fi
done

echo
echo -e $GREEN $BOLD =====Commands to re-tag the images with your image registry =============== $NC
echo

for j in ${IMAGES}
do
    TAG=$(echo $j | cut -f 2 -d ':')
    K10TAG=k10-${TAG}
    IMAGENAMEWITHOUTTAG=$(echo $j | awk -F '/' '{print $NF}'|cut -f 1 -d ':')
    #configmap-reloader image from the k10offline tool is without the prefix `docker.io` and errors if docker.io is not listed as unqualified search registry. Hack to add docker.io to the configmap-reloaded image
    if [[ $j = jimmidyson* ]]
    then
        echo "${CLIENT} tag docker.io/${j} ${TARGET_REGISTRY}/${IMAGENAMEWITHOUTTAG}:${K10TAG}"
    elif [[ $j = gcr.* ]]
    then
        echo "${CLIENT} tag ${j} ${TARGET_REGISTRY}/${IMAGENAMEWITHOUTTAG}:${TAG}"
    else
        echo "${CLIENT} tag ${j} ${TARGET_REGISTRY}/${IMAGENAMEWITHOUTTAG}:${K10TAG}"
    fi
done

echo
echo -e $GREEN $BOLD =====Commands to push the images to your image registry =============== $NC
echo

for j in ${IMAGES}
do
    TAG=$(echo $j | cut -f 2 -d ':')
    K10TAG=k10-${TAG}
    IMAGENAMEWITHOUTTAG=$(echo $j | awk -F '/' '{print $NF}'|cut -f 1 -d ':')
    if [[ $j = gcr.* ]]
    then
        echo ${CLIENT} push ${TARGET_REGISTRY}/${IMAGENAMEWITHOUTTAG}:${TAG}
    else
        echo ${CLIENT} push ${TARGET_REGISTRY}/${IMAGENAMEWITHOUTTAG}:${K10TAG}
    fi
done

exit 0
