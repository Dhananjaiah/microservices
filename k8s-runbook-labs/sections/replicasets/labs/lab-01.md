# ReplicaSets: Create and Scale

**Goal**: Create a ReplicaSet and observe replica management.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create ReplicaSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
spec:
  replicas: 3
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
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

# Watch pods being created
kubectl get pods -l app=web

# Get ReplicaSet status
kubectl get rs web-rs

# Scale up
kubectl scale rs web-rs --replicas=5

# Verify new pods created
kubectl get pods -l app=web

# Scale down
kubectl scale rs web-rs --replicas=2

# Verify pods terminated
kubectl get pods -l app=web
```

## Verify

- Exactly 3 pods initially created
- Scaling changes pod count
- All pods have app=web label

## Cleanup

```bash
kubectl delete rs web-rs
```

## Key Takeaways

- ReplicaSet maintains exact replica count
- Uses label selector to identify pods
- Scaling is immediate
- Pods are created/deleted to match desired state
