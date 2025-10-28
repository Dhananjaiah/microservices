# Module 02 — Cluster Architecture

## 🎯 Goals

- **Understand Kubernetes control plane components** and their responsibilities
- **Learn how worker node components function** and interact with the control plane
- **Explore cluster communication patterns** between components and pods

## 📋 Kubernetes Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     CONTROL PLANE NODE(S)                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  kube-apiserver (REST API, auth, validation)             │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  etcd (distributed key-value store, cluster state)       │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  kube-controller-manager (reconciliation loops)          │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  kube-scheduler (pod placement decisions)               │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  kubelet, kube-proxy, container runtime                 │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (HTTPS)
┌──────────────────────┐                 ┌──────────────────────┐
│   WORKER NODE 1      │                 │   WORKER NODE 2      │
│  ┌────────────────┐  │                 │  ┌────────────────┐  │
│  │ kubelet        │←─┼─────────────────┼─→│ kubelet        │  │
│  │ kube-proxy     │  │                 │  │ kube-proxy     │  │
│  │ containerd     │  │                 │  │ containerd     │  │
│  │ CNI (calico)   │  │                 │  │ CNI (calico)   │  │
│  └────────────────┘  │                 │  └────────────────┘  │
│  ┌────────────────┐  │                 │  ┌────────────────┐  │
│  │    PODS        │  │                 │  │    PODS        │  │
│  └────────────────┘  │                 │  └────────────────┘  │
└──────────────────────┘                 └──────────────────────┘
```

---

## 🧩 Control Plane Components

### 1. kube-apiserver

**What it does**: The API server is the front door to Kubernetes. All kubectl commands, controllers, and kubelet talk to it.

**Key responsibilities**:
- Exposes the Kubernetes API (REST)
- Authenticates and authorizes requests
- Validates resource definitions
- Persists state to etcd
- Serves as the only component that directly talks to etcd

**Check if running**:
```bash
kubectl get pods -n kube-system | grep apiserver
```

**Expected**:
```
kube-apiserver-cp1   1/1   Running   0   10m
```

**View logs**:
```bash
kubectl logs -n kube-system kube-apiserver-cp1
```

**Configuration location** (on control plane node):
```bash
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

This is a static pod manifest. kubelet reads it directly and runs the API server as a pod. Changes to this file are picked up automatically.

**Verify API server is responding**:
```bash
kubectl get --raw /healthz
# Output: ok

kubectl get --raw /version
# Output: JSON with Kubernetes version info
```

---

### 2. etcd

**What it does**: etcd is the distributed database that stores all cluster state. It's the single source of truth.

**Key responsibilities**:
- Store cluster configuration and state
- Provide consistent, highly-available storage
- Support watch mechanisms (controllers watch for changes)

**Check if running**:
```bash
kubectl get pods -n kube-system | grep etcd
```

**Expected**:
```
etcd-cp1   1/1   Running   0   10m
```

**View logs**:
```bash
kubectl logs -n kube-system etcd-cp1
```

**Access etcd directly** (advanced, for troubleshooting):
```bash
# On control plane node
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list
```

**Expected**: List of etcd members (1 for single control plane, 3+ for HA)

etcd uses the Raft consensus algorithm. Data is replicated across all etcd members. A majority (quorum) must agree on writes.

**Configuration location**:
```bash
cat /etc/kubernetes/manifests/etcd.yaml
```

---

### 3. kube-controller-manager

**What it does**: Runs all the built-in controllers that watch the API server and reconcile desired state with actual state.

**Key controllers**:
- **Node Controller**: Monitors node health, marks nodes as NotReady
- **Replication Controller**: Ensures the right number of pod replicas
- **Endpoints Controller**: Populates endpoint objects (links Services to Pods)
- **Service Account Controller**: Creates default ServiceAccounts and tokens
- **Job Controller**: Creates pods for Jobs and CronJobs
- **StatefulSet Controller**: Manages StatefulSet pods with stable identities

**Check if running**:
```bash
kubectl get pods -n kube-system | grep controller-manager
```

**Expected**:
```
kube-controller-manager-cp1   1/1   Running   0   10m
```

**View logs**:
```bash
kubectl logs -n kube-system kube-controller-manager-cp1 | tail -50
```

**Configuration location**:
```bash
cat /etc/kubernetes/manifests/kube-controller-manager.yaml
```

Controllers run in a "reconciliation loop": watch for changes, compare desired state to actual state, take actions to match them.

---

### 4. kube-scheduler

**What it does**: Watches for newly created pods with no assigned node and selects a node for them to run on.

**Scheduling process**:
1. **Filtering**: Eliminate nodes that don't meet requirements (resources, taints, affinity)
2. **Scoring**: Rank remaining nodes based on priorities (spread, resource balance)
3. **Binding**: Assign pod to the highest-scoring node

**Check if running**:
```bash
kubectl get pods -n kube-system | grep scheduler
```

