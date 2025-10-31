# Ingress: Path-Based Routing

**Goal**: Route traffic based on URL paths using Ingress.

## Prereqs

- kind cluster with NGINX Ingress Controller
- `kubectl` configured

## Steps

```bash
# Create two deployments
kubectl create deployment web1 --image=nginx:alpine --replicas=2
kubectl create deployment web2 --image=httpd:alpine --replicas=2

# Expose as services
kubectl expose deployment web1 --port=80
kubectl expose deployment web2 --port=80

# Create Ingress with path-based routing
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /web1
        pathType: Prefix
        backend:
          service:
            name: web1
            port:
              number: 80
      - path: /web2
        pathType: Prefix
        backend:
          service:
            name: web2
            port:
              number: 80
EOF

# Wait for ingress
sleep 10

# Check ingress
kubectl get ingress path-ingress

# Test routing (from inside cluster or use port-forward)
kubectl run test --image=curlimages/curl --rm -it --restart=Never -- curl http://path-ingress.default.svc.cluster.local/web1 || true
kubectl run test --image=curlimages/curl --rm -it --restart=Never -- curl http://path-ingress.default.svc.cluster.local/web2 || true

# For local testing with kind:
# curl http://localhost/web1
# curl http://localhost/web2
```

## Verify

- Ingress created with paths /web1 and /web2
- Each path routes to different service
- Both services accessible via single ingress

## Cleanup

```bash
kubectl delete ingress path-ingress
kubectl delete svc web1 web2
kubectl delete deployment web1 web2
```

## Key Takeaways

- Path-based routing directs by URL path
- Single ingress can route to multiple services
- rewrite-target strips path prefix
- Useful for microservices architecture
