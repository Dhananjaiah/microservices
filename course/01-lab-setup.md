# Module 01 — Lab Setup

## 🎯 Goals

- **Install a working Kubernetes cluster** using kubeadm on Ubuntu or RHEL/Rocky Linux
- **Configure containerd as the CRI** with proper systemd cgroup driver
- **Deploy Calico CNI** and verify all components are healthy

## ⚙️ Prerequisites

- **3 Virtual Machines** (or cloud instances):
  - 1 control-plane node: 2 vCPU, 2-4 GB RAM, 20 GB disk
  - 2 worker nodes: 2 vCPU, 2-4 GB RAM, 20 GB disk
- **OS**: Ubuntu 22.04 LTS or Rocky Linux 9
- **Network**: All nodes can reach each other, internet access for package installation
- **Root or sudo access** on all nodes

## 📋 Architecture Overview

```
┌─────────────────────────────────────────────────┐
│          Control Plane Node (cp1)               │
│  ┌──────────────────────────────────────────┐   │
│  │ kube-apiserver                           │   │
│  │ etcd                                     │   │
│  │ kube-controller-manager                  │   │
│  │ kube-scheduler                           │   │
│  │ kubelet, kube-proxy, containerd         │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
              ↓ (pod network: Calico CNI)
┌──────────────────────┐   ┌──────────────────────┐
│  Worker Node (w1)    │   │  Worker Node (w2)    │
│  ┌────────────────┐  │   │  ┌────────────────┐  │
│  │ kubelet        │  │   │  │ kubelet        │  │
│  │ kube-proxy     │  │   │  │ kube-proxy     │  │
│  │ containerd     │  │   │  │ containerd     │  │
│  │ pods           │  │   │  │ pods           │  │
│  └────────────────┘  │   │  └────────────────┘  │
└──────────────────────┘   └──────────────────────┘
```

---

## 🐧 Ubuntu 22.04 LTS Setup

### Step 1: Prepare All Nodes (Control Plane + Workers)

Run these commands on **all three nodes**.

#### 1.1 Disable Swap

**⚠️ DANGER**: This disables swap permanently. Kubernetes requires swap to be off.

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

**Verify**:
```bash
free -h
# Swap line should show 0B
```

Kubernetes scheduler assumes all memory is available. Swap interferes with pod memory limits and can cause unpredictable behavior.

#### 1.2 Load Kernel Modules

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

**Verify**:
```bash
lsmod | grep -E 'overlay|br_netfilter'
```

`overlay` is needed for container filesystems; `br_netfilter` enables iptables to see bridged traffic (required for pod networking).

#### 1.3 Configure Kernel Parameters

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

**Verify**:
```bash
sysctl net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward
# Both should return 1
```

These settings allow iptables to process traffic from container bridges, enabling Kubernetes networking and services to function.

#### 1.4 Install containerd

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key (containerd is part of Docker repos)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd.io
```

**Verify**:
```bash
systemctl status containerd
# Should show active (running)
```

containerd is the CRI (Container Runtime Interface) that kubelet uses to manage containers. It's lighter than Docker and CRI-compatible.

#### 1.5 Configure containerd (Critical!)

```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Enable SystemdCgroup (required for kubelet)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
```

**Verify**:
```bash
sudo grep SystemdCgroup /etc/containerd/config.toml
# Should show: SystemdCgroup = true
```

Kubernetes kubelet uses systemd cgroups by default. containerd must match this or pod creation will fail.

#### 1.6 Install kubeadm, kubelet, kubectl

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes apt repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes packages
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

**Verify**:
```bash
kubeadm version
kubectl version --client
kubelet --version
```

`apt-mark hold` prevents accidental upgrades. Kubernetes upgrades must be done carefully, one minor version at a time.

---

### Step 2: Initialize Control Plane (Control Plane Node ONLY)

Run these commands **only on the control plane node** (e.g., cp1).

#### 2.1 Initialize Cluster

```bash
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=$(hostname -i)
```

**What happens**: kubeadm generates certificates, starts etcd, API server, controller-manager, and scheduler. This takes 2-3 minutes.

**Expected Output** (end of output):
```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join <CONTROL_PLANE_IP>:6443 --token <TOKEN> \
    --discovery-token-ca-cert-hash sha256:<HASH>
