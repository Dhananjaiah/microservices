#!/bin/bash
# Deploy FoodCart application to Kubernetes

set -e

echo "🚀 Deploying FoodCart application..."

# Deploy in dependency order
kubectl apply -f manifests/00-namespace.yaml
echo "✓ Namespace created"

kubectl apply -f manifests/01-postgres-pv.yaml
kubectl apply -f manifests/02-postgres.yaml
echo "✓ PostgreSQL deployed"

kubectl apply -f manifests/03-redis.yaml
echo "✓ Redis deployed"

kubectl apply -f manifests/04-menu-service.yaml
kubectl apply -f manifests/05-orders-service.yaml
kubectl apply -f manifests/06-payments-service.yaml
echo "✓ Backend services deployed"

kubectl apply -f manifests/07-api-gateway.yaml
echo "✓ API Gateway deployed"

kubectl apply -f manifests/08-frontend.yaml
echo "✓ Frontend deployed"

kubectl apply -f manifests/09-ingress.yaml
echo "✓ Ingress configured"

kubectl apply -f manifests/10-hpa.yaml
kubectl apply -f manifests/11-pdb.yaml
echo "✓ HPA and PDB configured"

kubectl apply -f manifests/12-network-policies.yaml
echo "✓ NetworkPolicies applied"

echo ""
echo "📊 Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n foodcart --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=redis -n foodcart --timeout=60s || true
kubectl wait --for=condition=ready pod -l app=menu -n foodcart --timeout=60s || true
kubectl wait --for=condition=ready pod -l app=orders -n foodcart --timeout=60s || true
kubectl wait --for=condition=ready pod -l app=payments -n foodcart --timeout=60s || true
kubectl wait --for=condition=ready pod -l app=api-gateway -n foodcart --timeout=60s || true
kubectl wait --for=condition=ready pod -l app=frontend -n foodcart --timeout=60s || true

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Verify with:"
echo "  kubectl get all -n foodcart"
echo "  kubectl get pvc -n foodcart"
echo "  kubectl get ingress -n foodcart"
echo ""
echo "🌐 Access the application:"
echo "  NodePort: http://<NODE_IP>:30080"
echo "  Ingress: http://foodcart.local (add to /etc/hosts)"
echo ""