**Expected**:
```
kube-scheduler-cp1   1/1   Running   0   10m
```

**View logs** (see scheduling decisions):
```bash
kubectl logs -n kube-system kube-scheduler-cp1 | tail -50
```

**Configuration location**:
```bash
cat /etc/kubernetes/manifests/kube-scheduler.yaml
```

The scheduler doesn't run the pod—it just updates the pod's `spec.nodeName`. Kubelet on that node sees the update and starts the pod.

---

## 🖥️ Worker Node Components

### 1. kubelet

**What it does**: The kubelet is the "node agent" that runs on every node (including control plane). It ensures containers are running as specified.

**Key responsibilities**:
- Registers node with the API server
- Watches for pods assigned to its node
- Tells the container runtime (containerd) to start/stop containers
- Reports pod and node status back to API server
- Runs liveness/readiness/startup probes
- Mounts volumes

**Check if running** (on any node):
```bash
systemctl status kubelet
```

**Expected**: `active (running)`

**View logs**:
```bash
journalctl -u kubelet -f
```

**Configuration location**:
```bash
cat /var/lib/kubelet/config.yaml
```

**Verify kubelet is talking to API server**:
```bash
kubectl get nodes
# All nodes should be Ready
```

kubelet is NOT a pod—it's a systemd service. It runs on the host to manage pods.

---

### 2. kube-proxy

**What it does**: kube-proxy maintains network rules on nodes to implement Services. It enables pod-to-service communication.

**Modes**:
- **iptables** (default): Uses iptables rules to forward traffic
- **ipvs**: Uses IPVS (IP Virtual Server) for better performance at scale
- **userspace**: Legacy, rarely used

**Check if running**:
```bash
kubectl get pods -n kube-system | grep kube-proxy
```

**Expected**: One kube-proxy pod per node (DaemonSet)

**View logs**:
```bash
kubectl logs -n kube-system kube-proxy-xxxxx
```

**Verify iptables rules** (on any node):
```bash
sudo iptables -t nat -L KUBE-SERVICES
```

**Expected**: A chain for each Service

kube-proxy watches Services and Endpoints. When a Service is created, kube-proxy adds iptables rules on every node to redirect traffic to pod IPs.

---

### 3. Container Runtime (containerd)

**What it does**: containerd is the CRI-compliant runtime that actually runs containers.

**Kubelet → CRI → containerd → runc → container**

**Check if running**:
```bash
systemctl status containerd
```

**List running containers**:
```bash
sudo crictl ps
```

**Get container info**:
```bash
sudo crictl inspect <container-id>
```

**View container logs**:
```bash
sudo crictl logs <container-id>
```

**List images**:
```bash
sudo crictl images
```

`crictl` is the CLI for interacting with CRI runtimes. Use it when kubectl can't help (e.g., kubelet is down).

---

### 4. Container Network Interface (CNI)

**What it does**: CNI plugins configure pod networking. They assign IP addresses to pods and set up routes.

**Example CNIs**:
- **Calico**: L3 networking, supports NetworkPolicies
- **Flannel**: Simple overlay network
- **Cilium**: eBPF-based, advanced networking and security

**Check CNI pods** (Calico example):
```bash
kubectl get pods -n calico-system
```

**Expected**: calico-node pods on every node (DaemonSet)

**CNI configuration location** (on nodes):
```bash
ls /etc/cni/net.d/
cat /etc/cni/net.d/10-calico.conflist
```

**Verify pod networking**:
```bash
kubectl run test1 --image=busybox --restart=Never -- sleep 3600
kubectl run test2 --image=busybox --restart=Never -- sleep 3600

POD1_IP=$(kubectl get pod test1 -o jsonpath='{.status.podIP}')
kubectl exec test2 -- ping -c 3 $POD1_IP
```

**Expected**: Successful ping

**Cleanup**:
```bash
kubectl delete pod test1 test2
```

---

## 🔄 Component Communication Flow

### Example: kubectl create deployment web --image=nginx

**Step-by-step flow**:

1. **kubectl** → **kube-apiserver** (HTTPS, port 6443)
   - Authenticates with client certificate or token
   - API server validates the Deployment spec

2. **kube-apiserver** → **etcd** (port 2379)
   - Persists the Deployment object

3. **Deployment Controller** (in kube-controller-manager) watches API server
   - Sees new Deployment
   - Creates a ReplicaSet

4. **ReplicaSet Controller** watches API server
   - Sees new ReplicaSet
   - Creates Pod(s)

5. **kube-scheduler** watches API server
   - Sees unscheduled Pod(s)
   - Selects a node for each pod
   - Updates Pod's `spec.nodeName`

6. **kubelet** on the assigned node watches API server
   - Sees pod assigned to it
   - Tells containerd to pull image and start container

7. **kube-proxy** on all nodes watches API server
   - Sees new Service (if you create one)
   - Updates iptables rules

