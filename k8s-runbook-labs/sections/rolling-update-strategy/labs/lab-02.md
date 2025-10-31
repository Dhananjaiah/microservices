# Rolling Update: Configure maxSurge and maxUnavailable

**Goal**: Control rolling update behavior with maxSurge and maxUnavailable.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment with custom rolling update config
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 6
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
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
EOF

# Wait for initial deployment
kubectl rollout status deployment/web

# Update image
kubectl set image deployment/web nginx=nginx:1.22-alpine

# Watch pod count during rollout
kubectl get pods -l app=web -w &
WATCH_PID=$!

# Check deployment details
sleep 5
kubectl describe deployment web | grep -A 5 "RollingUpdate"

# Wait for completion
kubectl rollout status deployment/web

kill $WATCH_PID 2>/dev/null || true
```

## Verify

- Max 8 pods during update (6 + maxSurge 2)
- Min 5 pods available (6 - maxUnavailable 1)
- Update progresses in waves

## Cleanup

```bash
kubectl delete deployment web
```

## Key Takeaways

- maxSurge allows temporary over-capacity
- maxUnavailable controls minimum availability
- Can use numbers or percentages
- Tune for speed vs resource usage
