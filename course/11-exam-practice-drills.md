# Module 11 — Exam Practice Drills

## 🎯 Goals

- **Practice CKA-style tasks** under time pressure
- **Build speed and accuracy** with kubectl commands
- **Master context switching** and multi-cluster scenarios

## ⏱️ Exam Format

- **Duration**: 2 hours
- **Questions**: 15-20 performance-based tasks
- **Passing Score**: 66%
- **Environment**: Remote desktop, kubectl, vim/nano, browser (kubernetes.io docs only)
- **Multiple clusters**: 4-8 clusters, must switch contexts

## 🎓 Exam Tips

### Before the Exam
1. **Practice typing kubectl commands** without autocomplete
2. **Bookmark important pages** (RBAC, NetworkPolicy, PV/PVC, etc.)
3. **Set up aliases** in .bashrc (allowed in exam)
4. **Know how to generate YAML** with --dry-run=client -o yaml
5. **Practice on multiple clusters** (context switching!)

### During the Exam
1. **Read questions carefully** → check namespace, context, cluster!
2. **Do easy questions first** → build confidence, save time
3. **Always switch context** before starting a question
4. **Verify your work** → kubectl get/describe after every change
5. **Skip and return** → don't spend 20 min on one question
6. **Use imperative commands** when possible (faster than YAML)

### Time Management
- **2 min average per question** (but varies widely)
- **Easy questions**: 1-3 min (create deployment, scale, expose)
- **Medium questions**: 5-8 min (RBAC, NetworkPolicy, troubleshooting)
- **Hard questions**: 10-15 min (cluster upgrade, etcd backup/restore, complex debugging)

## 🚀 Speed Drills (Timed)

### Drill 1: Create Resources (5 minutes)

**Tasks**:
1. Create namespace `practice`
2. Create deployment `web` with nginx:1.21, 3 replicas, in namespace `practice`
3. Expose deployment as NodePort service on port 80
4. Scale deployment to 5 replicas

**Commands**:
```bash
kubectl create namespace practice
kubectl create deployment web --image=nginx:1.21 --replicas=3 -n practice
kubectl expose deployment web --port=80 --type=NodePort -n practice
kubectl scale deployment web --replicas=5 -n practice
```

**Verify**:
```bash
kubectl get all -n practice
```

---

### Drill 2: RBAC Setup (7 minutes)

**Tasks**:
1. Create ServiceAccount `app-sa` in namespace `default`
2. Create Role `pod-reader` that can get, list, watch pods
3. Bind the role to the ServiceAccount
4. Verify the ServiceAccount can list pods

**Commands**:
```bash
kubectl create serviceaccount app-sa
kubectl create role pod-reader --verb=get,list,watch --resource=pods
kubectl create rolebinding app-read-pods --role=pod-reader --serviceaccount=default:app-sa
kubectl auth can-i list pods --as=system:serviceaccount:default:app-sa
```

---

### Drill 3: Storage (7 minutes)

**Tasks**:
1. Create a PV with 1Gi capacity, hostPath `/mnt/data`, accessMode ReadWriteOnce
2. Create a PVC requesting 500Mi
3. Create a pod that mounts the PVC at `/data`

**PV**:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
```

**PVC**:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

**Pod**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-pvc
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc1
```

---

### Drill 4: Troubleshooting (10 minutes)

**Scenario**: A deployment's pods are in CrashLoopBackOff.

**Tasks**:
1. Identify the issue
2. Fix the deployment
3. Verify pods are running

**Debug Steps**:
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
```

**Common fixes**:
```bash
# Fix image
kubectl set image deployment/<name> container=nginx:1.21

# Add env var
kubectl set env deployment/<name> REQUIRED_VAR=value

# Increase resources
kubectl set resources deployment/<name> --limits=memory=512Mi
```

---

### Drill 5: NetworkPolicy (8 minutes)

**Tasks**:
1. Create a NetworkPolicy that denies all ingress traffic to pods with label `app=backend`
2. Add a rule to allow traffic only from pods with label `app=frontend` on port 8080

**NetworkPolicy**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

**Test**:
```bash
# Should work
kubectl run frontend --image=busybox --labels="app=frontend" --restart=Never --rm -it -- nc -zv backend-service 8080

