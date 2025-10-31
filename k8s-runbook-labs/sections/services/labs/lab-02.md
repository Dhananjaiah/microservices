# Services: NodePort Service

**Goal**: Expose service externally using NodePort.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment
kubectl create deployment web --image=nginx:alpine --replicas=2

# Expose as NodePort service
kubectl expose deployment web --type=NodePort --port=80 --name=web-nodeport

# Get service with node port
kubectl get svc web-nodeport

# Get the NodePort (30000-32767 range)
NODE_PORT=$(kubectl get svc web-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
echo "NodePort: ${NODE_PORT}"

# For kind: access via localhost
# curl http://localhost:${NODE_PORT}

# For minikube: use minikube service
# minikube service web-nodeport --url

# Port forward for testing
kubectl port-forward svc/web-nodeport 8080:80 &
PF_PID=$!
sleep 2

# Test service
curl http://localhost:8080

# Cleanup port-forward
kill $PF_PID 2>/dev/null || true
```

## Verify

- Service type is NodePort
- Port in range 30000-32767
- Service accessible from outside cluster

## Cleanup

```bash
kubectl delete svc web-nodeport
kubectl delete deployment web
```

## Key Takeaways

- NodePort exposes service on all node IPs
- Port is allocated from 30000-32767 range
- Useful for development/testing
- For production, use LoadBalancer or Ingress
