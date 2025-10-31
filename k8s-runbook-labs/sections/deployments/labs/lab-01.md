# Deployments: Create and Update

**Goal**: Create a deployment and perform a rolling update.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment
kubectl create deployment web --image=nginx:1.21-alpine --replicas=3

# Check deployment status
kubectl get deployment web

# Get pods created by deployment
kubectl get pods -l app=web

# Check rollout status
kubectl rollout status deployment/web

# Update image (rolling update)
kubectl set image deployment/web nginx=nginx:1.22-alpine

# Watch rollout
kubectl rollout status deployment/web

# Check revision history
kubectl rollout history deployment/web

# View deployment details
kubectl describe deployment web

# Check ReplicaSets (old and new)
kubectl get rs -l app=web
```

## Verify

- Deployment creates pods via ReplicaSet
- Rolling update creates new ReplicaSet
- Old pods gradually replaced by new ones
- Zero downtime during update

## Cleanup

```bash
kubectl delete deployment web
```

## Key Takeaways

- Deployments manage ReplicaSets
- Rolling updates happen automatically
- Revision history enables rollbacks
- Old ReplicaSets kept for rollback
