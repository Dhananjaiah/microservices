# Ingress: Host-Based Routing

**Goal**: Route traffic based on hostname using Ingress.

## Prereqs

- kind cluster with NGINX Ingress Controller
- `kubectl` configured

## Steps

```bash
# Create two deployments
kubectl create deployment app1 --image=nginx:alpine
kubectl create deployment app2 --image=httpd:alpine

# Expose as services
kubectl expose deployment app1 --port=80
kubectl expose deployment app2 --port=80

# Create Ingress with host-based routing
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
  - host: app2.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2
            port:
              number: 80
EOF

# Check ingress
kubectl get ingress host-ingress
kubectl describe ingress host-ingress

# Test with host headers (in kind cluster)
# curl -H "Host: app1.example.com" http://localhost/
# curl -H "Host: app2.example.com" http://localhost/

# Or add to /etc/hosts for testing:
# echo "127.0.0.1 app1.example.com app2.example.com" | sudo tee -a /etc/hosts
# curl http://app1.example.com/
# curl http://app2.example.com/
```

## Verify

- Ingress configured with two hosts
- Each host routes to different service
- Host header determines backend

## Cleanup

```bash
kubectl delete ingress host-ingress
kubectl delete svc app1 app2
kubectl delete deployment app1 app2
```

## Key Takeaways

- Host-based routing uses hostname/domain
- Single IP serves multiple domains
- Name-based virtual hosting
- Requires DNS or host file configuration
- Common for multi-tenant applications
