# Ansible AWX Installation on Ubuntu

This guide details the steps to install Ansible AWX with Docker and Minikube on an Ubuntu system.

## Prerequisites

Before you begin the installation, make sure your system meets the following specifications:
- **RAM**: 8 GB
- **CPU**: 3.4 GHz with 2 Cores
- **Hard Disk Space**: 20 GB
- **Internet Connection**: Required
- **Minikube**: Pre-installed on your system

## Installation Steps

### Step 1: Install Required Packages

First, log in to your Ubuntu system and install Git and Make:

```bash
sudo apt install git make -y
## Step 2: Install Docker and Minikube
## Update your package list and install Docker:

sudo apt update
sudo apt install curl
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-registry
sudo usermod -aG docker $USER
newgrp docker
```
## Install Minikube:
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
minikube start --vm-driver=docker --addons=ingress
sudo snap install kubectl --classic
```
## Step 3: Deploy Ansible AWX via Operator
```
git clone https://github.com/ansible/awx-operator.git
cd awx-operator/
git checkout 2.19.0
export NAMESPACE=ansible-awx
make deploy
kubectl get pods -n ansible-awx
```

 ## Create a new AWX instance:

```

cp awx-demo.yml awx-ubuntu.yml
vi awx-ubuntu.yml
```
---
![image](https://github.com/user-attachments/assets/8dfe0a4a-0b03-40bd-885b-a018befb2267)


Step 4: Access AWX Dashboard
```
minikube service awx-ubuntu-service --url -n ansible-awx
kubectl port-forward --address 0.0.0.0 svc/awx-ubuntu-service 8080:80 -n ansible-awx
```
Retrieve Admin Password
Use the following commands to get the admin password:

```
kubectl get secret -n ansible-awx | grep -i password
kubectl get secret awx-ubuntu-admin-password -o jsonpath="{.data.password}" -n ansible-awx | base64 --decode; echo
```

![image](https://github.com/user-attachments/assets/c84287a8-498d-4c6a-994c-debb98b32446)
