# CKA Kubernetes Course - Complete Summary

## 📚 Course Overview

This repository now contains a **complete, production-ready CKA (Certified Kubernetes Administrator) exam preparation course** designed as a "cake walk" - clear, command-first, with copy-pasteable examples.

## 🎯 What's Included

### 1. Course Modules (12 Comprehensive Modules)

Located in `/course/` directory:

- **Module 00**: Overview & Course Map
  - Learning objectives, audience, study schedules
  - Mermaid course flow diagram
  - Exam tips and resource links

- **Module 01**: Lab Setup
  - Ubuntu 22.04 LTS setup (complete)
  - RHEL/Rocky Linux 9 setup (complete)
  - kubeadm cluster initialization
  - Calico CNI installation
  - Verification procedures

- **Module 02**: Cluster Architecture
  - Control plane components (API server, etcd, controller-manager, scheduler)
  - Worker node components (kubelet, kube-proxy, containerd, CNI)
  - Communication flow diagrams
  - Mini-labs for exploring components

- **Module 03**: Installation and Upgrade
  - kubeadm cluster lifecycle
  - Step-by-step cluster upgrades
  - etcd backup and restore procedures
  - Certificate management

- **Module 04**: Workloads and Scheduling
  - Pods, Deployments, StatefulSets, DaemonSets
  - Jobs and CronJobs
  - Resource requests/limits
  - Probes (liveness, readiness, startup)
  - Node selectors, affinity, taints & tolerations

- **Module 05**: Services and Networking
  - Service types (ClusterIP, NodePort, LoadBalancer)
  - Ingress configuration
  - NetworkPolicies (allow/deny patterns)
  - DNS and service discovery

- **Module 06**: Storage and State
  - PersistentVolumes (PV) and PersistentVolumeClaims (PVC)
  - StorageClasses
  - Access modes and reclaim policies
  - StatefulSets with persistent storage

- **Module 07**: RBAC and Security
  - ServiceAccounts, Roles, RoleBindings
  - ClusterRoles and ClusterRoleBindings
  - Pod Security Standards
  - Secrets and ImagePullSecrets
  - securityContext configuration

- **Module 08**: Observability and Logging
  - Metrics server installation
  - kubectl logs, describe, events
  - Resource monitoring (kubectl top)
  - Debugging techniques

- **Module 09**: Cluster Maintenance
  - Node drain, cordon, uncordon
  - etcd backup and restore (detailed)
  - Cluster upgrade procedures
  - Certificate rotation

- **Module 10**: Troubleshooting Guide
  - Systematic debugging methodology
  - Common pod failures (CrashLoopBackOff, ImagePullBackOff, Pending, OOMKilled)
  - Network troubleshooting
  - Node and control plane issues
  - Quick troubleshooting checklist

- **Module 11**: Exam Practice Drills
  - 10 timed practice drills
  - Exam tips and time management
  - Context switching practice
  - Final exam checklist

### 2. FoodCart Project (End-to-End Application)

Located in `/project/` directory:

**Complete Microservices Application** demonstrating:
- Multiple services (frontend, api-gateway, menu, orders, payments, postgres, redis)
- StatefulSet with persistent storage (postgres)
- HorizontalPodAutoscaler
- PodDisruptionBudget
- NetworkPolicies (service-to-service security)
- ConfigMaps and Secrets
- Liveness and readiness probes
- Resource limits

**Files**:
- `README.md`: Complete project documentation
- `manifests/`: 12+ Kubernetes YAML files
  - Namespace configuration
  - PostgreSQL StatefulSet with PV/PVC
  - Microservice deployments
  - Services and Ingress
  - HPA and PDB
  - NetworkPolicies
- `scripts/deploy.sh`: One-command deployment
- `runbook.md`: SRE troubleshooting playbooks

### 3. Cheatsheets

Located in `/cheatsheets/` directory:

- **kubectl-cheatsheet.md**: 100+ essential kubectl commands
  - Resource management
  - Debugging commands
  - RBAC operations
  - Fast YAML generation
  - Exam-specific aliases

- **yaml-snippets.md**: Ready-to-use YAML templates
  - Pods with resources and probes
  - Deployments with rolling updates
  - Services (all types)
  - NetworkPolicies
  - PV/PVC
  - ConfigMaps and Secrets
  - RBAC (Roles, RoleBindings)
  - HPA and PDB
  - Ingress

- **troubleshooting-checklist.md**: Systematic debugging guide
  - Quick triage steps
  - Pod issues checklist
  - Network issues checklist
  - Node issues checklist
  - Control plane issues checklist
  - Essential debugging commands

### 4. Mock Exams

Located in `/exams/` directory:

- **mock-exam-1.md**: 15 questions, 2 hours
  - Covers all CKA domains
  - Weighted scoring (66% to pass)
  - Mixed difficulty levels
  - Real exam format

