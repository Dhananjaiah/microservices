# CKA Course - YAML Examples

This directory contains complete, ready-to-use YAML manifests for all Kubernetes resources covered in the CKA course.

## 📂 Directory Structure

Each module has its own subdirectory with relevant YAML examples:

```
yaml-examples/
├── 04-workloads-and-scheduling/    # Pods, Deployments, Jobs, Scheduling
├── 05-services-and-networking/     # Services, Ingress, NetworkPolicies
├── 06-storage-and-state/           # PV, PVC, StorageClass, StatefulSets
├── 07-rbac-and-security/           # RBAC, ServiceAccounts, Secrets
└── 11-exam-practice-drills/        # CKA exam practice scenarios
```

## 🎯 How to Use These Files

### Apply a Single Resource
```bash
kubectl apply -f 04-workloads-and-scheduling/01-pod-nginx.yaml
```

### Apply All Resources in a Module
```bash
kubectl apply -f 04-workloads-and-scheduling/
```

### Delete Resources
```bash
kubectl delete -f 04-workloads-and-scheduling/01-pod-nginx.yaml
```

### View Resource Before Applying
```bash
cat 04-workloads-and-scheduling/01-pod-nginx.yaml
```

## 📋 Module 04: Workloads and Scheduling

### Basic Workloads
- **01-pod-nginx.yaml** - Simple nginx pod
- **02-deployment-web.yaml** - Deployment with 3 replicas
- **03-statefulset-web.yaml** - StatefulSet with persistent storage
- **04-daemonset-logger.yaml** - DaemonSet running on every node
- **05-job-pi.yaml** - Batch job to calculate pi
- **06-cronjob-hello.yaml** - Scheduled job running every minute

### Health Checks
- **07-pod-with-liveness-probe.yaml** - Liveness probe example
- **08-pod-with-readiness-probe.yaml** - Readiness probe example
- **09-pod-with-startup-probe.yaml** - Startup probe example

### Resource Management
- **10-pod-with-resources.yaml** - Resource requests and limits

### Pod Scheduling
- **11-pod-with-node-selector.yaml** - Simple node selection
- **12-pod-with-node-affinity.yaml** - Advanced node affinity
- **13-pod-with-toleration.yaml** - Toleration for tainted nodes

## 🌐 Module 05: Services and Networking

### Service Types
- **01-ingress-web-ingress.yaml** - HTTP ingress for external access
- **04-service-clusterip.yaml** - ClusterIP service (internal only)
- **05-service-nodeport.yaml** - NodePort service (external on static port)
- **06-service-loadbalancer.yaml** - LoadBalancer service (cloud provider)

### Network Security
- **02-networkpolicy-deny-all.yaml** - Deny all ingress traffic
- **03-networkpolicy-allow-frontend.yaml** - Allow specific pod access

## 💾 Module 06: Storage and State

### Persistent Volumes
- **01-persistentvolume-pv-local.yaml** - Local PersistentVolume
- **02-persistentvolumeclaim-pvc-local.yaml** - PVC binding to PV
- **03-storageclass-fast.yaml** - StorageClass for dynamic provisioning
- **04-persistentvolumeclaim-pvc-dynamic.yaml** - Dynamic PVC

### Using Storage
- **05-pod-app.yaml** - Pod mounting a PVC
- **06-statefulset-postgres.yaml** - PostgreSQL with persistent storage

## 🔐 Module 07: RBAC and Security

### RBAC
- **01-pod-app.yaml** - Pod with custom ServiceAccount
- **02-role-pod-reader.yaml** - Role with pod read permissions
- **03-rolebinding-read-pods.yaml** - RoleBinding to ServiceAccount

### Pod Security
- **04-pod-secure-pod.yaml** - Pod with security context

### Secrets
- **05-example-db-user.yaml** - Secret for database credentials
- **06-example-secret-volume.yaml** - Pod mounting secret as volume

## ✅ Module 11: Exam Practice Drills

### Storage Practice
- **01-persistentvolume-pv1.yaml** - PV for exam practice
- **02-persistentvolumeclaim-pvc1.yaml** - PVC for exam practice
- **03-pod-pod-with-pvc.yaml** - Pod with storage

### Networking Practice
- **04-networkpolicy-backend-policy.yaml** - Backend access restriction

### Multi-Container Practice
- **05-pod-multi-container.yaml** - Sidecar pattern example

### Resource Management
- **06-resourcequota-quota.yaml** - Namespace resource quota

## 🎓 Exam Tips

### Using These Examples in the CKA Exam

1. **Don't memorize** - Understand the structure and adapt
2. **Use kubectl create --dry-run** - Generate YAML quickly
3. **Bookmark kubernetes.io/docs** - Reference documentation is allowed
4. **Practice typing** - Build muscle memory for common patterns

### Quick Generation Commands

Instead of copying these files, practice generating them:

```bash
# Generate pod YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml

# Generate deployment YAML
kubectl create deployment web --image=nginx --replicas=3 --dry-run=client -o yaml

# Generate service YAML
kubectl create service clusterip web --tcp=80:80 --dry-run=client -o yaml

# Generate role YAML
kubectl create role pod-reader --verb=get,list,watch --resource=pods --dry-run=client -o yaml
```

## 🔧 Validation

All YAML files in this directory:
- ✅ Are syntactically valid
- ✅ Follow Kubernetes best practices
- ✅ Include 2-line descriptions in header comments
- ✅ Are tested and working examples

## 📝 File Naming Convention

Files follow this pattern:
```
[number]-[resource-type]-[resource-name].yaml
```

Examples:
- `01-pod-nginx.yaml`
- `02-deployment-web.yaml`
- `03-service-clusterip.yaml`

## 🚀 Quick Start

Try this workflow to get started:

```bash
# 1. Create a simple pod
kubectl apply -f 04-workloads-and-scheduling/01-pod-nginx.yaml

# 2. Verify it's running
kubectl get pods

# 3. Expose it as a service
kubectl apply -f 05-services-and-networking/04-service-clusterip.yaml

# 4. Test the service
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- http://web-clusterip

# 5. Clean up
kubectl delete -f 04-workloads-and-scheduling/01-pod-nginx.yaml
kubectl delete -f 05-services-and-networking/04-service-clusterip.yaml
```

## 💡 Learning Path

1. **Start with Module 04** - Master basic workloads
2. **Move to Module 05** - Understand networking
3. **Practice Module 06** - Get comfortable with storage
4. **Secure with Module 07** - Learn RBAC and security
5. **Test with Module 11** - Practice exam scenarios

## 🆘 Troubleshooting

If a YAML file doesn't work:

1. **Check syntax**: `kubectl apply --dry-run=client -f <file>`
2. **View events**: `kubectl get events --sort-by='.lastTimestamp'`
3. **Describe resource**: `kubectl describe <resource-type> <resource-name>`
4. **Check logs**: `kubectl logs <pod-name>`

## 📚 Additional Resources

- **Course Modules**: `../[module-number]-[module-name].md`
- **kubectl Cheatsheet**: `../../cheatsheets/kubectl-cheatsheet.md`
- **YAML Snippets**: `../../cheatsheets/yaml-snippets.md`
- **Official Docs**: https://kubernetes.io/docs/

---

**Ready to practice? Start applying these YAMLs and master Kubernetes! 🚀**
