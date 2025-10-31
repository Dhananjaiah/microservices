# ReplicaSets: Self-Healing Demo

**Goal**: Demonstrate ReplicaSet self-healing when pods are deleted.

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
EOF

# Wait for pods
sleep 5
kubectl get pods -l app=web

# Get one pod name
POD_NAME=$(kubectl get pods -l app=web -o jsonpath='{.items[0].metadata.name}')

# Delete the pod (simulate failure)
echo "Deleting pod: ${POD_NAME}"
kubectl delete pod ${POD_NAME}

# Watch ReplicaSet recreate pod
sleep 3
kubectl get pods -l app=web

# ReplicaSet always maintains 3 replicas!
kubectl get rs web-rs
```

## Verify

- After deletion, new pod is created immediately
- Total pod count returns to 3
- ReplicaSet status shows desired=3, current=3

## Cleanup

```bash
kubectl delete rs web-rs
```

## Key Takeaways

- ReplicaSet automatically replaces failed pods
- Self-healing ensures high availability
- Pod names change but count stays constant
- Labels determine which pods belong to ReplicaSet
