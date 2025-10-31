# Scaling Out: Pod Distribution

**Goal**: Observe how pods distribute across nodes.

## Prereqs

- kind cluster running with multiple nodes
- `kubectl` configured

## Steps

```bash
# Create deployment with many replicas
kubectl create deployment web --image=nginx:alpine --replicas=10

# Wait for pods
kubectl rollout status deployment/web

# View pod distribution across nodes
kubectl get pods -l app=web -o wide

# Count pods per node
kubectl get pods -l app=web -o wide --no-headers | awk '{print $7}' | sort | uniq -c

# View node resource usage
kubectl top nodes || echo "Install metrics-server to see usage"

# Check scheduler decisions
kubectl get events --sort-by='.lastTimestamp' | grep -i scheduled | head -10

# Scale up more to see distribution
kubectl scale deployment web --replicas=20

# Check distribution again
sleep 5
kubectl get pods -l app=web -o wide --no-headers | awk '{print $7}' | sort | uniq -c
```

## Verify

- Pods distributed across available nodes
- Scheduler balances workload
- No single node overloaded

## Cleanup

```bash
kubectl delete deployment web
```

## Key Takeaways

- Scheduler distributes pods for balance
- More nodes = more capacity
- Pods spread based on resources and affinity rules
- Adding nodes allows more workloads
