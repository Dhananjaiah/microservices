# DaemonSet: Create and Observe

**Goal**: Create a DaemonSet and verify one pod per node.

## Prereqs

- kind cluster running
- `kubectl` configured

## Steps

```bash
# Create DaemonSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
spec:
  selector:
    matchLabels:
      app: monitor
  template:
    metadata:
      labels:
        app: monitor
    spec:
      containers:
      - name: monitor
        image: busybox:latest
        command: ['sh', '-c', 'while true; do echo "Monitoring $(hostname)"; sleep 30; done']
EOF

# Wait for pods
sleep 10

# Get DaemonSet status
kubectl get daemonset node-monitor

# Count nodes
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "Nodes: ${NODE_COUNT}"

# Count DaemonSet pods (should match or be close)
POD_COUNT=$(kubectl get pods -l app=monitor --no-headers | wc -l)
echo "DaemonSet pods: ${POD_COUNT}"

# View pod distribution
kubectl get pods -l app=monitor -o wide

# Check logs from one pod
POD_NAME=$(kubectl get pods -l app=monitor -o jsonpath='{.items[0].metadata.name}')
kubectl logs ${POD_NAME} --tail=5
```

## Verify

- Pod count approximately matches node count
- Each node has one monitor pod
- Pods run on all nodes including workers

## Cleanup

```bash
kubectl delete daemonset node-monitor
```

## Key Takeaways

- DaemonSet creates one pod per node
- Useful for node-level services
- Pods automatically deployed to new nodes
- Cannot use standard scaling commands
