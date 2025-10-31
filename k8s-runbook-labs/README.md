# Kubernetes Runbook Labs

Complete, runnable Kubernetes labs covering containers, Docker, and Kubernetes from basics to advanced topics. All labs are tested on **kind** and **minikube**.

## 🎯 Project Goals

- **100% Coverage**: Every concept from containers to ingress
- **Runnable Labs**: Copy-paste commands that work
- **Simple English**: Clear explanations, commands-first approach
- **Quality Assured**: Automated linting and schema validation

## 🚀 Quickstart

### Prerequisites

- Docker installed
- `kubectl` CLI installed
- Choose one: **kind** or **minikube**

### Setup with kind

```bash
# Install kind (if not already installed)
# See: https://kind.sigs.k8s.io/docs/user/quick-start/#installation

# Create cluster
cd k8s-runbook-labs
./scripts/kind-up.sh

# Verify
kubectl cluster-info
kubectl get nodes
```

### Setup with minikube

```bash
# Install minikube (if not already installed)
# See: https://minikube.sigs.k8s.io/docs/start/

# Start cluster
minikube start --nodes=3

# Verify
kubectl cluster-info
kubectl get nodes
```

## 📚 Sections

| # | Section | Topics |
|---|---------|--------|
| 1 | [Why Containers](sections/why-containers/) | Portability, efficiency, isolation |
| 2 | [Containers and Virtual Machines](sections/containers-and-virtual-machines/) | Architecture comparison, resource usage |
| 3 | [Docker Components](sections/docker-components/) | Engine, images, containers, Dockerfile |
| 4 | [Managing Containers at Scale](sections/managing-containers-at-scale/) | Orchestration needs, scaling challenges |
| 5 | [Kubernetes Architecture](sections/kubernetes-architecture/) | Control plane, worker nodes, components |
| 6 | [Pod Lifecycle](sections/pod-lifecycle/) | Phases, container states, init containers |
| 7 | [ReplicaSets](sections/replicasets/) | Self-healing, scaling, label selectors |
| 8 | [Deployments](sections/deployments/) | Rolling updates, rollbacks, revisions |
| 9 | [Services](sections/services/) | ClusterIP, NodePort, service discovery |
| 10 | [Recreate Strategy](sections/recreate-strategy/) | All-at-once updates, downtime |
| 11 | [Rolling Update Strategy](sections/rolling-update-strategy/) | Zero-downtime, maxSurge, maxUnavailable |
| 12 | [Scaling Out a Cluster](sections/scaling-out-a-cluster/) | Adding nodes, capacity expansion |
| 13 | [Draining in Kubernetes](sections/draining-in-kubernetes/) | Cordon, drain, node maintenance |
| 14 | [Scaling In a Cluster](sections/scaling-in-a-cluster/) | Removing nodes, safe scale-down |
| 15 | [DaemonSet](sections/daemonset/) | One pod per node, node-level services |
| 16 | [Jobs](sections/jobs/) | Batch processing, CronJobs, completions |
| 17 | [ConfigMaps](sections/configmaps/) | Configuration management, env vars, volumes |
| 18 | [Liveness, Readiness and Startup Probes](sections/liveness-readiness-startup-probes/) | Health checks, traffic control |
| 19 | [Ingress](sections/ingress/) | HTTP routing, path/host-based rules |

## 🧪 Lab Structure

Each section follows a consistent pattern:

```
sections/<topic>/
├── README.md          # Concept overview (2-3 lines + key points)
├── labs/
│   ├── lab-01.md     # Hands-on lab with commands
│   ├── lab-02.md     # Additional labs as needed
│   └── ...
└── examples/          # YAML files and code from labs
    ├── deployment.yaml
    └── ...
```

Every lab includes:
- **Goal**: What you'll learn (1-2 lines)
- **Prereqs**: Requirements
- **Steps**: Exact bash commands (copy-paste ready)
- **Verify**: How to confirm success
- **Cleanup**: Remove resources
- **Key Takeaways**: Main lessons

## 🔧 Utilities

Helper scripts in `scripts/`:

- `kind-up.sh` - Create kind cluster (idempotent)
- `kind-down.sh` - Delete kind cluster
- `wait-for-pod.sh` - Wait for pod readiness

## ✅ Quality Gates

This project uses automated checks:

- **yamllint**: YAML syntax and style
- **kubeconform**: Kubernetes schema validation
- **markdownlint**: Markdown consistency
- **Coverage check**: Ensures all topics documented

Run locally:

```bash
# Install pre-commit
pip install pre-commit

# Setup hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## 📋 Coverage

See [COVERAGE.md](COVERAGE.md) for complete mapping of topics to labs and files.

## 🤝 Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## 📄 License

Same as parent repository - see [LICENSE](../LICENSE).

## 🆘 Troubleshooting

### Common Issues

**kind cluster fails to create**
- Ensure Docker is running
- Check ports 80/443 are not in use
- Try: `kind delete cluster --name k8s-runbook && ./scripts/kind-up.sh`

**kubectl commands fail**
- Verify context: `kubectl config current-context`
- Check cluster: `kubectl cluster-info`

**Pods stuck in Pending**
- Check nodes: `kubectl get nodes`
- Check events: `kubectl get events --sort-by='.lastTimestamp'`

**ImagePullBackOff errors**
- Expected in some labs demonstrating negative cases
- Check image name spelling
- Verify internet connectivity

## 📚 Additional Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [kind Documentation](https://kind.sigs.k8s.io/)
- [Docker Documentation](https://docs.docker.com/)
- [CNCF Landscape](https://landscape.cncf.io/)

---

**Happy Learning! 🚀**
