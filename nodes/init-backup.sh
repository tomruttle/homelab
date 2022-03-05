# on master

# get token & discovery-token-ca-cert-hash
kubeadm token create --print-join-command

# get certificate-key
kubeadm init phase upload-certs --upload-certs

# on backup

sudo mv /tmp/kube-vip.yml /etc/kubernetes/manifests/kube-vip.yml

sudo kubeadm join --config /tmp/join.yml

kubectl taint nodes --all node-role.kubernetes.io/master-
