sudo apt install linux-generic-hwe-20.04

docker run --network host --rm ghcr.io/kube-vip/kube-vip:$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name") manifest pod \
    --interface enx00e04c0814ec \
    --address 192.168.11.100 \
    --controlplane \
    --arp \
    --leaderElection | tee nodes/manifests/kube-vip.yaml

scp nodes/manifests/kube-vip.yml katana:/tmp/kube-vip.yml
scp nodes/kubeadm-config-init.yml katana:/tmp/config.yml

sudo mv /tmp/kube-vip.yml /etc/kubernetes/manifests/
sudo kubeadm init --config=/tmp/config.yml --upload-certs

# add non-admin user

openssl genrsa -out tom.key 4096
openssl req -new -key tom.key -out tom.csr

# REMEMBER TO SET COMMON NAME = tom HERE!!!

cat tom.csr | base64 | tr -d '\n'

# add {{ base64_encoded_csr }} to tom-csr.yml

kubectl apply -f nodes/manifests/tom-csr.yml
kubectl certificate approve tom
kubectl get csr tom -o jsonpath='{.status.certificate}'| base64 -d > tom.crt

kubectl apply -f nodes/manifests/tom-crb.yml

kubectl config set-credentials tom --client-key=tom.key --client-certificate=tom.crt --embed-certs=true
kubectl config set-context tom --cluster=kubernetes --user=tom
kubectl config use-context tom

kubectl taint nodes --all node-role.kubernetes.io/master-

# install cni

# helm repo add cilium https://helm.cilium.io/

# helm install cilium cilium/cilium --version 1.11.1 \
#     --namespace kube-system \
#     --set tunnel=disabled \
#     --set autoDirectNodeRoutes=true \
#     --set hostServices.hostNamespaceOnly=true \
#     --set kubeProxyReplacement=strict \
#     --set loadBalancer.mode=hybrid \
#     --set kubeProxyReplacement=strict \
#     --set k8sServiceHost=192.168.11.100 \
#     --set k8sServicePort=6443 \
#     --set bgp.enabled=true \
#     --set bgp.announce.loadbalancerIP=true \
#     --set hubble.relay.enabled=true \
#     --set hubble.ui.enabled=true

kubectl apply -f nodes/manifests/bgp-config.yml

brew install cilium-cli

# on each node, ensure to `rm /sys/fs/bpf/tc/globals/*` before trying to install cilium

cilium install --version -service-mesh:v1.11.0-beta.1 \
    --kube-proxy-replacement=strict \
    --ipv4-native-routing-cidr=10.0.0.0/9 \
    --config tunnel=disabled \
    --config auto-direct-node-routes=true \
    --config bpf-lb-sock-hostns-only=true \
    --config node-port-mode=hybrid \
    --config enable-envoy-config=true \
    --config bgp-announce-lb-ip=true \
    --config k8s-api-server=https://192.168.11.100:6443 \
    --config debug=true

cilium hubble enable --ui

# install gitops
brew install fluxcd/tap/flux

GITHUB_TOKEN=${GITHUB_TOKEN} flux bootstrap github \
  --server=https://192.168.11.100:6443 \
  --repository=homelab \
  --owner=${GITHUB_USER} \
  --path=cluster \
  --personal \
  --branch=master

# kubeadm kubeconfig user ...

brew install octant

apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
type: Opaque
stringData:
  api-token:

# https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/#api-tokens
kubectl create secret generic cloudflare-api-token-secret \
  --namespace=cert-manager
  --from-literal=api-token=${CLOUDFLARE_TOKEN}