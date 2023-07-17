#! /bin/bash
echo "Starting setup of Kubevirt environment.."
sleep 1
export VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml
(   set -x; cd "$(mktemp -d)" &&   curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz" &&   tar zxvf krew-linux_amd64.tar.gz &&   KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&   "$KREW" install krew; )
export PATH="${PATH}:${HOME}/.krew/bin"
echo "export PATH="${PATH}:${HOME}/.krew/bin"" >> /root/.bashrc
kubectl krew install virt
export CDIVERSION=v0.41.0
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDIVERSION/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDIVERSION/cdi-cr.yaml
echo ""
ctr image pull docker.io/kubevirt/virtio-container-disk:latest -k
echo -e "$G"
echo "Finished, installing Kubevirt Manager....."
echo -e "$W"
kubectl apply -f https://raw.githubusercontent.com/kubevirt-manager/kubevirt-manager/main/kubernetes/bundled.yaml
echo ""
exit 
