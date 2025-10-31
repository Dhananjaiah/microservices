# Services: Port Forwarding

**Goal**: Access services using kubectl port-forward.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment and service
kubectl create deployment web --image=nginx:alpine
kubectl expose deployment web --port=80

# Port forward to service
kubectl port-forward svc/web 8080:80 &
PF_PID=$!
sleep 2

# Test forwarded port
curl http://localhost:8080

# Port forward to specific pod
POD_NAME=$(kubectl get pods -l app=web -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward pod/${POD_NAME} 8081:80 &
PF_POD_PID=$!
sleep 2

# Test pod port forward
curl http://localhost:8081

# Cleanup port forwards
kill $PF_PID $PF_POD_PID 2>/dev/null || true
```

## Verify

- Can access service on localhost:8080
- Can access pod directly on localhost:8081
- Both serve the same content

## Cleanup

```bash
kill $(jobs -p) 2>/dev/null || true
kubectl delete svc web
kubectl delete deployment web
```

## Key Takeaways

- Port-forward useful for quick testing
- Can forward to services or pods
- Runs in foreground (use & for background)
- Only accessible from local machine
