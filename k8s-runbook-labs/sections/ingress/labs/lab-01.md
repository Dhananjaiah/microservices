# Ingress: Install NGINX Ingress Controller

**Goal**: Deploy NGINX Ingress Controller in kind cluster.

## Prereqs

- kind cluster running (created with scripts/kind-up.sh)
- `kubectl` configured

## Steps

```bash
# For kind, install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo "Waiting for ingress-nginx..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Verify installation
kubectl get pods -n ingress-nginx

# Check ingress class
kubectl get ingressclass

# Verify controller service
kubectl get svc -n ingress-nginx
```

## Verify

- ingress-nginx-controller pod Running
- IngressClass 'nginx' exists
- Controller service created

## Cleanup

```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml 2>/dev/null || true
```

## Key Takeaways

- Ingress requires an Ingress Controller
- kind cluster configured for ingress on ports 80/443
- NGINX is most popular ingress controller
- IngressClass identifies controller to use

## Notes

For minikube, use: `minikube addons enable ingress`
