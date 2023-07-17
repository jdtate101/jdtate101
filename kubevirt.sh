#! /bin/bash
echo "Starting setup of Kubevirt environment.."
echo ""
sleep 1
export VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml
echo ""
echo "Installing Krew and virt plugin..."
echo ""
sleep 1
(  set -x; cd "$(mktemp -d)" &&  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&  KREW="krew-${OS}_${ARCH}" &&  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&  tar zxvf "${KREW}.tar.gz" &&  ./"${KREW}" install krew)
export PATH="${PATH}:${HOME}/.krew/bin"
echo "export PATH="${PATH}:${HOME}/.krew/bin"" >> /root/.bashrc
kubectl krew install virt
export CDIVERSION=$(curl -s https://api.github.com/repos/kubevirt/containerized-data-importer/releases | grep tag_name | grep -v -- '-rc' | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDIVERSION/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDIVERSION/cdi-cr.yaml
echo ""
echo "Installing Virtio Drivers.."
echo ""
sleep 1
ctr image pull docker.io/kubevirt/virtio-container-disk:latest -k
echo  ""
echo "Finished, installing Kubevirt Manager....."
echo ""
sleep 1
kubectl apply -f https://raw.githubusercontent.com/kubevirt-manager/kubevirt-manager/main/kubernetes/bundled.yaml
echo ""
sleep 1
echo "Install Virtctl..."
echo ""
(  set -x; cd "$(mktemp -d)" &&  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && VIRTCTL="virtctl-v${VERSION}-${OS}-${ARCH}" && wget "https://github.com/kubevirt/kubevirt/releases/download/v${VERSION}/${VIRTCTL}" && mv virtctl* /usr/local/bin/virtctl && chmod +x /usr/local/bin/virtctl )
echo ""
exit 
