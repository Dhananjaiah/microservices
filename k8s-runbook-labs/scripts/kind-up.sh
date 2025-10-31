#!/usr/bin/env bash
set -euo pipefail

# Create a kind cluster (idempotent)
CLUSTER_NAME="${KIND_CLUSTER_NAME:-k8s-runbook}"

echo "Checking if cluster '${CLUSTER_NAME}' exists..."
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "✅ Cluster '${CLUSTER_NAME}' already exists"
  exit 0
fi

echo "Creating kind cluster '${CLUSTER_NAME}'..."
cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF

echo "✅ Cluster '${CLUSTER_NAME}' created successfully"
echo "⚙️  Switching kubectl context..."
kubectl cluster-info --context "kind-${CLUSTER_NAME}"
echo "✅ Ready to use!"
