# Module 03 — Installation and Upgrade

## 🎯 Goals

- **Master the kubeadm cluster lifecycle** from installation to decommissioning
- **Upgrade a Kubernetes cluster** safely across minor versions
- **Backup and restore etcd** to protect cluster state

## 📋 kubeadm Cluster Lifecycle

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Install    │ →    │   Operate    │ →    │   Upgrade    │
│ (kubeadm init)│     │ (day-to-day)  │     │(kubeadm upgrade)│
└──────────────┘      └──────────────┘      └──────────────┘
                                                    ↓
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│ Decommission │ ←    │  Maintain    │ ←    │Backup/Restore│
│(kubeadm reset)│      │(drain, cordon)│     │    (etcd)    │
└──────────────┘      └──────────────┘      └──────────────┘
```

---

## 🚀 Cluster Installation Review

We covered basic installation in Module 01. Here's a quick recap with additional details.

### Control Plane Initialization

```bash
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=$(hostname -i) \
  --control-plane-endpoint=<LOAD_BALANCER_DNS>:6443  # For HA only
```

**Options explained**:
- `--pod-network-cidr`: CIDR for pod IPs (must match CNI requirements)
- `--apiserver-advertise-address`: IP other nodes use to reach API server
- `--control-plane-endpoint`: For HA clusters with multiple control planes
- `--kubernetes-version`: Specify exact version (e.g., v1.28.0)

**Verify**:
```bash
kubectl get nodes
kubectl get pods -n kube-system
```

### Adding Worker Nodes

```bash
# On control plane, generate join command
kubeadm token create --print-join-command

# On worker nodes
sudo kubeadm join <CONTROL_PLANE_IP>:6443 --token <TOKEN> \
    --discovery-token-ca-cert-hash sha256:<HASH>
```

**Verify**:
```bash
kubectl get nodes
# All nodes should show Ready
```

---

## 🔄 Kubernetes Cluster Upgrade

Upgrading Kubernetes is a multi-step process. You must upgrade one minor version at a time (e.g., 1.27 → 1.28 → 1.29).

### Upgrade Order

1. **Control plane node(s)** (one at a time if HA)
2. **Worker nodes** (can be done in parallel or rolling)

### Pre-Upgrade Checklist

```bash
# Check current version
kubectl get nodes

# Check for deprecated APIs (if upgrading to 1.25+)
kubectl get apiservices
kubectl get --raw /apis | jq .groups[].preferredVersion

# Review release notes
# https://kubernetes.io/docs/setup/release/notes/
```

---

### Step 1: Upgrade kubeadm on Control Plane

**Find available versions**:
```bash
# Ubuntu
sudo apt update
sudo apt-cache madison kubeadm

# RHEL/Rocky
sudo dnf --showduplicates list kubeadm
```

**Upgrade kubeadm**:
```bash
# Ubuntu (example: upgrade to 1.28.5)
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.28.5-00
sudo apt-mark hold kubeadm

# RHEL/Rocky
sudo dnf install -y kubeadm-1.28.5-0 --disableexcludes=kubernetes
```

**Verify**:
```bash
kubeadm version
```

---

### Step 2: Plan the Upgrade

```bash
sudo kubeadm upgrade plan
```

**Expected output**:
```
Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       TARGET
kubelet     3 x v1.27.0   v1.28.5

Upgrade to the latest stable version:

COMPONENT                 CURRENT   TARGET
kube-apiserver            v1.27.0   v1.28.5
kube-controller-manager   v1.27.0   v1.28.5
kube-scheduler            v1.27.0   v1.28.5
kube-proxy                v1.27.0   v1.28.5
CoreDNS                   v1.10.1   v1.11.1
etcd                      3.5.9     3.5.9

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.28.5
```

This shows what will be upgraded. Review carefully!

---

### Step 3: Apply Upgrade to Control Plane

```bash
sudo kubeadm upgrade apply v1.28.5
```

**What happens**:
- Downloads new component images
- Upgrades static pod manifests in `/etc/kubernetes/manifests/`
- API server, controller-manager, scheduler restart with new versions
- etcd is upgraded if needed
- CoreDNS is upgraded
- kube-proxy DaemonSet is updated

**⏱️ Time**: 2-5 minutes

**Expected output** (at the end):
```
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.28.5". Enjoy!
```

**Verify**:
```bash
kubectl get nodes
# Control plane still shows old version (kubelet not upgraded yet)

