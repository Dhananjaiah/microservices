# Scaling In: Node Removal Workflow

**Goal**: Understand the process of safely removing a node.

## Prereqs

- kind cluster running
- `kubectl` configured

## Steps

```bash
# Create workload
kubectl create deployment web --image=nginx:alpine --replicas=8

# Wait for deployment
kubectl rollout status deployment/web

# View pod distribution
kubectl get pods -l app=web -o wide

# Get node count
kubectl get nodes
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "Current nodes: ${NODE_COUNT}"

# Select a worker node to "remove"
WORKER_NODE=$(kubectl get nodes --no-headers | grep -v control-plane | head -1 | awk '{print $1}')
echo "Removing node: ${WORKER_NODE}"

# Step 1: Cordon
kubectl cordon ${WORKER_NODE}

# Step 2: Drain
kubectl drain ${WORKER_NODE} --ignore-daemonsets --delete-emptydir-data

# Step 3: Verify pods migrated
kubectl get pods -l app=web -o wide

# In production, node would be deleted here:
# - Cloud: delete from node group/instance group
# - On-prem: decommission machine
# - kind: kind delete nodes (not practical to demo)

# For demo, we'll just keep it drained
echo "In production, node would be deleted at this point"

# Uncordon for cleanup (reverse the operation)
kubectl uncordon ${WORKER_NODE}
```

## Verify

- Pods successfully migrated off target node
- No app pods remain on drained node
- Cluster continues operating normally

## Cleanup

```bash
kubectl delete deployment web
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} kubectl uncordon {} 2>/dev/null || true
```

## Key Takeaways

- Always drain before removing nodes
- Ensures workloads migrate safely
- Check cluster capacity before scaling in
- PodDisruptionBudgets prevent over-eviction
- **DANGER**: Don't delete nodes without draining first
