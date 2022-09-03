#!/bin/bash

echo $'\nInstalling dontainerd' 

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo $'\nApplying sysctl changes'
sysctl --system

echo $'\nUpdating Repository database'
apt update

echo $'\nInstalling containerd'
apt install -y containerd

echo $'\nCreating /etc/containerd'
mkdir -p /etc/containerd

echo $'\nGenerating containerd default files'
containerd config default | sudo tee /etc/containerd/config.toml

echo $'\nRestarting containerd service'
sudo systemctl restart containerd
