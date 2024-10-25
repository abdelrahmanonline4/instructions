#!/bin/bash

# Update and install necessary dependencies
sudo apt update && sudo apt install -y curl git

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "Error: kubectl is not installed. Please install Kubernetes manually."
    exit 1
else
    echo "kubectl is already installed"
fi

# Check if Kubernetes is running
if ! kubectl cluster-info &> /dev/null
then
    echo "Error: Kubernetes is not running. Please ensure your Kubernetes cluster is up and running."
    exit 1
else
    echo "Kubernetes is running"
fi

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "Waiting for Argo CD components to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment --all -n argocd

# Expose the Argo CD server using a NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Retrieve the Argo CD server NodePort
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
echo "Argo CD is available at http://localhost:${ARGOCD_PORT}"

# Retrieve the initial admin password
echo "Retrieving initial admin password..."
ARGOCD_PASSWORD=$(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
echo "Argo CD admin password: ${ARGOCD_PASSWORD}"

echo "Argo CD installation is complete. You can access the Argo CD UI at http://localhost:${ARGOCD_PORT}"