# Should fail
kubectl run other --image=busybox --restart=Never --rm -it -- nc -zv backend-service 8080
```

---

### Drill 6: Node Maintenance (5 minutes)

**Tasks**:
1. Drain worker node `w1` safely
2. Verify no non-DaemonSet pods running on it
3. Uncordon the node

**Commands**:
```bash
kubectl drain w1 --ignore-daemonsets --delete-emptydir-data
kubectl get pods -o wide | grep w1
kubectl uncordon w1
```

---

### Drill 7: etcd Backup (5 minutes)

**Task**: Create an etcd snapshot at `/tmp/etcd-backup.db`

**Command** (on control plane):
```bash
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup.db --write-out=table
```

---

### Drill 8: Multi-Container Pod (5 minutes)

**Task**: Create a pod with two containers: nginx and busybox (sidecar)

**Pod**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container
spec:
  containers:
  - name: nginx
    image: nginx
  - name: sidecar
    image: busybox
    command: ["sh", "-c", "while true; do echo $(date); sleep 5; done"]
```

**Verify**:
```bash
kubectl logs multi-container -c nginx
kubectl logs multi-container -c sidecar
```

---

### Drill 9: Resource Quotas (7 minutes)

**Tasks**:
1. Create namespace `limited`
2. Create ResourceQuota: max 2 pods, 1 CPU, 1Gi memory
3. Try to create 3 pods (third should fail)

**ResourceQuota**:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota
  namespace: limited
spec:
  hard:
    pods: "2"
    requests.cpu: "1"
    requests.memory: 1Gi
```

---

### Drill 10: Context Switching (2 minutes)

**Critical for exam!**

**Tasks**:
1. List all contexts
2. Switch to context `cluster2`
3. Verify current context

**Commands**:
```bash
kubectl config get-contexts
kubectl config use-context cluster2
kubectl config current-context
```

**Pro tip**: Start every exam question by verifying context!

---

## 📚 Practice Recommendations

### Week Before Exam
1. **Do 2-3 drills per day** from above
2. **Time yourself** — aim to beat target times
3. **Practice on killer.sh** (free CKA simulator, 2 sessions with registration)
4. **Review Module 10** (Troubleshooting) thoroughly

### Day Before Exam
1. **Rest!** Don't cram
2. **Review kubectl cheatsheet** (Module cheatsheets/kubectl-cheatsheet.md)
3. **Test your internet and computer** for remote exam
4. **Prepare your workspace** (clean desk, no distractions)

### During Exam
1. **Stay calm** — you've practiced!
2. **Read carefully** — context, namespace, cluster
3. **Skip hard questions** — come back later
4. **Verify everything** — kubectl get/describe
5. **Use time wisely** — 2 hours goes fast!

---

## 🎯 Final Exam Checklist

- [ ] Practiced all 10 drills above until confident
- [ ] Can switch contexts without thinking
- [ ] Know kubectl imperative commands by heart
- [ ] Can generate YAML with --dry-run=client -o yaml
- [ ] Familiar with kubernetes.io docs navigation
- [ ] Completed killer.sh practice exams (or similar)
- [ ] Completed Mock Exam 1 and 2 (in /exams/)
- [ ] Reviewed common mistakes from all modules
- [ ] Set up .bashrc aliases for exam
- [ ] Rested and ready!

---

## 💪 Motivation

You've completed the course! You have all the knowledge and skills needed to pass the CKA exam. The drills above simulate real exam questions. Practice them until they feel easy, then take the mock exams in `/exams/`. When you consistently score 90%+, you're ready.

**Remember**:
- **Speed comes with practice** — don't worry if you're slow at first
- **The exam is passable** — 66% is achievable with practice
- **Mistakes are learning** — review what you got wrong
- **You got this!** 🚀

---

**Next**: Take Mock Exams 1 and 2 in `/exams/`