```

**⚠️ CRITICAL**: Copy the `kubeadm join` command. You'll need it for workers!

#### 2.2 Configure kubectl (Control Plane Node)

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**Verify**:
```bash
kubectl get nodes
# Should show control-plane node, status NotReady (CNI not installed yet)
```

The kubeconfig file contains cluster info and admin credentials. kubectl reads it to authenticate with the API server.

#### 2.3 Install Calico CNI

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
```

**Wait for Calico pods** (takes 1-2 minutes):
```bash
watch kubectl get pods -n calico-system
# Wait until all pods are Running
```

**Verify**:
```bash
kubectl get nodes
# Control-plane node should now show Ready
```

Calico provides pod-to-pod networking. Without a CNI, pods can't communicate, and nodes stay NotReady.

---

### Step 3: Join Worker Nodes (Worker Nodes ONLY)

Run the `kubeadm join` command from Step 2.1 on **each worker node**.

```bash
sudo kubeadm join <CONTROL_PLANE_IP>:6443 --token <TOKEN> \
    --discovery-token-ca-cert-hash sha256:<HASH>
```

**If you lost the join command**, regenerate it on the control plane:
```bash
kubeadm token create --print-join-command
```

**Verify from control plane**:
```bash
kubectl get nodes
# Should show cp1, w1, w2 all Ready
```

**⏱️ Time**: 1-2 minutes per worker.

---

## 🐧 RHEL / Rocky Linux 9 Setup

### Step 1: Prepare All Nodes (Control Plane + Workers)

Run these commands on **all three nodes**.

#### 1.1 Disable Swap

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

**Verify**:
```bash
free -h
```

#### 1.2 Disable SELinux (Temporary)

**⚠️ DANGER**: This sets SELinux to permissive mode. For production, configure SELinux policies for Kubernetes instead.

```bash
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

**Verify**:
```bash
getenforce
# Should show Permissive
```

**Safer Alternative**: Keep SELinux enforcing and use Kubernetes SELinux policies (advanced, not covered here).

#### 1.3 Configure Firewall

**⚠️ DANGER**: This disables the firewall. For production, open specific ports instead.

```bash
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

**Safer Alternative** (open required ports):
```bash
# Control plane
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250-10252/tcp
sudo firewall-cmd --permanent --add-port=179/tcp  # Calico BGP
sudo firewall-cmd --reload

# Workers
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --reload
```

#### 1.4 Load Kernel Modules

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

**Verify**:
```bash
lsmod | grep -E 'overlay|br_netfilter'
```

#### 1.5 Configure Kernel Parameters

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

**Verify**:
```bash
sysctl net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward
```

#### 1.6 Install containerd

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y containerd.io
```

**Verify**:
```bash
systemctl status containerd
```

#### 1.7 Configure containerd

```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

**Verify**:
```bash
sudo grep SystemdCgroup /etc/containerd/config.toml
```

#### 1.8 Install kubeadm, kubelet, kubectl

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
```

**Verify**:
```bash
kubeadm version
kubectl version --client
```

---

### Step 2 & 3: Initialize Control Plane and Join Workers

**Same as Ubuntu** (see Steps 2 and 3 above). Commands are identical.

---

## ✅ Verification Checklist

Run these on the **control plane node** after all workers have joined.

### 1. Check All Nodes are Ready

```bash
kubectl get nodes
```

**Expected**:
```
NAME   STATUS   ROLES           AGE   VERSION
cp1    Ready    control-plane   5m    v1.28.x
w1     Ready    <none>          2m    v1.28.x
w2     Ready    <none>          2m    v1.28.x
```

### 2. Check All System Pods are Running

```bash
kubectl get pods -n kube-system
```

**Expected**: All pods in `Running` state (coredns, kube-proxy, calico, etc.)

### 3. Check Calico Networking

```bash
kubectl get pods -n calico-system
```

**Expected**: All calico pods `Running`.

### 4. Test Pod-to-Pod Networking

```bash
kubectl run test-nginx --image=nginx --restart=Never
kubectl run test-busybox --image=busybox --restart=Never -- sleep 3600

# Wait for pods to run
kubectl get pods

