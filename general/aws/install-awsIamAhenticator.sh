#!/bin/bash

echo "Downloading AWS IAM Authenticator v0.5.9"
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64

echo "Updating execute permissions"
chmod +x ./aws-iam-authenticator

echo "Move binary to ~/bin and add to user PATH variable."
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc