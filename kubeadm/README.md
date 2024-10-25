# Kubernetes Cluster Setup with kubeadm and Vagrant

This document provides a step-by-step guide for setting up a Kubernetes cluster using `kubeadm` and `Vagrant`

## Prerequisites
1. **[Vagrant](https://www.vagrantup.com/downloads)**: A tool for building and managing virtual machine environments.
2. **[VirtualBox](https://www.virtualbox.org/wiki/Downloads)**: A free and open-source hosted hypervisor.
3. **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)**: Kubernetes command-line tool.
4. **[kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)**: Tool to bootstrap Kubernetes clusters.
5. **[Vagrant Plugins](https://www.vagrantup.com/docs/cli/plugin)**: Ensure the `vagrant-vbguest` plugin is installed to manage VirtualBox guest additions.
6.  To install the required tools, follow the respective installation instructions provided in the links above.

## Setup Instructions
  **Clone this Repository**
    cd in repo 


    vagrant up

    vagrant ssh master
    
    sudo kubeadm init --apiserver-advertise-address=<ip> --pod-network-cidr=192.168.0.0/16 
  
  # Set up kubectl for the root user:
    mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config


# Join Worker Nodes

vagrant ssh worker1 

vagrant ssh worker2

sudo kubeadm join <master-ip>:<port> --token <token> --discovery-token-ca-cert-hash <hash>



kubectl get nodes


![WhatsApp Image 2024-09-17 at 13 22 26_d72e9163](https://github.com/user-attachments/assets/757971e4-6508-4110-8aca-8cccb78891be)


 # If there are any problems, use vagrant reload
