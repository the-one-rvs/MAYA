#!/bin/bash

if ! command -v kind &> /dev/null; then
    echo "kind is not installed. Installing kind..."
    
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    
    echo "kind has been installed successfully."
else
    echo "kind is already installed."
fi

if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Installing kubectl..."
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    
    echo "kubectl has been installed successfully."
else
    echo "kubectl is already installed."
fi

if ! command -v kubelet &> /dev/null; then
    echo "kubelet is not installed. Installing kubelet..."
    
    sudo apt-get update
    sudo apt-get install -y kubelet
    
    echo "kubelet has been installed successfully."
else
    echo "kubelet is already installed."
fi

kind create cluster --name maya-cluster --config kind-config.yaml

echo "kind cluster 'maya-cluster' has been created successfully."


