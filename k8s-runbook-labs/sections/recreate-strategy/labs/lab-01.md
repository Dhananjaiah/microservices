# Recreate Strategy: Deployment with Downtime

**Goal**: Observe Recreate strategy causing downtime during updates.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment with Recreate strategy
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-recreate
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
EOF

# Wait for initial deployment
kubectl rollout status deployment/web-recreate

# Check running pods
kubectl get pods -l app=web

# Update image (triggers Recreate)
kubectl set image deployment/web-recreate nginx=nginx:1.22-alpine

# Watch pods - ALL old pods terminate FIRST
kubectl get pods -l app=web -w &
WATCH_PID=$!

# Wait for rollout
sleep 10
kubectl rollout status deployment/web-recreate

# Stop watching
kill $WATCH_PID 2>/dev/null || true

# Verify all pods are new
kubectl get pods -l app=web
```

## Verify

- All old pods terminated before new ones start
- Brief period with 0 pods running (downtime)
- All pods eventually show same new image

## Cleanup

```bash
kubectl delete deployment web-recreate
```

## Key Takeaways

- Recreate causes downtime
- All old pods stopped before new ones start
- Simpler than rolling updates
- Use only when downtime is acceptable
- **DANGER**: Production services will be unavailable during update
