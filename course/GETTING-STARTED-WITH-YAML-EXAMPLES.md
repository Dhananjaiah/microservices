# Getting Started with CKA YAML Examples

This guide shows you how to quickly start using the YAML examples for hands-on practice.

## 🚀 Quick Start (5 minutes)

If you have a Kubernetes cluster running, try these examples immediately:

### 1. Deploy Your First Pod
```bash
kubectl apply -f course/yaml-examples/04-workloads-and-scheduling/01-pod-nginx.yaml
kubectl get pods
kubectl describe pod nginx
```

### 2. Create a Deployment
```bash
kubectl apply -f course/yaml-examples/04-workloads-and-scheduling/02-deployment-web.yaml
kubectl get deployments
kubectl get pods -l app=web
```

### 3. Expose with a Service
```bash
kubectl apply -f course/yaml-examples/05-services-and-networking/04-service-clusterip.yaml
kubectl get services
```

### 4. Test the Service
```bash
kubectl run test --image=busybox --rm -it --restart=Never -- wget -O- http://web-clusterip
```

### 5. Clean Up
```bash
kubectl delete -f course/yaml-examples/04-workloads-and-scheduling/01-pod-nginx.yaml
kubectl delete -f course/yaml-examples/04-workloads-and-scheduling/02-deployment-web.yaml
kubectl delete -f course/yaml-examples/05-services-and-networking/04-service-clusterip.yaml
```

## 📚 Learning Path

### Week 1: Workloads
Practice all examples in `04-workloads-and-scheduling/`:
1. Start with pods (01-06)
2. Add health checks (07-09)
3. Configure resources (10)
4. Control scheduling (11-13)

### Week 2: Networking
Practice all examples in `05-services-and-networking/`:
1. Create different service types (04-06)
2. Set up ingress (01)
3. Apply network policies (02-03)

### Week 3: Storage
Practice all examples in `06-storage-and-state/`:
1. Create PVs and PVCs (01-04)
2. Use storage in pods (05)
3. Deploy StatefulSet (06)

### Week 4: Security
Practice all examples in `07-rbac-and-security/`:
1. Set up RBAC (01-03)
2. Apply pod security (04)
3. Work with secrets (05-09)

### Week 5: Exam Practice
Practice all examples in `11-exam-practice-drills/`:
- Complete each example under time pressure
- Practice without referring to solutions

## 🎯 Exam Simulation

Time yourself completing these tasks:

### Task 1 (5 min): Deploy StatefulSet with Storage
```bash
kubectl apply -f course/yaml-examples/06-storage-and-state/01-persistentvolume-pv-local.yaml
kubectl apply -f course/yaml-examples/06-storage-and-state/06-statefulset-postgres.yaml
kubectl get statefulset
kubectl get pvc
```

### Task 2 (5 min): Create RBAC
```bash
kubectl create serviceaccount app-sa
kubectl apply -f course/yaml-examples/07-rbac-and-security/02-role-pod-reader.yaml
kubectl apply -f course/yaml-examples/07-rbac-and-security/03-rolebinding-read-pods.yaml
kubectl auth can-i list pods --as=system:serviceaccount:default:app-sa
```

### Task 3 (5 min): Network Policy
```bash
kubectl apply -f course/yaml-examples/05-services-and-networking/02-networkpolicy-deny-all.yaml
kubectl run test --image=nginx --labels=app=frontend
kubectl apply -f course/yaml-examples/05-services-and-networking/03-networkpolicy-allow-frontend.yaml
```

## 💡 Pro Tips

### 1. Don't Just Copy-Paste
Type the commands manually to build muscle memory for the exam.

### 2. Use Dry-Run
Practice generating YAML instead of copying:
```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml > my-pod.yaml
```

### 3. Understand, Don't Memorize
Read the 2-line description in each file header to understand what it does.

### 4. Verify Everything
Always check that resources are working:
```bash
kubectl get all
kubectl describe <resource> <name>
kubectl logs <pod>
```

### 5. Practice Cleanup
Get comfortable deleting resources:
```bash
kubectl delete -f <file>
kubectl delete <resource> <name>
```

## 🔧 Common Workflows

### Workflow 1: Full Application Stack
```bash
# 1. Create namespace
kubectl create namespace myapp

# 2. Deploy backend with storage
kubectl apply -f course/yaml-examples/06-storage-and-state/01-persistentvolume-pv-local.yaml
kubectl apply -f course/yaml-examples/06-storage-and-state/06-statefulset-postgres.yaml -n myapp

# 3. Deploy frontend
kubectl apply -f course/yaml-examples/04-workloads-and-scheduling/02-deployment-web.yaml -n myapp

# 4. Expose services
kubectl apply -f course/yaml-examples/05-services-and-networking/04-service-clusterip.yaml -n myapp

# 5. Apply security
kubectl apply -f course/yaml-examples/05-services-and-networking/02-networkpolicy-deny-all.yaml -n myapp
kubectl apply -f course/yaml-examples/05-services-and-networking/03-networkpolicy-allow-frontend.yaml -n myapp
```

### Workflow 2: Scheduled Jobs
```bash
# Create a CronJob
kubectl apply -f course/yaml-examples/04-workloads-and-scheduling/06-cronjob-hello.yaml

# Watch jobs being created
kubectl get cronjobs
kubectl get jobs --watch

# View logs from completed job
kubectl logs job/hello-<timestamp>
```

### Workflow 3: Security Hardening
```bash
# 1. Create ServiceAccount
kubectl create serviceaccount secure-app

# 2. Create Role and RoleBinding
kubectl apply -f course/yaml-examples/07-rbac-and-security/02-role-pod-reader.yaml
kubectl apply -f course/yaml-examples/07-rbac-and-security/03-rolebinding-read-pods.yaml

# 3. Create Secret
kubectl apply -f course/yaml-examples/07-rbac-and-security/05-secret-db-credentials.yaml

# 4. Deploy secure pod
kubectl apply -f course/yaml-examples/07-rbac-and-security/04-pod-secure-pod.yaml

# 5. Verify RBAC
kubectl auth can-i list pods --as=system:serviceaccount:default:app-sa
```

## 📊 Track Your Progress

Create a checklist and mark off each example as you complete it:

- [ ] Module 04: All 13 workload examples
- [ ] Module 05: All 6 networking examples
- [ ] Module 06: All 6 storage examples
- [ ] Module 07: All 9 security examples
- [ ] Module 11: All 6 exam drills

## 🎓 Next Steps

After mastering these examples:

1. **Complete the course modules** - Read the full documentation
2. **Build the FoodCart project** - Apply everything end-to-end
3. **Take mock exams** - Test your speed and accuracy
4. **Schedule your CKA exam** - When you score 90%+ consistently

## 🆘 Troubleshooting

### Example Won't Apply
```bash
# Validate syntax
kubectl apply --dry-run=client -f <file>

# Check cluster connection
kubectl cluster-info

# View detailed error
kubectl apply -f <file> -v=9
```

### Resource Not Working
```bash
# Check status
kubectl get <resource> <name> -o yaml

# View events
kubectl get events --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod>

# Describe for details
kubectl describe <resource> <name>
```

---

**Ready to master Kubernetes? Start practicing now! 🚀**

For detailed information about each example, see:
- [YAML Examples README](yaml-examples/README.md)
- [YAML Examples Index](YAML-EXAMPLES-INDEX.md)