kubectl get pods -n kube-system
# All pods should be Running with new versions
```

---

### Step 4: Upgrade kubelet and kubectl on Control Plane

**Drain the control plane node** (move pods to workers):
```bash
kubectl drain cp1 --ignore-daemonsets --delete-emptydir-data
```

**Verify**:
```bash
kubectl get nodes
# cp1 should show SchedulingDisabled
```

This prevents new pods from being scheduled on the control plane while we upgrade.

**Upgrade kubelet and kubectl**:
```bash
# Ubuntu
sudo apt-mark unhold kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubelet=1.28.5-00 kubectl=1.28.5-00
sudo apt-mark hold kubelet kubectl

# RHEL/Rocky
sudo dnf install -y kubelet-1.28.5-0 kubectl-1.28.5-0 --disableexcludes=kubernetes
```

**Restart kubelet**:
```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

**Verify**:
```bash
systemctl status kubelet
```

**Uncordon the node** (allow scheduling again):
```bash
kubectl uncordon cp1
```

**Verify**:
```bash
kubectl get nodes
# cp1 should now show v1.28.5
```

---

### Step 5: Upgrade Worker Nodes

Repeat for **each worker node**. You can do them one at a time (safer) or in parallel (faster).

#### On Control Plane (for each worker)

**Drain the worker**:
```bash
kubectl drain w1 --ignore-daemonsets --delete-emptydir-data
```

**Verify**:
```bash
kubectl get nodes
# w1 should show SchedulingDisabled

kubectl get pods -o wide
# No non-DaemonSet pods should be on w1
```

#### On Worker Node w1

**Upgrade kubeadm**:
```bash
# Ubuntu
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.28.5-00
sudo apt-mark hold kubeadm

# RHEL/Rocky
sudo dnf install -y kubeadm-1.28.5-0 --disableexcludes=kubernetes
```

**Upgrade node configuration**:
```bash
sudo kubeadm upgrade node
```

**Expected output**:
```
[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[upgrade] Skipping phase. Not a control plane node.
[upgrade] Upgrading your Static Pod-hosted control plane instance to version "v1.28.5"...
Static pod: kube-proxy-xxx hash: xxx
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
```

**Upgrade kubelet**:
```bash
# Ubuntu
sudo apt-mark unhold kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubelet=1.28.5-00 kubectl=1.28.5-00
sudo apt-mark hold kubelet kubectl

# RHEL/Rocky
sudo dnf install -y kubelet-1.28.5-0 kubectl-1.28.5-0 --disableexcludes=kubernetes
```

**Restart kubelet**:
```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

**Verify**:
```bash
systemctl status kubelet
```

#### On Control Plane (after worker upgraded)

**Uncordon the worker**:
```bash
kubectl uncordon w1
```

**Verify**:
```bash
kubectl get nodes
# w1 should now show v1.28.5 and Ready
```

**Repeat for w2, w3, etc.**

---

### Step 6: Verify Cluster Health

```bash
# Check all nodes
kubectl get nodes

# Check all system pods
kubectl get pods -n kube-system

# Check workload pods
kubectl get pods -A

# Check component health
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
```

**Expected**: All nodes on v1.28.5, all pods Running, health checks ok.

---

## 💾 etcd Backup and Restore

etcd contains ALL cluster state. Losing etcd means losing your entire cluster. **Always backup etcd!**

### Prerequisites: Install etcdctl

etcdctl is usually included with etcd, but you can also download it separately.

```bash
# Check if etcdctl is available
etcdctl version

