#! /bin/bash
R='\033[0;31m'      #'0;31' is Red's ANSI color code
G='\033[0;32m'     #'0;32' is Green's ANSI color code
W='\033[1;37m'     #'1;37' is White's ANSI color code
# the following command will set the ubuntu service restart under apt to automatic
sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

echo -e "$R ____  ___                ___                            __    ____  _____ "
echo -e "$R|    |/ _|____    _______/  |_  ____   ____             |  | _/_   \   _  \ "
echo -e "$R|      < \__  \  /  ___/\   __\/ __ \ /    \    ______  |  |/ /|   /  /_\  \ "
echo -e "$R|    |  \ / __ \_\___ \  |  | \  ___/|   |  \  /_____/  |    < |   \  \_/   \ "
echo -e "$R|____|__ (____  /____  > |__|  \___  >___|  /           |__|_ \|___|\_____  / "
echo -e "$R        \/    \/     \/            \/     \/                 \/           \/ "
echo -e "$G Simple K10 node installer.....!"
echo ""
echo -e "$G This will install a single node k3s cluster with zfs-csi driver, zfs storageclass and k10 annotated volumesnapshotclass"
echo -e "$G It will then install k10 via HELM and automatically expose the k10 dashboard on the cluster load balancer"
echo ""
echo -e "$G Enter drive path of extra volume (ie /dev/sdb). If you do not know this exit this script by cmd-x and run "fdisk -l" to find the drive path: "
echo -e "$W "
read DRIVE < /dev/tty
sleep 5
echo ""
echo -e "$G Patching Ubuntu"
echo ""
sleep 5
echo -e "$W " 
pro config set apt_news=false
apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y
sleep 5
echo -e "$G Installing k3s single node cluster"
echo -e "$W "
sleep 5
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable local-storage" sh -s -
sleep 5
echo ""
echo -e "$G Installing ZFS and configuring pool"
echo -e "$W "
sleep 5
apt install zfsutils-linux -y
zpool create kasten-pool $DRIVE
sleep 5
echo ""
echo -e "$G Installing ZFS Operator, StorageClass & VolumeSnapshotClass"
echo -e "$W "
sleep 5
kubectl apply -f https://openebs.github.io/charts/zfs-operator.yaml
curl -s https://raw.githubusercontent.com/jdtate101/jdtate101/main/zfs-sc2.yaml > zfs-sc2.yaml
curl -s https://raw.githubusercontent.com/jdtate101/jdtate101/main/zfs-snapclass.yaml > zfs-snapclass.yaml
kubectl apply -f zfs-sc2.yaml
kubectl apply -f zfs-snapclass.yaml
kubectl patch storageclass kasten-zfs-destination -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sleep 5
echo ""
echo -e "$G Installing Helm"
echo -e "$W "
sleep 5
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x ./get_helm.sh
./get_helm.sh
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
helm repo add kasten https://charts.kasten.io
sleep 5
echo ""
echo -e "$G Installing Kasten K10"
echo -e "$W "
sleep 5
kubectl create ns kasten-io
helm install k10 kasten/k10 --namespace kasten-io --version=5.5.4
echo ""
echo -e "$R Please wait for 60sec whilst we wait for the pods to spin up..."
echo -e "$R After this period the external URL for K10 access will display (DO NOT exit this script)"
sleep 60
echo -e "$W "
pod=$(kubectl get po -n kasten-io |grep gateway | awk '{print $1}' )
kubectl expose po $pod -n kasten-io --type=LoadBalancer --port=8000 --name=k10-dashboard
ip=$(curl -s ifconfig.io)
port=$(kubectl get svc -n kasten-io |grep k10-dashboard | cut -d':' -f2- | cut -f1 -d'/' )
echo ""
echo -e "$G K10 dashboard can be accessed on http://"$ip":"$port"/k10/#/"
echo -e "$W "
echo -e "$R It may take a while for all pods to become active. You can check with $G < kubectl get po -n kasten-io > $R wait for the gateway pod to go 1/1 before you go to the URL"
echo -e "$W "
exit 
