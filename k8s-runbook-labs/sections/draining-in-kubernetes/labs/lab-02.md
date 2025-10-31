# Draining: Handle DaemonSets

**Goal**: Drain nodes with DaemonSet pods using proper flags.

## Prereqs

- kind cluster running
- `kubectl` configured

## Steps

```bash
# Create a DaemonSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-logger
spec:
  selector:
    matchLabels:
      app: logger
  template:
    metadata:
      labels:
        app: logger
    spec:
      containers:
      - name: logger
        image: busybox:latest
        command: ['sh', '-c', 'while true; do echo "Logging..."; sleep 30; done']
EOF

# Wait for DaemonSet
sleep 10
kubectl get daemonset node-logger

# Get a worker node
WORKER_NODE=$(kubectl get nodes --no-headers | grep -v control-plane | head -1 | awk '{print $1}')

# Try drain WITHOUT --ignore-daemonsets (will fail)
kubectl drain ${WORKER_NODE} --delete-emptydir-data || echo "Expected failure - DaemonSet pods present"

# Drain WITH --ignore-daemonsets (succeeds)
kubectl drain ${WORKER_NODE} --ignore-daemonsets --delete-emptydir-data

# Verify node drained
kubectl get nodes

# Uncordon node
kubectl uncordon ${WORKER_NODE}

# DaemonSet pod recreated on uncordoned node
sleep 5
kubectl get pods -l app=logger -o wide | grep ${WORKER_NODE}
```

## Verify

- Drain fails without --ignore-daemonsets
- Drain succeeds with --ignore-daemonsets
- DaemonSet pods recreated after uncordon

## Cleanup

```bash
kubectl delete daemonset node-logger
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {} kubectl uncordon {} 2>/dev/null || true
```

## Key Takeaways

- DaemonSets run on all nodes (by design)
- Must use --ignore-daemonsets to drain
- DaemonSet pods return after uncordon
- Used for node-level services (monitoring, logging)
