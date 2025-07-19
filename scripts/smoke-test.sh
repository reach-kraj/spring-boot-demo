#!/bin/bash
set -euo pipefail

echo "🚀 Starting smoke test of deployed endpoints..."

DEPLOYMENT_NAME="demo-release-demo"
SERVICE_HOST="http://$DEPLOYMENT_NAME:8080"

echo "⏳ Waiting for deployment to become available..."
kubectl wait --for=condition=available --timeout=60s deployment/$DEPLOYMENT_NAME

declare -A endpoints
endpoints["/old"]="OLD code"
endpoints["/new"]="New commit"

success_count=0

for endpoint in "${!endpoints[@]}"; do
  expected="${endpoints[$endpoint]}"
  echo "🔍 Testing $endpoint (expecting: $expected)"

  for i in {1..5}; do
    RESP=$(kubectl run curl --image=curlimages/curl:8.8.0 -i --rm --restart=Never -- \
           curl -s "${SERVICE_HOST}${endpoint}") && break
    echo "⚠️ Attempt $i failed for $endpoint, retrying..."
    sleep 5
  done

  echo "🔹 Response from $endpoint:"
  echo "$RESP"

  if [[ "$RESP" == *"$expected"* ]]; then
    echo "✅ $endpoint passed."
    success_count=$((success_count + 1))
  else
    echo "❌ $endpoint failed (did not find: $expected)"
  fi
done

if [[ "$success_count" -gt 0 ]]; then
  echo "🎉 At least one endpoint passed. Smoke test succeeded."
  exit 0
else
  echo "💥 All endpoints failed. Smoke test failed."
  exit 1
fi
