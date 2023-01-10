#! /bin/bash
DRIVE=/dev/nvme1p1

apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y
curl -sfL https://get.k3s.io | sh -
apt install zfsutils-linux
zpool create kasten-pool $DRIVE
kubectl apply -f https://openebs.github.io/charts/zfs-operator.yaml
kubectl apply -f zfs-sc.yaml
kubectl apply -f zfs-snapclass.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass kasten-zfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x ./get_helm.sh
./get_helm.sh
helm repo add kasten https://charts.kasten.io
kubectl create ns kasten-io
helm install k10 kasten/k10 --namespace kasten-io
