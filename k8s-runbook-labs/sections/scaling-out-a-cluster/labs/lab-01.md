# Scaling Out: Add Worker Node

**Goal**: Understand node addition process and capacity expansion.

## Prereqs

- kind cluster running (from scripts/kind-up.sh)
- `kubectl` configured

## Steps

```bash
# Check current nodes
kubectl get nodes

# View node resource capacity
kubectl describe nodes | grep -A 5 "Capacity:"

# Note: In kind, adding nodes requires cluster recreation
# For demonstration, we'll show the concept

# Check current node count
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "Current nodes: ${NODE_COUNT}"

# View cluster capacity
kubectl top nodes || echo "Metrics not available, install metrics-server"

# In production/cloud:
# - GKE: gcloud container clusters resize
# - EKS: eksctl scale nodegroup
# - AKS: az aks scale

# For kind: would need to recreate cluster with more nodes
# See scripts/kind-up.sh which creates 1 control-plane + 2 workers
```

## Verify

- Current node count matches cluster config
- Each node has capacity visible
- Understanding of scaling methods

## Cleanup

No cleanup needed - observation only.

## Key Takeaways

- Scaling out increases total cluster capacity
- Cloud providers offer autoscaling
- kind/minikube limited for node scaling demos
- Production uses cluster autoscaler
- New nodes join automatically (kubeadm, cloud-init)
