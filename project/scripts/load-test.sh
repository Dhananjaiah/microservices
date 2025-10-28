#!/bin/bash
# Load test script for FoodCart application

set -e

echo "🔥 Starting load test for FoodCart..."

# Check if required tools are available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is required but not installed"
    exit 1
fi

# Configuration
NAMESPACE="foodcart"
DURATION=${1:-60}  # Default 60 seconds
CONCURRENT=${2:-10}  # Default 10 concurrent requests

echo "Configuration:"
echo "  Duration: ${DURATION} seconds"
echo "  Concurrent requests: ${CONCURRENT}"
echo ""

# Get the NodePort
NODEPORT=$(kubectl get svc frontend -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "Target: http://${NODE_IP}:${NODEPORT}"
echo ""

# Create a load test pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: load-test
  namespace: $NAMESPACE
spec:
  containers:
  - name: load-test
    image: williamyeh/hey:latest
    command: ["sleep", "infinity"]
  restartPolicy: Never
EOF

echo "Waiting for load test pod to be ready..."
kubectl wait --for=condition=ready pod/load-test -n $NAMESPACE --timeout=60s

echo ""
echo "🚀 Running load test..."
echo ""

# Run load test against frontend
kubectl exec -n $NAMESPACE load-test -- hey -z ${DURATION}s -c ${CONCURRENT} http://frontend/ &
FRONTEND_PID=$!

# Run load test against api-gateway
kubectl exec -n $NAMESPACE load-test -- hey -z ${DURATION}s -c ${CONCURRENT} http://api-gateway/health &
API_PID=$!

# Wait for tests to complete
wait $FRONTEND_PID
wait $API_PID

echo ""
echo "📊 Monitoring HPA during load test..."
kubectl get hpa -n $NAMESPACE

echo ""
echo "📈 Resource usage:"
kubectl top pods -n $NAMESPACE

# Cleanup
echo ""
echo "🧹 Cleaning up load test pod..."
kubectl delete pod load-test -n $NAMESPACE --grace-period=0 --force 2>/dev/null || true

echo ""
echo "✅ Load test complete!"
echo ""
echo "Check HPA scaling:"
echo "  watch kubectl get hpa -n $NAMESPACE"
echo ""
echo "Check pod metrics:"
echo "  kubectl top pods -n $NAMESPACE"
echo ""
