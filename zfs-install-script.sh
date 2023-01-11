#! /bin/bash
echo "_____  ___                ___                            __    ____  _____ "
echo "|    |/ _|____    _______/  |_  ____   ____             |  | _/_   \   _  \ "
echo "|      < \__  \  /  ___/\   __\/ __ \ /    \    ______  |  |/ /|   /  /_\  \ "
echo "|    |  \ / __ \_\___ \  |  | \  ___/|   |  \  /_____/  |    < |   \  \_/   \ "
echo "|____|__ (____  /____  > |__|  \___  >___|  /           |__|_ \|___|\_____  / "
echo "        \/    \/     \/            \/     \/                 \/           \/ "
echo "Welcome to the script runner!"
echo ""
echo "This will install a single node k3s cluster with zfs-csi driver, zfs storageclass and k10 annotated volumesnapshotclass"
echo "It will then install k10 via HELM and automatically expose the k10 dashboard on the cluster load balancer"

echo "Enter drive path of extra volume (ie /dev/sdb). If you do not know this exit this script by cmd-x and run "fdisk -l" to find the drive path: "
read DRIVE < /dev/tty
pro config set apt_news=false
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
ip=$(curl -s ifconfig.io)
port=$(kubectl get svc -n kasten-io |grep k10-dashboard | cut -d':' -f2- | cut -f1 -d'/' )
echo ""
echo "K10 dashboard can be accessed on" $ip":"$port
