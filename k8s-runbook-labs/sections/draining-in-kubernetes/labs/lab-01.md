# Draining: Cordon and Drain Node

**Goal**: Safely prepare node for maintenance using cordon and drain.

## Prereqs

- kind cluster with multiple worker nodes
- `kubectl` configured

## Steps

```bash
# Create deployment
kubectl create deployment web --image=nginx:alpine --replicas=6

# Wait for pods
kubectl rollout status deployment/web

# View pod distribution
kubectl get pods -l app=web -o wide

# Get a worker node name
WORKER_NODE=$(kubectl get nodes --no-headers | grep -v control-plane | head -1 | awk '{print $1}')
echo "Target node: ${WORKER_NODE}"

# Cordon node (mark unschedulable)
kubectl cordon ${WORKER_NODE}

# Verify node is cordoned
kubectl get nodes

# Scale up - new pods won't schedule to cordoned node
kubectl scale deployment web --replicas=10
sleep 5
kubectl get pods -l app=web -o wide | grep ${WORKER_NODE} || echo "No new pods on cordoned node"

# Drain node (evict existing pods)
kubectl drain ${WORKER_NODE} --ignore-daemonsets --delete-emptydir-data

# Verify no app pods on drained node
kubectl get pods -l app=web -o wide | grep ${WORKER_NODE} || echo "Node successfully drained"

# Uncordon node to make it schedulable again
kubectl uncordon ${WORKER_NODE}

# Verify node is ready
kubectl get nodes
```

## Verify

- Cordoned node shows SchedulingDisabled
- Drain moves pods to other nodes
- Uncordon restores normal scheduling

## Cleanup

```bash
kubectl delete deployment web
# Ensure node is uncordoned
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} kubectl uncordon {} 2>/dev/null || true
```

## Key Takeaways

- Cordon prevents new pod scheduling
- Drain evicts existing pods gracefully
- Use before node maintenance
- Always uncordon after maintenance
- **DANGER**: Drain can cause pod disruption - use PodDisruptionBudgets in production
