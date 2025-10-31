# Rolling Update: Zero-Downtime Deployment

**Goal**: Observe rolling update maintaining availability.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment (RollingUpdate is default)
kubectl create deployment web --image=nginx:1.21-alpine --replicas=4

# Wait for initial rollout
kubectl rollout status deployment/web

# Update image
kubectl set image deployment/web nginx=nginx:1.22-alpine

# Watch pods during rollout - note gradual replacement
kubectl get pods -l app=web -w &
WATCH_PID=$!

# Check rollout status
kubectl rollout status deployment/web

# Stop watching
kill $WATCH_PID 2>/dev/null || true

# Check ReplicaSets - old and new
kubectl get rs -l app=web

# Verify all pods are new version
kubectl get pods -l app=web -o jsonpath='{.items[*].spec.containers[0].image}'
echo ""
```

## Verify

- Pods gradually replaced (not all at once)
- Some old pods remain during update
- No downtime - service stays available
- Two ReplicaSets exist (old scaled to 0)

## Cleanup

```bash
kubectl delete deployment web
```

## Key Takeaways

- RollingUpdate is the default strategy
- Zero downtime during updates
- Old and new versions run briefly together
- Controlled by maxSurge/maxUnavailable
