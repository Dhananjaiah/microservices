# Deployments: Bad Image Rollout (Negative Test)

**Goal**: Observe deployment behavior with invalid image (ImagePullBackOff).

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment with good image
kubectl create deployment web --image=nginx:alpine --replicas=3
kubectl rollout status deployment/web

# Update to BAD image (doesn't exist)
kubectl set image deployment/web nginx=nginx:nonexistent-version

# Watch rollout (will hang)
kubectl rollout status deployment/web --timeout=30s || echo "Rollout timed out as expected"

# Check pods - some will be in ImagePullBackOff
kubectl get pods -l app=web

# Describe pod with error
BAD_POD=$(kubectl get pods -l app=web | grep ImagePullBackOff | head -1 | awk '{print $1}')
if [ -n "$BAD_POD" ]; then
  kubectl describe pod $BAD_POD | grep -A 5 "Events:"
fi

# Check deployment status
kubectl get deployment web

# Old pods still running! (thanks to maxUnavailable)
kubectl get pods -l app=web | grep Running

# Rollback to fix
kubectl rollout undo deployment/web

# Verify recovery
kubectl rollout status deployment/web
kubectl get pods -l app=web
```

## Verify

- **EXPECTED ERROR**: ImagePullBackOff for bad image
- Old pods remain running (rolling update protects availability)
- Rollback restores working state
- No complete outage occurred

## Cleanup

```bash
kubectl delete deployment web
```

## Key Takeaways

- Bad updates don't kill all pods immediately
- maxUnavailable protects against full outage
- ImagePullBackOff indicates image not found
- Rollback is the fix for bad deployments
