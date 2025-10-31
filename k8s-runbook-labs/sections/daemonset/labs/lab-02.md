# DaemonSet: Node Selector

**Goal**: Use nodeSelector to target specific nodes.

## Prereqs

- kind cluster running
- `kubectl` configured

## Steps

```bash
# Label a node
WORKER_NODE=$(kubectl get nodes --no-headers | grep -v control-plane | head -1 | awk '{print $1}')
kubectl label nodes ${WORKER_NODE} disktype=ssd

# Create DaemonSet with nodeSelector
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ssd-monitor
spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        app: ssd-monitor
    spec:
      nodeSelector:
        disktype: ssd
      containers:
      - name: monitor
        image: busybox:latest
        command: ['sh', '-c', 'while true; do echo "SSD monitor on $(hostname)"; sleep 30; done']
EOF

# Wait for pods
sleep 10

# Get DaemonSet status
kubectl get daemonset ssd-monitor

# View pods - should only be on labeled node
kubectl get pods -l app=ssd-monitor -o wide

# Verify only on ssd node
kubectl get pods -l app=ssd-monitor -o wide | grep ${WORKER_NODE}

# Label another node
WORKER_NODE2=$(kubectl get nodes --no-headers | grep -v control-plane | tail -1 | awk '{print $1}')
kubectl label nodes ${WORKER_NODE2} disktype=ssd

# Wait and check - new pod appears
sleep 10
kubectl get pods -l app=ssd-monitor -o wide
```

## Verify

- Pods only on nodes with disktype=ssd label
- Adding label triggers pod creation
- Removing label would trigger pod deletion

## Cleanup

```bash
kubectl delete daemonset ssd-monitor
kubectl label nodes ${WORKER_NODE} disktype- 2>/dev/null || true
kubectl label nodes ${WORKER_NODE2} disktype- 2>/dev/null || true
```

## Key Takeaways

- nodeSelector limits DaemonSet to specific nodes
- Dynamic - pods added/removed as labels change
- Useful for hardware-specific workloads
- Labels provide flexible targeting
