#!/bin/bash
# Chaos engineering script to inject failures and test resilience

set -e

NAMESPACE="foodcart"

function show_usage() {
    echo "Usage: $0 <scenario>"
    echo ""
    echo "Available scenarios:"
    echo "  kill-pods         - Randomly kill pods to test self-healing"
    echo "  network-partition - Simulate network issues with NetworkPolicies"
    echo "  restart-db        - Restart the database to test recovery"
    echo "  resource-stress   - Stress CPU/memory to trigger HPA"
    echo "  cordon-node       - Cordon a node to test pod rescheduling"
    echo "  delete-pvc        - Delete PVC to simulate storage failure"
    echo ""
}

function kill_pods() {
    echo "🔴 Chaos: Randomly killing pods..."
    
    # Kill a random backend pod
    PODS=($(kubectl get pods -n $NAMESPACE -l role=backend -o name))
    if [ ${#PODS[@]} -gt 0 ]; then
        RANDOM_POD=${PODS[$RANDOM % ${#PODS[@]}]}
        echo "Killing: $RANDOM_POD"
        kubectl delete $RANDOM_POD -n $NAMESPACE --grace-period=0 --force
    fi
    
    # Kill a random api-gateway pod
    kubectl delete pod -n $NAMESPACE -l app=api-gateway --field-selector=status.phase=Running --grace-period=0 --force 2>/dev/null || true
    
    echo "✓ Pods killed. Watch recovery with: kubectl get pods -n $NAMESPACE -w"
}

function network_partition() {
    echo "🔴 Chaos: Creating network partition..."
    
    # Create a blocking NetworkPolicy
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: chaos-block-all
  namespace: $NAMESPACE
spec:
  podSelector:
    matchLabels:
      app: api-gateway
  policyTypes:
  - Ingress
  - Egress
EOF
    
    echo "✓ Network partition created"
    echo "To restore: kubectl delete networkpolicy chaos-block-all -n $NAMESPACE"
}

function restart_db() {
    echo "🔴 Chaos: Restarting database..."
    
    kubectl delete pod postgres-0 -n $NAMESPACE
    
    echo "✓ Database pod deleted. Watch recovery with: kubectl get pods -n $NAMESPACE -w"
}

function resource_stress() {
    echo "🔴 Chaos: Creating resource stress..."
    
    # Create CPU stress pod
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: stress-test
  namespace: $NAMESPACE
  labels:
    app: api-gateway
spec:
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "300s"]
    resources:
      requests:
        cpu: 400m
        memory: 128Mi
      limits:
        cpu: 1000m
        memory: 256Mi
EOF
    
    echo "✓ Stress test started. Watch HPA scale: watch kubectl get hpa -n $NAMESPACE"
    echo "Cleanup: kubectl delete pod stress-test -n $NAMESPACE"
}

function cordon_node() {
    echo "🔴 Chaos: Cordoning a node..."
    
    # Get a random worker node
    NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name | head -1)
    
    if [ -z "$NODE" ]; then
        echo "❌ No worker nodes found"
        return 1
    fi
    
    echo "Cordoning: $NODE"
    kubectl cordon $NODE
    
    echo "✓ Node cordoned. To restore: kubectl uncordon $NODE"
    echo "Evict pods: kubectl drain $NODE --ignore-daemonsets --delete-emptydir-data"
}

function delete_pvc() {
    echo "🔴 Chaos: Simulating storage failure..."
    echo "⚠️  WARNING: This will delete the PostgreSQL PVC and all data!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        return 0
    fi
    
    kubectl delete statefulset postgres -n $NAMESPACE
    kubectl delete pvc postgres-storage-postgres-0 -n $NAMESPACE
    
    echo "✓ PVC deleted. Redeploy with: kubectl apply -f manifests/02-postgres.yaml"
}

# Main script
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

SCENARIO=$1

case $SCENARIO in
    kill-pods)
        kill_pods
        ;;
    network-partition)
        network_partition
        ;;
    restart-db)
        restart_db
        ;;
    resource-stress)
        resource_stress
        ;;
    cordon-node)
        cordon_node
        ;;
    delete-pvc)
        delete_pvc
        ;;
    *)
        echo "❌ Unknown scenario: $SCENARIO"
        show_usage
        exit 1
        ;;
esac

echo ""
echo "📚 Use the runbook to troubleshoot and recover!"
echo "  See: project/runbook.md"
echo ""
