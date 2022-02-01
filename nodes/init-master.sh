#!/bin/bash

KUBE_TOKEN=$(kubeadm token generate)

kubeadm init --config ./kubeadm-config-init.yaml \
  --token $KUBE_TOKEN \
  --pod-network-cidr 10.244.0.0/16 \
  --apiserver-advertise-address=192.168.11.141

# Get joining hash:
# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --version 1.11.0 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=192.168.11.141 \
    --set k8sServicePort=6443 \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true

# add non-admin user
# kubeadm kubeconfig user ...

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
