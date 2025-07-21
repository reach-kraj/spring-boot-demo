#!/bin/bash
set -euo pipefail

echo "🔧 Setting up monitoring stack with ingress..."

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack with ingress enabled
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.hosts[0]=grafana.local \
  --set grafana.ingress.className=nginx \
  --set prometheus.ingress.enabled=true \
  --set prometheus.ingress.hosts[0]=prometheus.local \
  --set prometheus.ingress.className=nginx \
  --set grafana.persistence.enabled=false \
  --wait

echo "✅ Monitoring stack installed with ingress!"

# Import custom dashboard
if [ -f "monitoring/grafana-dashboard.json" ]; then
  echo "📊 Importing custom Grafana dashboard..."
  kubectl create configmap grafana-dashboard \
    --from-file=monitoring/grafana-dashboard.json \
    -n monitoring \
    --dry-run=client -o yaml | kubectl apply -f -
fi
