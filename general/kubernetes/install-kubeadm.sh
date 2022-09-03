#!/bin/bash

echo "NOTE: This will install the latest available versions for kubeadm, kubectl, and kubelet."
echo "Installing required packages"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl

echo ""
echo "Downloading Google Cloud public signing key"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo ""
echo "Adding Kubernetes Repository"
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo ""
echo "Installing kubelet kubeadm kubectl"
echo "kubeadm - used to initialise the cluster"
echo "kubectl - used to talk to the cluster"
echo "kubelet - used to start pods and containers"
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

echo ""
echo "Marking kubelet kubeadm kubectl to not update"
sudo apt-mark hold kubelet kubeadm kubectl