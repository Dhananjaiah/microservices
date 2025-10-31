# Services: ClusterIP Service

**Goal**: Create ClusterIP service for internal communication.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment
kubectl create deployment web --image=nginx:alpine --replicas=3

# Expose as ClusterIP service
kubectl expose deployment web --port=80 --target-port=80 --name=web-svc

# Get service details
kubectl get svc web-svc

# Get service endpoints (pod IPs)
kubectl get endpoints web-svc

# Test service from inside cluster
kubectl run test-pod --image=busybox:latest --rm -it --restart=Never -- wget -O- http://web-svc:80

# Check service DNS
kubectl run test-pod --image=busybox:latest --rm -it --restart=Never -- nslookup web-svc

# View service in YAML
kubectl get svc web-svc -o yaml
```

## Verify

- Service has ClusterIP assigned
- Endpoints match pod IPs
- Service accessible from within cluster
- DNS resolution works

## Cleanup

```bash
kubectl delete svc web-svc
kubectl delete deployment web
```

## Key Takeaways

- ClusterIP is internal-only (not accessible outside)
- Service uses label selector to find pods
- Provides load balancing across pods
- DNS name: `<service-name>.<namespace>.svc.cluster.local`