# Get nginx pod IP
NGINX_IP=$(kubectl get pod test-nginx -o jsonpath='{.status.podIP}')

# Test connectivity from busybox to nginx
kubectl exec test-busybox -- wget -O- $NGINX_IP:80
```

**Expected**: HTML output from nginx (default welcome page).

**Cleanup**:
```bash
kubectl delete pod test-nginx test-busybox
```

### 5. Test DNS Resolution

```bash
kubectl run test-dns --image=busybox --restart=Never -- nslookup kubernetes.default
kubectl logs test-dns
```

**Expected**:
```
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes.default
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

**Cleanup**:
```bash
kubectl delete pod test-dns
```

### 6. Check Component Health

```bash
kubectl get componentstatuses
```

**Note**: In newer Kubernetes versions, this command may be deprecated. Use these instead:

```bash
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
```

**Expected**: `ok` for all components.

---

## 🧪 Mini-Lab: Deploy a Test Application (10 minutes)

### Task 1: Create a Deployment

```bash
kubectl create deployment web --image=nginx:1.21 --replicas=3
```

**Verify**:
```bash
kubectl get deployments
kubectl get pods -l app=web
```

**Expected**: 3 nginx pods running, spread across worker nodes.

### Task 2: Expose the Deployment

```bash
kubectl expose deployment web --port=80 --type=NodePort
```

**Verify**:
```bash
kubectl get service web
```

**Expected**: A NodePort service (e.g., port 30000-32767).

### Task 3: Access the Application

```bash
NODE_PORT=$(kubectl get service web -o jsonpath='{.spec.ports[0].nodePort}')
WORKER_IP=$(kubectl get nodes -o jsonpath='{.items[1].status.addresses[0].address}')

curl http://$WORKER_IP:$NODE_PORT
```

**Expected**: Nginx welcome page HTML.

### Task 4: Cleanup

```bash
kubectl delete service web
kubectl delete deployment web
```

**Verify**:
```bash
kubectl get all
# Should only show kubernetes service
```

---

## 🎯 Exam Drill: Cluster Setup Speed Run (15 minutes)

**Scenario**: You have 3 fresh VMs. Initialize a Kubernetes cluster as fast as possible.

**Tasks**:
1. Disable swap on all nodes (2 min)
2. Install containerd and configure it (5 min)
3. Install kubeadm, kubelet, kubectl (3 min)
4. Initialize control plane and install Calico (3 min)
5. Join 2 worker nodes (2 min)

**Scoring**:
- **Full marks**: All 3 nodes Ready in <15 minutes
- **Partial marks**: Control plane Ready with CNI in <10 minutes
- **Fail**: Control plane not Ready or CNI not working

**Practice this drill until you can do it blindfolded!**

---

## ❌ Common Mistakes

1. **Forgetting to disable swap** → kubelet fails to start with error "running with swap on is not supported"
2. **Not setting SystemdCgroup=true in containerd** → pods fail to start with "failed to create containerd task"
3. **Wrong pod-network-cidr for CNI** → Calico expects 192.168.0.0/16 by default; mismatch causes networking failure
4. **Firewall blocking required ports** → `kubeadm join` fails with "connection refused" to :6443
5. **Lost join token** → Regenerate with `kubeadm token create --print-join-command`

---

## 📝 Post-Setup Tasks

### Enable kubectl Autocomplete (Highly Recommended!)

```bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
```

Now you can use `k get pods<TAB>` for autocomplete.

### Install crictl (for CRI debugging)

```bash
VERSION="v1.28.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

# Configure crictl
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF
```

**Verify**:
```bash
sudo crictl ps
# Should list running containers
```

`crictl` is the CLI for CRI-compatible runtimes. Use it when `kubectl` doesn't help (e.g., kubelet not starting).

---

## 🎓 Key Takeaways

- **Swap must be disabled** for kubelet to start
- **containerd requires SystemdCgroup=true** to work with kubelet
- **CNI must be installed** before nodes become Ready
- **kubeadm init** only runs on control plane; workers use `kubeadm join`
- **pod-network-cidr** in kubeadm init must match CNI configuration

---

**Next**: Module 02 — Cluster Architecture (understand what you just built!)
