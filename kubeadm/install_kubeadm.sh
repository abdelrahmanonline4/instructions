#!/bin/bash

# Enable logging
exec > >(tee -i /var/log/install.log)
exec 2>&1

# Disable swap
echo "Disabling swap..."
sudo swapoff -a
if [ $? -ne 0 ]; then
    echo "Failed to disable swap. Exiting."
    exit 1
fi

sudo sed -i '/ swap / s/^/#/' /etc/fstab
if [ $? -ne 0 ]; then
    echo "Failed to update /etc/fstab. Exiting."
    exit 1
fi

# Install Docker
echo "Installing Docker..."
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Failed to update package lists. Exiting."
    exit 1
fi

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
if [ $? -ne 0 ]; then
    echo "Failed to install dependencies for Docker. Exiting."
    exit 1
fi

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
if [ $? -ne 0 ]; then
    echo "Failed to add Docker GPG key. Exiting."
    exit 1
fi

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
if [ $? -ne 0 ]; then
    echo "Failed to add Docker repository. Exiting."
    exit 1
fi

sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Failed to update package lists after adding Docker repository. Exiting."
    exit 1
fi

sudo apt-get install -y docker-ce docker-ce-cli containerd.io
if [ $? -ne 0 ]; then
    echo "Failed to install Docker. Exiting."
    exit 1
fi

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
if [ $? -ne 0 ]; then
    echo "Failed to enable Docker service. Exiting."
    exit 1
fi

sudo systemctl start docker
if [ $? -ne 0 ]; then
    echo "Failed to start Docker service. Exiting."
    exit 1
fi
product_uuid=$(sudo cat /sys/class/dmi/id/product_uuid)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo " The Output is:"
echo " UUID: $product_uuid\n"
echo " Hostname: $(hostname)"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

#sysctl params required by setup, params persist across reboots

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
lsmod | grep br_netfilter
lsmod | grep overlay
sudo sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
cd /tmp
wget https://github.com/containerd/containerd/releases/download/v1.7.20/containerd-1.7.20-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.20-linux-amd64.tar.gz
sudo wget -O /usr/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
wget https://github.com/opencontainers/runc/releases/download/v1.2.0-rc.2/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
wget https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.1.tgz
sudo su - 
if [ ! -d /etc/containerd ]; then
  sudo mkdir -p /etc/containerd
fi
sudo containerd config default > /etc/containerd/config.toml
exit
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's|sandbox_image = ".*"|sandbox_image = "k8s.gcr.io/pause:3.9"|' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

#install kubadm kubelet and kubectl and hold their versions to prevent the system from updating them.

sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

#Enable the kubelet service before running kubeadm:

sudo systemctl enable --now kubelet
sudo kubeadm config images pull

# dont forget install CNI Such as 
## kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
##curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml -O
#Create the manifest to install Calico.
##kubectl create -f custom-resources.yaml 
##Verify Calico installation in your cluster.
#watch kubectl get pods -n calico-system
#after this  in master use this  sudo kubeadm init --apiserver-advertise-address=<ip> --pod-network-cidr=192.168.0.0/16 
#and Joining your nodes

#SSH to the machine. Become root (e.g. sudo su -) 
#kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
