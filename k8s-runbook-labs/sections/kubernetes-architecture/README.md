# Kubernetes Architecture

Kubernetes has a master-worker architecture with a control plane managing worker nodes. The control plane makes global decisions, while nodes run containerized applications.

## Control Plane Components

- **kube-apiserver**: Frontend for Kubernetes control plane
- **etcd**: Distributed key-value store for cluster data
- **kube-scheduler**: Assigns pods to nodes
- **kube-controller-manager**: Runs controller processes
- **cloud-controller-manager**: Integrates with cloud providers

## Node Components

- **kubelet**: Agent ensuring containers run in pods
- **kube-proxy**: Network proxy on each node
- **Container Runtime**: Runs containers (Docker, containerd, CRI-O)

## Architecture Diagram

```mermaid
graph TB
    subgraph "Control Plane"
        API[kube-apiserver]
        ETCD[etcd]
        SCHED[kube-scheduler]
        CM[kube-controller-manager]
    end
    
    subgraph "Worker Node 1"
        K1[kubelet]
        P1[kube-proxy]
        POD1[Pods]
    end
    
    subgraph "Worker Node 2"
        K2[kubelet]
        P2[kube-proxy]
        POD2[Pods]
    end
    
    API --> ETCD
    API --> SCHED
    API --> CM
    API --> K1
    API --> K2
    K1 --> POD1
    K2 --> POD2
```

## Labs

- [Lab 01: Explore Cluster Components](labs/lab-01.md)
