#!/bin/bash
set -euo pipefail

echo "💾 Exporting monitoring data..."

mkdir -p monitoring-data

# Export Kubernetes resources
echo "📦 Exporting Kubernetes monitoring resources..."
kubectl get all -n monitoring -o yaml > monitoring-data/monitoring-resources.yaml
kubectl get configmaps -n monitoring -o yaml > monitoring-data/monitoring-configmaps.yaml
kubectl get secrets -n monitoring -o yaml > monitoring-data/monitoring-secrets.yaml

# Export application metrics
echo "📊 Exporting application metrics..."
kubectl port-forward svc/demo-release-demo 8080:8080 &
APP_PID=$!
sleep 5

curl -s http://localhost:8080/actuator/health > monitoring-data/app-health.json
curl -s http://localhost:8080/actuator/metrics > monitoring-data/app-metrics.json
curl -s http://localhost:8080/actuator/prometheus > monitoring-data/app-prometheus-metrics.txt

kill $APP_PID 2>/dev/null || true

# Export logs
echo "📝 Exporting application logs..."
kubectl logs deployment/demo-release-demo --tail=100 > monitoring-data/app-logs.txt

# Create summary report
cat > monitoring-data/summary.md << EOF
# Monitoring Summary Report

## Deployment Information
- Image: $IMAGE_NAME:$GITHUB_SHA
- Timestamp: $(date)
- Namespace: default

## Health Status
- Application Health: $(grep -o '"status":"[^"]*"' monitoring-data/app-health.json || echo "Unknown")

## Key Metrics
- Prometheus Metrics Endpoint: Available
- Actuator Endpoints: Available
- Container Status: $(kubectl get pods -l app=demo --no-headers | wc -l) pods running

## Access Instructions
To access monitoring in a real cluster:
\`\`\`bash
# Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:9090

# Application
kubectl port-forward svc/demo-release-demo 8080:8080
\`\`\`
EOF

echo "✅ Monitoring data exported to monitoring-data/ directory"
