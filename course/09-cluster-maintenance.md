# Module 09 — Cluster Maintenance

## 🎯 Goals

- **Safely drain and cordon nodes** for maintenance
- **Backup and restore etcd** for disaster recovery
- **Perform cluster upgrades** step by step

## 🔧 Node Maintenance

### Cordon (Mark Unschedulable)

Prevents new pods from being scheduled on the node.

```bash
kubectl cordon w1
kubectl get nodes
# w1 shows SchedulingDisabled
```

**Uncordon** (allow scheduling again):
```bash
kubectl uncordon w1
```

### Drain (Evict Pods)

Safely evicts all pods from the node before maintenance.

```bash
kubectl drain w1 --ignore-daemonsets --delete-emptydir-data
```

**Options**:
- `--ignore-daemonsets`: DaemonSet pods can't be evicted
- `--delete-emptydir-data`: Delete emptyDir data (pods with emptyDir volumes)
- `--force`: Force delete pods not managed by controllers
- `--grace-period=60`: Wait 60s for graceful shutdown

**Verify**:
```bash
kubectl get pods -o wide
# No non-DaemonSet pods on w1
```

**After maintenance**:
```bash
kubectl uncordon w1
```

## 💾 etcd Backup

**Take snapshot**:
```bash
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

**Verify backup**:
```bash
sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup.db --write-out=table
```

## ♻️ etcd Restore

**Stop API server and etcd**:
```bash
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
sudo mv /etc/kubernetes/manifests/etcd.yaml /tmp/
```

**Restore snapshot**:
```bash
sudo ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
  --data-dir=/var/lib/etcd-restore
```

**Update etcd manifest**:
```bash
sudo sed -i 's|/var/lib/etcd|/var/lib/etcd-restore|g' /tmp/etcd.yaml
```

**Restart**:
```bash
sudo mv /tmp/etcd.yaml /etc/kubernetes/manifests/
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```

## 🔄 Cluster Upgrade Review

See Module 03 for detailed upgrade steps.

**Summary**:
1. Backup etcd
2. Upgrade kubeadm on control plane
3. Run `kubeadm upgrade plan`
4. Run `kubeadm upgrade apply`
5. Drain control plane
6. Upgrade kubelet/kubectl on control plane
7. Uncordon control plane
8. Repeat for each worker: drain, upgrade kubeadm, upgrade node, upgrade kubelet, uncordon

## 🧪 Mini-Lab: Node Maintenance (10 minutes)

```bash
# Create test deployment
kubectl create deployment test --image=nginx --replicas=5

# Check pod distribution
kubectl get pods -o wide

# Drain a worker
kubectl drain w1 --ignore-daemonsets --delete-emptydir-data

# Pods moved to other nodes
kubectl get pods -o wide

# Uncordon
kubectl uncordon w1

# Cleanup
kubectl delete deployment test
```

## ❌ Common Mistakes

1. **Draining without --ignore-daemonsets** → command fails
2. **Not backing up etcd before upgrades**
3. **Forgetting to uncordon after maintenance**
4. **Draining all nodes at once** → no capacity for pods
5. **Not checking PodDisruptionBudgets**

---

**Next**: Module 10 — Troubleshooting Guide
