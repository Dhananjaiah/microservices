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

kubectl apply -f manifests/04-menu-service.yaml
echo "✓ Menu service deployed"

kubectl apply -f manifests/10-hpa.yaml
kubectl apply -f manifests/11-pdb.yaml
echo "✓ HPA and PDB configured"

kubectl apply -f manifests/12-network-policies.yaml
echo "✓ NetworkPolicies applied"

echo ""
echo "📊 Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n foodcart --timeout=120s
kubectl wait --for=condition=ready pod -l app=menu -n foodcart --timeout=120s

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Verify with: kubectl get all -n foodcart"
