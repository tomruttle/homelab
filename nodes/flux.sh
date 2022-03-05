flux create source git monitoring \
  --interval=30m \
  --url=https://github.com/fluxcd/flux2 \
  --branch=main

flux create kustomization monitoring-stack \
  --interval=1h \
  --prune=true \
  --source=monitoring \
  --path="./manifests/monitoring/kube-prometheus-stack" \
  --health-check="Deployment/kube-prometheus-stack-operator.monitoring" \
  --health-check="Deployment/kube-prometheus-stack-grafana.monitoring"

flux create kustomization monitoring-config \
  --interval=1h \
  --prune=true \
  --source=monitoring \
  --path="./manifests/monitoring/monitoring-config"