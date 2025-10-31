# Kubernetes Architecture: Explore Components

**Goal**: Examine Kubernetes cluster components and their roles.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# View cluster info
kubectl cluster-info

# List all nodes
kubectl get nodes

# Get detailed node information
kubectl get nodes -o wide

# View control plane components (in kube-system namespace)
kubectl get pods -n kube-system

# Describe a node to see kubelet info
kubectl describe node $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# Check API server
kubectl get pods -n kube-system -l component=kube-apiserver

# Check etcd
kubectl get pods -n kube-system -l component=etcd

# Check scheduler
kubectl get pods -n kube-system -l component=kube-scheduler

# Check controller manager
kubectl get pods -n kube-system -l component=kube-controller-manager

# View kubelet process (on kind, check container)
docker exec kind-k8s-runbook-control-plane ps aux | grep kubelet || echo "Note: kubelet runs as host process in some setups"

# Check kube-proxy
kubectl get daemonset -n kube-system kube-proxy
```

## Verify

- All control plane pods are Running
- Nodes are in Ready state
- Core components are healthy

## Cleanup

No cleanup needed - read-only operations.

## Key Takeaways

- Control plane manages cluster state
- etcd stores all cluster data
- kubelet runs on each node
- kube-proxy handles networking
- API server is the central hub
