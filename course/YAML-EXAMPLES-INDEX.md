# CKA Course YAML Examples - Quick Reference

This document provides a quick reference for all YAML examples in the course.

## 📂 Location

All YAML examples are located in: `course/yaml-examples/`

## 🔗 Module Links

### Module 04: Workloads and Scheduling
**Path**: `yaml-examples/04-workloads-and-scheduling/`

| File | Resource | Description |
|------|----------|-------------|
| 01-pod-nginx.yaml | Pod | Simple nginx pod |
| 02-deployment-web.yaml | Deployment | Web deployment with 3 replicas |
| 03-statefulset-web.yaml | StatefulSet | Ordered pods with persistent storage |
| 04-daemonset-logger.yaml | DaemonSet | Logger running on every node |
| 05-job-pi.yaml | Job | Batch job to calculate pi |
| 06-cronjob-hello.yaml | CronJob | Scheduled job every minute |
| 07-pod-with-liveness-probe.yaml | Pod | Liveness probe example |
| 08-pod-with-readiness-probe.yaml | Pod | Readiness probe example |
| 09-pod-with-startup-probe.yaml | Pod | Startup probe example |
| 10-pod-with-resources.yaml | Pod | Resource requests and limits |
| 11-pod-with-node-selector.yaml | Pod | Node selector for scheduling |
| 12-pod-with-node-affinity.yaml | Pod | Node affinity rules |
| 13-pod-with-toleration.yaml | Pod | Toleration for tainted nodes |

### Module 05: Services and Networking
**Path**: `yaml-examples/05-services-and-networking/`

| File | Resource | Description |
|------|----------|-------------|
| 01-ingress-web-ingress.yaml | Ingress | HTTP ingress for external access |
| 02-networkpolicy-deny-all.yaml | NetworkPolicy | Deny all ingress traffic |
| 03-networkpolicy-allow-frontend.yaml | NetworkPolicy | Allow specific pod access |
| 04-service-clusterip.yaml | Service | ClusterIP (internal only) |
| 05-service-nodeport.yaml | Service | NodePort (external static port) |
| 06-service-loadbalancer.yaml | Service | LoadBalancer (cloud provider) |

### Module 06: Storage and State
**Path**: `yaml-examples/06-storage-and-state/`

| File | Resource | Description |
|------|----------|-------------|
| 01-persistentvolume-pv-local.yaml | PersistentVolume | Local PV for development |
| 02-persistentvolumeclaim-pvc-local.yaml | PVC | PVC binding to PV |
| 03-storageclass-fast.yaml | StorageClass | Dynamic provisioning |
| 04-persistentvolumeclaim-pvc-dynamic.yaml | PVC | Dynamic PVC |
| 05-pod-app.yaml | Pod | Pod mounting a PVC |
| 06-statefulset-postgres.yaml | StatefulSet | PostgreSQL with storage |

### Module 07: RBAC and Security
**Path**: `yaml-examples/07-rbac-and-security/`

| File | Resource | Description |
|------|----------|-------------|
| 01-pod-app.yaml | Pod | Pod with ServiceAccount |
| 02-role-pod-reader.yaml | Role | Pod read permissions |
| 03-rolebinding-read-pods.yaml | RoleBinding | Bind role to ServiceAccount |
| 04-pod-secure-pod.yaml | Pod | Pod with security context |
| 05-secret-db-credentials.yaml | Secret | Database credentials |
| 06-pod-with-secret-env.yaml | Pod | Secret as environment variables |
| 07-pod-with-secret-volume.yaml | Pod | Secret as volume mount |
| 08-secret-docker-registry.yaml | Secret | Docker registry credentials |
| 09-pod-with-image-pull-secret.yaml | Pod | Using ImagePullSecret |

### Module 11: Exam Practice Drills
**Path**: `yaml-examples/11-exam-practice-drills/`

| File | Resource | Description |
|------|----------|-------------|
| 01-persistentvolume-pv1.yaml | PersistentVolume | Exam practice PV |
| 02-persistentvolumeclaim-pvc1.yaml | PVC | Exam practice PVC |
| 03-pod-pod-with-pvc.yaml | Pod | Pod with storage practice |
| 04-networkpolicy-backend-policy.yaml | NetworkPolicy | Backend access restriction |
| 05-pod-multi-container.yaml | Pod | Sidecar pattern example |
| 06-resourcequota-quota.yaml | ResourceQuota | Namespace resource limits |

## 💡 Usage Tips

### Apply a specific example
```bash
kubectl apply -f yaml-examples/04-workloads-and-scheduling/01-pod-nginx.yaml
```

### Apply all examples from a module
```bash
kubectl apply -f yaml-examples/04-workloads-and-scheduling/
```

### View an example before applying
```bash
cat yaml-examples/05-services-and-networking/04-service-clusterip.yaml
```

### Generate similar YAML (CKA exam approach)
```bash
# Instead of copying, practice generating:
kubectl run nginx --image=nginx --dry-run=client -o yaml
kubectl create deployment web --image=nginx --replicas=3 --dry-run=client -o yaml
```

## 🎯 Study Strategy

1. **Read the course module** first to understand concepts
2. **Review the corresponding YAML examples** to see implementations
3. **Practice typing** the commands to generate similar YAML
4. **Apply the examples** to a test cluster
5. **Verify** the resources are working correctly
6. **Troubleshoot** any issues that arise

## ✅ Validation

All 40 YAML files have been validated for:
- ✓ Correct YAML syntax
- ✓ Valid Kubernetes resource definitions
- ✓ Complete manifests (no fragments)
- ✓ Descriptive header comments

## 📚 Related Resources

- **Main README**: `README.md` in yaml-examples directory
- **Course Modules**: `course/[module-number]-[module-name].md`
- **kubectl Cheatsheet**: `cheatsheets/kubectl-cheatsheet.md`
- **YAML Snippets**: `cheatsheets/yaml-snippets.md`

---

**Ready to practice? Start with Module 04 and work your way through! 🚀**
