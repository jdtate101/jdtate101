get_public_ip() {
    curl -s ifconfig.me
}
get_local_ip() {
    hostname -I | awk '{print $1}'
}
if [[ -n "$AWS_EXECUTION_ENV" || -n "$AWS_REGION" || -n "$AWS_DEFAULT_REGION" ]]; then
    echo "Running on AWS"
    # echo "Public IP: $(get_public_ip)"
    echo -e "$G K10 dashboard can be accessed on http://"$get_public_ip":"$port"/k10/#/"
elif [[ -n "$AZURE_REGIONNAME" || -n "$AZURE_WT_REGION" ]]; then
    echo "Running on Azure"
    # echo "Public IP: $(get_public_ip)"
    echo -e "$G K10 dashboard can be accessed on http://"$get_public_ip":"$port"/k10/#/"
elif [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
    echo "Running on Google Cloud"
    # echo "Public IP: $(get_public_ip)"
    echo -e "$G K10 dashboard can be accessed on http://"$get_public_ip":"$port"/k10/#/"
elif [[ -n "$OCI_REGION" ]]; then
    echo "Running on Oracle Cloud"
    # echo "Public IP: $(get_public_ip)"
    echo -e "$G K10 dashboard can be accessed on http://"$get_public_ip":"$port"/k10/#/"
elif [[ -n "$ALIBABA_CLOUD_REGION" ]]; then
    echo "Running on Alibaba Cloud"
    # echo "Public IP: $(get_public_ip)"
    echo -e "$G K10 dashboard can be accessed on http://"$get_public_ip":"$port"/k10/#/"
elif [[ -n "$IBM_CLOUD_REGION" ]]; then
    echo "Running on IBM Cloud"
    # echo "Public IP: $(get_public_ip)"
    echo -e "$G K10 dashboard can be accessed on http://"$get_public_ip":"$port"/k10/#/"
else
    # Check if running on a local VM
    dmidecode -s system-manufacturer | grep -qi "vmware\|virtualbox\|qemu\|kvm"
    if [[ $? -eq 0 ]]; then
        echo "Running on a local virtual machine"
        # echo "Public IP: $(get_public_ip)"
        echo -e "$G K10 dashboard can be accessed on http://"$get_local_ip":"$port"/k10/#/"
    else
        echo "Running on a local physical machine"
        # echo "Local IP: $(get_local_ip)"
        echo -e "$G K10 dashboard can be accessed on http://"$get_local_ip":"$port"/k10/#/"
    fi
fi
