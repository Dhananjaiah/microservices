# Pod Lifecycle: Observe Pod Phases

**Goal**: Watch a pod transition through lifecycle phases.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create a simple pod
kubectl run nginx --image=nginx:alpine

# Watch pod creation (in another terminal or use -w)
kubectl get pods -w &
WATCH_PID=$!

# Get pod details
sleep 5
kubectl get pods nginx

# Describe pod to see events
kubectl describe pod nginx

# Check pod phase
kubectl get pod nginx -o jsonpath='{.status.phase}'
echo ""

# Check container state
kubectl get pod nginx -o jsonpath='{.status.containerStatuses[0].state}'
echo ""

# Delete pod and watch termination
kubectl delete pod nginx

# Wait for cleanup
sleep 2
kill $WATCH_PID 2>/dev/null || true
```

## Verify

- Pod transitions: Pending → Running
- Container state: Waiting → Running
- Pod terminates gracefully

## Cleanup

```bash
kubectl delete pod nginx --force --grace-period=0 2>/dev/null || true
```

## Key Takeaways

- Pods go through distinct lifecycle phases
- Pending phase means scheduling/image pull
- Running means at least one container is active
- Termination can be graceful or forced