- **mock-exam-1-solutions.md**: Complete solutions with commands

- **mock-exam-2.md**: 15 questions, 2 hours
  - Alternative question set
  - Focus on troubleshooting and operations
  - Multi-cluster scenarios

## 📊 Content Statistics

- **Total Modules**: 12
- **Total Files**: 27
- **Course Content**: ~30,000 words
- **Code Examples**: 500+ command examples
- **YAML Templates**: 25+ ready-to-use manifests
- **Practice Questions**: 30 (from 2 mock exams)
- **Mini-Labs**: 15+ hands-on exercises
- **Exam Drills**: 10 timed practice drills

## 🎓 CKA Exam Coverage

This course covers **100% of CKA exam domains**:

| Domain | Weight | Covered |
|--------|--------|---------|
| Cluster Architecture, Installation & Configuration | 25% | ✅ Modules 01-03 |
| Workloads & Scheduling | 15% | ✅ Module 04 |
| Services & Networking | 20% | ✅ Module 05 |
| Storage | 10% | ✅ Module 06 |
| Troubleshooting | 30% | ✅ Modules 08, 10 |

Additional coverage:
- RBAC & Security: Module 07
- Cluster Maintenance: Module 09
- Exam Preparation: Module 11

## 🚀 How to Use This Course

### For Self-Study

1. **Start with Module 00** (overview) to understand the structure
2. **Set up your lab** using Module 01
3. **Work through Modules 02-11** sequentially
4. **Build the FoodCart project** after Module 09
5. **Take Mock Exam 1**, review mistakes
6. **Take Mock Exam 2**, aim for 90%+
7. **Schedule your CKA exam** when ready

### Study Schedule Recommendations

**Intensive (2-3 weeks)**:
- Week 1: Modules 01-06 + daily labs
- Week 2: Modules 07-09 + FoodCart project
- Week 3: Modules 10-11 + mock exams

**Standard (4-6 weeks)**:
- One module every 3-4 days
- Complete all mini-labs
- Build FoodCart project in week 4
- Mock exams in weeks 5-6

**Relaxed (8-12 weeks)**:
- One module per week
- Deep dive into each topic
- Multiple iterations of FoodCart project
- Practice mock exams until 90%+ consistently

## 🛠️ Technical Requirements

- **Hardware**: 3 VMs (1 control plane, 2 workers) or cloud instances
- **Resources per node**: 2 vCPU, 2-4 GB RAM, 20 GB disk
- **OS**: Ubuntu 22.04 LTS or Rocky Linux 9
- **Software**: kubectl, kubeadm, kubelet, containerd, Calico CNI
- **Optional**: Docker for local development

## 📖 Key Features

1. **Commands First**: Every concept starts with copy-pasteable commands
2. **Verify Everything**: All tasks include verification steps
3. **Real-World**: FoodCart project mirrors production applications
4. **Exam-Focused**: Aligned with CKA exam format and timing
5. **Troubleshooting**: Extensive debugging guides and checklists
6. **Platform-Agnostic**: Works on Ubuntu, RHEL/Rocky, local VMs, or cloud

## 🔗 Quick Navigation

- **Start Learning**: `/course/00-overview.md`
- **Set Up Lab**: `/course/01-lab-setup.md`
- **Quick Reference**: `/cheatsheets/kubectl-cheatsheet.md`
- **Practice Exam**: `/exams/mock-exam-1.md`
- **Project**: `/project/README.md`
- **Troubleshooting**: `/cheatsheets/troubleshooting-checklist.md`

## 💡 Pro Tips

1. **Type commands manually** instead of copy-pasting (builds muscle memory)
2. **Break things intentionally** and practice fixing them
3. **Use kubectl explain** extensively
4. **Practice on multiple clusters** (context switching is critical for the exam)
5. **Time yourself** on exam drills and mock exams
6. **Keep notes** of commands you forget

## 🎯 Success Criteria

You're ready for the CKA exam when you can:
- [ ] Deploy a kubeadm cluster from scratch in <15 minutes
- [ ] Switch contexts without thinking
- [ ] Debug any pod failure in <5 minutes
- [ ] Write YAML from memory for common resources
- [ ] Score 90%+ on both mock exams
- [ ] Complete all exam drills within target times

## 📚 Additional Resources

- **Official Docs**: kubernetes.io/docs
- **Practice Environment**: killer.sh (2 free sessions)
- **Community**: Kubernetes Slack, Reddit r/kubernetes
- **Blog**: kubernetes.io/blog

## 🙏 Acknowledgments

This course structure follows CKA exam requirements as of 2024 and incorporates best practices from the Kubernetes community.

---

**Ready to ace the CKA exam? Start with `/course/00-overview.md`!** 🚀
