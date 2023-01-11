#! /bin/bash
DRIVE=/dev/nvme1p1

apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable local-storage" sh -s -
apt install zfsutils-linux -y
zpool create kasten-pool $DRIVE
kubectl apply -f https://openebs.github.io/charts/zfs-operator.yaml
kubectl apply -f https://github.com/jdtate101/jdtate101/blob/main/zfs-sc.yaml
kubectl apply -f https://github.com/jdtate101/jdtate101/blob/main/zfs-snapclass.yaml
kubectl patch storageclass kasten-zfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x ./get_helm.sh
./get_helm.sh
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
helm repo add kasten https://charts.kasten.io
kubectl create ns kasten-io
helm install k10 kasten/k10 --namespace kasten-io
sleep 60
pod=$(kubectl get po -n kasten-io |grep gateway | awk '{print $1}' )
kubectl expose po $pod -n kasten-io --type=LoadBalancer --port=8000 --name=k10-dashboard
