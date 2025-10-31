#!/usr/bin/env bash
set -euo pipefail

# Delete kind cluster
CLUSTER_NAME="${KIND_CLUSTER_NAME:-k8s-runbook}"

echo "Checking if cluster '${CLUSTER_NAME}' exists..."
if ! kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "ℹ️  Cluster '${CLUSTER_NAME}' does not exist"
  exit 0
fi

echo "⚠️  Deleting cluster '${CLUSTER_NAME}'..."
kind delete cluster --name "${CLUSTER_NAME}"
echo "✅ Cluster '${CLUSTER_NAME}' deleted successfully"
