#!/bin/bash
set -euo pipefail

echo "📊 Generating monitoring reports..."

# Create reports directory
mkdir -p reports

# Wait for Grafana to be ready
kubectl wait --for=condition=available --timeout=60s deployment/monitoring-grafana -n monitoring

# Port forward to access Grafana API
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 &
GRAFANA_PID=$!
sleep 10

# Set up Grafana API access
GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASS="admin123"

# Create API key
API_KEY=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"ci-key","role":"Admin"}' \
  "http://${GRAFANA_USER}:${GRAFANA_PASS}@localhost:3000/api/auth/keys" | \
  jq -r '.key' 2>/dev/null || echo "")

if [ -n "$API_KEY" ]; then
  echo "✅ Generated Grafana API key"

  # Export dashboard as JSON
  curl -s -H "Authorization: Bearer $API_KEY" \
    "$GRAFANA_URL/api/search?query=Spring" | \
    jq -r '.[0].uid' | \
    xargs -I {} curl -s -H "Authorization: Bearer $API_KEY" \
    "$GRAFANA_URL/api/dashboards/uid/{}" > reports/dashboard-export.json

  echo "📄 Dashboard exported to reports/dashboard-export.json"
else
  echo "⚠️ Could not generate API key, using alternative method"
fi

# Kill port-forward
kill $GRAFANA_PID 2>/dev/null || true

# Generate metrics snapshot
kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:9090 &
PROM_PID=$!
sleep 5

# Query Prometheus for key metrics
echo "📈 Collecting metrics snapshot..."
curl -s "http://localhost:9090/api/v1/query?query=up" > reports/prometheus-up-metrics.json
curl -s "http://localhost:9090/api/v1/query?query=rate(endpoint_requests_total[5m])" > reports/prometheus-request-rate.json

kill $PROM_PID 2>/dev/null || true

echo "✅ Reports generated in reports/ directory"
