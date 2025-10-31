# Deployments: Rollback

**Goal**: Rollback a deployment to previous version.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment
kubectl create deployment web --image=nginx:1.21-alpine --replicas=3

# Wait for initial rollout
kubectl rollout status deployment/web

# Update to version 1.22
kubectl set image deployment/web nginx=nginx:1.22-alpine
kubectl rollout status deployment/web

# Update to version 1.23
kubectl set image deployment/web nginx=nginx:1.23-alpine
kubectl rollout status deployment/web

# View rollout history
kubectl rollout history deployment/web

# Check specific revision
kubectl rollout history deployment/web --revision=2

# Rollback to previous version
kubectl rollout undo deployment/web

# Watch rollback
kubectl rollout status deployment/web

# Verify image version
kubectl get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""

# Rollback to specific revision
kubectl rollout undo deployment/web --to-revision=1

# Verify
kubectl get deployment web -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
```

## Verify

- Can rollback to previous revision
- Can rollback to specific revision
- Rollback creates new revision
- Old pods replaced with previous version

## Cleanup

```bash
kubectl delete deployment web
```

## Key Takeaways

- Rollback uses previous ReplicaSet
- Can rollback to any previous revision
- Rollback is just another rollout
- History preserved for easy recovery
