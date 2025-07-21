#!/bin/bash
set -euo pipefail

echo "🔧 Setting up logging stack..."

# Create logging namespace
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

# Add Elastic Helm repository
helm repo add elastic https://helm.elastic.co
helm repo update

# Install Elasticsearch
helm upgrade --install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --set replicas=1 \
  --set minimumMasterNodes=1 \
  --set volumeClaimTemplate.resources.requests.storage=1Gi \
  --wait

# Install Kibana
helm upgrade --install kibana elastic/kibana \
  --namespace logging \
  --set service.type=NodePort \
  --set service.nodePort=32002 \
  --wait

# Install Fluent Bit for log collection
helm repo add fluent https://fluent.github.io/helm-charts
helm upgrade --install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --set config.outputs="[OUTPUT]\n    Name es\n    Match *\n    Host elasticsearch-master\n    Port 9200\n    Index fluent-bit" \
  --wait

echo "✅ Logging stack installed!"
echo "🔗 Access Kibana at: http://localhost:32002"
