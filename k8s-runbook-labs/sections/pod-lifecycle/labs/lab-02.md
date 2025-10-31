# Pod Lifecycle: Init Containers

**Goal**: Use init containers that run before main containers.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create pod with init container
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  initContainers:
  - name: init-setup
    image: busybox:latest
    command: ['sh', '-c', 'echo "Initializing..." && sleep 5 && echo "Done!"']
  containers:
  - name: main
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

# Watch pod initialization
kubectl get pods init-demo -w &
WATCH_PID=$!

# Wait for init to complete
sleep 10

# Check init container logs
kubectl logs init-demo -c init-setup

# Check main container status
kubectl get pod init-demo

# Describe to see init container completion
kubectl describe pod init-demo

# Cleanup
kill $WATCH_PID 2>/dev/null || true
kubectl delete pod init-demo
```

## Verify

- Init container runs and completes first
- Main container starts only after init succeeds
- Pod shows both container statuses

## Cleanup

```bash
kubectl delete pod init-demo --force --grace-period=0 2>/dev/null || true
```

## Key Takeaways

- Init containers run before app containers
- All init containers must succeed sequentially
- Used for setup tasks (download config, wait for dependencies)
- Main containers don't start until init completes
