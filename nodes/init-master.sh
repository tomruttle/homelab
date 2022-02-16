# on master
kubeadm init --config=/tmp/config.yml --upload-certs

# on backup
kubeadm join ...

# on machine
kubectl taint nodes --all node-role.kubernetes.io/master-

# install cni
helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --version 1.11.1 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=192.168.11.100 \
    --set k8sServicePort=6443 \
    --set bgp.enabled=true \
    --set bgp.announce.loadbalancerIP=true
    # --set hubble.relay.enabled=true \
    # --set hubble.ui.enabled=true

# add non-admin user
openssl genrsa -out tom.key 4096
openssl req -new -key tom.key -out tom.csr
cat tom.csr | base64 | tr -d '\n'

# add {{ base64_encoded_csr }} to tom-csr.yml

kubectl apply -f nodes/manifests/tom-csr.yml
kubectl certificate approve tom
kubectl get csr tom -o jsonpath='{.status.certificate}'| base64 -d > tom.crt

kubectl apply -f nodes/manifests/tom-crb.yml

kubectl config set-credentials tom --client-key=tom.key --client-certificate=tom.crt --embed-certs=true
kubectl config set-context tom --cluster=kubernetes --user=tom

# kubeadm kubeconfig user ...

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