# If not, install it
ETCD_VER=v3.5.9
wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo mv etcd-${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/
rm -rf etcd-${ETCD_VER}-linux-amd64*
```

**Verify**:
```bash
etcdctl version
```

---

### Taking a Backup

**On the control plane node**:
```bash
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db
```

**Verify backup**:
```bash
sudo ETCDCTL_API=3 etcdctl \
  --write-out=table \
  snapshot status /tmp/etcd-backup.db
```

**Expected**:
```
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| 12345678 |    54321 |       1234 |     3.2 MB |
+----------+----------+------------+------------+
```

**Store backup safely**:
```bash
sudo cp /tmp/etcd-backup.db /root/etcd-backup-$(date +%Y%m%d-%H%M%S).db
# Or upload to S3, GCS, etc.
```

**Automate daily backups** (cron example):
```bash
# Add to root's crontab
sudo crontab -e

# Add this line (daily at 2 AM)
0 2 * * * ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /root/etcd-backup-$(date +\%Y\%m\%d).db
```

---

### Restoring from Backup

**⚠️ DANGER**: Restore wipes out the current etcd data. Only do this in a disaster recovery scenario.

**Stop kube-apiserver and etcd** (they'll restart automatically):
```bash
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/
sudo mv /etc/kubernetes/manifests/etcd.yaml /tmp/
```

**Wait for pods to stop**:
```bash
sudo crictl ps | grep -E 'kube-apiserver|etcd'
# Should be empty
```

**Restore etcd data**:
```bash
sudo ETCDCTL_API=3 etcdctl \
  snapshot restore /root/etcd-backup-20240115.db \
  --data-dir=/var/lib/etcd-restore
```

**Update etcd manifest** to use new data directory:
```bash
sudo sed -i 's|/var/lib/etcd|/var/lib/etcd-restore|g' /tmp/etcd.yaml
```

**Restart etcd and apiserver**:
```bash
sudo mv /tmp/etcd.yaml /etc/kubernetes/manifests/
sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
```

**Wait for pods to start**:
```bash
watch kubectl get pods -n kube-system
```

**Verify cluster is healthy**:
```bash
kubectl get nodes
kubectl get pods -A
```

---

## 🧪 Mini-Lab: Cluster Upgrade Simulation (20 minutes)

### Task 1: Check Current Version

```bash
kubectl get nodes
kubectl version --short
kubeadm version
```

### Task 2: Simulate Upgrade Planning

```bash
# Don't actually run this if you're on the latest version
sudo kubeadm upgrade plan
```

### Task 3: Take etcd Backup

```bash
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup-lab.db

sudo ETCDCTL_API=3 etcdctl \
  --write-out=table \
  snapshot status /tmp/etcd-backup-lab.db
```

### Task 4: Practice Node Drain/Uncordon

```bash
# Create a test deployment
kubectl create deployment test --image=nginx --replicas=3

# Drain a worker node
kubectl drain w1 --ignore-daemonsets --delete-emptydir-data

# Check where pods moved
kubectl get pods -o wide

# Uncordon the node
kubectl uncordon w1

# Cleanup
kubectl delete deployment test
```

---

## 🎯 Exam Drill: Upgrade and Backup (20 minutes)

**Scenario**: Upgrade control plane from 1.27.0 to 1.28.0 and backup etcd.

**Tasks**:
1. Take etcd backup (5 min)
2. Upgrade kubeadm on control plane (3 min)
3. Run upgrade plan (2 min)
4. Apply upgrade (5 min)
5. Upgrade kubelet/kubectl on control plane (5 min)

**Scoring**:
- **Full marks**: All tasks complete, cluster healthy
- **Partial marks**: Upgrade plan successful
- **Fail**: Cluster unhealthy after upgrade

---

## ❌ Common Mistakes

1. **Upgrading more than one minor version** → Not supported. Must go 1.27 → 1.28 → 1.29.

2. **Forgetting to drain nodes** → Pods may be disrupted during kubelet upgrade.

3. **Not taking etcd backup** → If upgrade fails, you have no recovery path.

4. **Upgrading workers before control plane** → Workers must be equal to or older than control plane.

5. **Using wrong etcd endpoints** → Must use HTTPS (127.0.0.1:2379) with certs, not HTTP.

6. **Restoring etcd without stopping API server** → API server will write to etcd, corrupting the restore.

---

## 🎓 Key Takeaways

- **Always backup etcd before upgrades** — it's your disaster recovery lifeline
- **Upgrade one minor version at a time** — skipping versions is not supported
- **Drain nodes before upgrading kubelet** — prevents pod disruption
- **Control plane first, workers second** — never upgrade workers ahead of control plane
- **Test upgrades in dev** before production — catch issues early

---

**Next**: Module 04 — Workloads and Scheduling (deploy and manage applications)