**Verify**:
```bash
kubectl create deployment web --image=nginx
kubectl get deployment,replicaset,pod -l app=web
```

**Expected**: 1 Deployment, 1 ReplicaSet, 1 Pod (all related)

**Cleanup**:
```bash
kubectl delete deployment web
```

---

## 🧪 Mini-Lab: Explore Cluster Components (15 minutes)

### Task 1: Inspect Control Plane Pods

```bash
kubectl get pods -n kube-system
kubectl describe pod kube-apiserver-cp1 -n kube-system
kubectl logs -n kube-system kube-apiserver-cp1 --tail=20
```

**What to observe**:
- Static pods are named with the node suffix (-cp1)
- They have no controllers (no Deployment/ReplicaSet)
- hostNetwork: true (use host's network namespace)

### Task 2: Check Component Health

```bash
kubectl get componentstatuses

# Or use newer endpoints
kubectl get --raw='/readyz?verbose' | grep -v 'check passed'
kubectl get --raw='/livez?verbose' | grep -v 'check passed'
```

**Expected**: All components healthy

### Task 3: Examine Node Components

On a worker node (SSH to w1):
```bash
systemctl status kubelet
systemctl status containerd
sudo crictl ps
sudo iptables -t nat -L KUBE-SERVICES | head -20
```

### Task 4: Watch Scheduler in Action

Terminal 1:
```bash
kubectl logs -n kube-system kube-scheduler-cp1 -f | grep 'pod/test'
```

Terminal 2:
```bash
kubectl run test --image=nginx
# Watch Terminal 1 for scheduling decision
kubectl delete pod test
```

### Task 5: Explore etcd (Control Plane Node)

```bash
# List all keys in etcd
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix --keys-only | grep /pods | head -10
```

**What to observe**: Every Kubernetes object is stored under `/registry/<resource>/<namespace>/<name>`

---

## 🎯 Exam Drill: Component Troubleshooting (10 minutes)

**Scenario**: The API server pod is CrashLooping.

**Tasks**:
1. Check API server pod status (2 min)
2. View API server logs to find error (3 min)
3. Check etcd connectivity (2 min)
4. Verify certificates are valid (3 min)

**Commands**:
```bash
kubectl get pods -n kube-system | grep apiserver
kubectl logs -n kube-system kube-apiserver-cp1 --previous
kubectl get pods -n kube-system | grep etcd

# On control plane node
sudo ls -la /etc/kubernetes/pki/
sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -i validity
```

**Scoring**:
- **Full marks**: Identified root cause in <10 min
- **Partial marks**: Found error logs
- **Fail**: Couldn't access logs

---

## ❌ Common Mistakes

1. **Confusing static pods with regular pods** → Static pods are defined in `/etc/kubernetes/manifests/`, not in etcd. kubelet manages them directly.

2. **Thinking all components are pods** → kubelet and containerd run as systemd services, not pods.

3. **Not understanding the watch mechanism** → Controllers don't poll; they watch the API server and are notified immediately of changes.

4. **Forgetting kube-proxy mode** → In iptables mode, changing the mode requires deleting and recreating the kube-proxy DaemonSet.

5. **Directly modifying etcd** → Never write to etcd directly. Always use kubectl or the API server.

---

## 📝 Key Concepts Summary

### Control Plane Components (Decision Makers)
| Component | Role | Runs As |
|-----------|------|---------|
| kube-apiserver | REST API, auth, persistence | Static Pod |
| etcd | Cluster state database | Static Pod |
| kube-controller-manager | Reconciliation loops | Static Pod |
| kube-scheduler | Pod placement | Static Pod |

### Worker Node Components (Task Executors)
| Component | Role | Runs As |
|-----------|------|---------|
| kubelet | Node agent, runs pods | systemd service |
| kube-proxy | Service networking | DaemonSet pod |
| containerd | Container runtime | systemd service |
| CNI (calico) | Pod networking | DaemonSet pod |

### Data Flow
1. **kubectl** → **API server** (authenticate, validate)
2. **API server** → **etcd** (persist state)
3. **Controllers** watch **API server** (reconcile state)
4. **Scheduler** watches **API server** (assign pods)
5. **kubelet** watches **API server** (run pods)
6. **kube-proxy** watches **API server** (update iptables)

---

## 🎓 Key Takeaways

- **API server is the hub** — everything talks to it, nothing talks directly to each other
- **etcd is the source of truth** — if it's not in etcd, Kubernetes doesn't know about it
- **Controllers are the brain** — they continuously reconcile desired state with actual state
- **Scheduler is the matchmaker** — it finds the best node for each pod
- **kubelet is the hands** — it does the actual work of running containers
- **Everything is declarative** — you declare desired state, controllers make it happen

---

**Next**: Module 03 — Installation and Upgrade (cluster lifecycle management)
