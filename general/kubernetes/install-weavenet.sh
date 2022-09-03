#!/bin/bash

echo ""
echo "Downloading Weavenet Manifest file"
wget "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" -O weave.yaml

echo ""
echo "Applying manifest file"
kubectl apply -f weave.yaml