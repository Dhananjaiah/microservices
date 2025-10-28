# CKA Mock Exam 2

## ⏱️ Time Limit: 2 Hours
## 📊 Passing Score: 66% (10/15 questions)

**Focus**: Mixed operations, troubleshooting, and real-world scenarios

---

## Question 1 (5%) - Context Switching & Resource Creation

**Context**: `kubernetes-admin@cluster3`

**Tasks**:
1. Switch to the correct context
2. Create a namespace `app-prod`
3. Set the default namespace to `app-prod` for the current context

**Verification**:
```bash
kubectl config current-context
kubectl config get-contexts
# default namespace should be app-prod
```

---

## Question 2 (8%) - Cluster Backup

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Take a complete etcd backup
2. Save to `/opt/etcd-backup.db`
3. Verify the backup contains data

**Verification**:
```bash
ETCDCTL_API=3 etcdctl snapshot status /opt/etcd-backup.db --write-out=table
```

---

## Question 3 (6%) - Pod with Security Context

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a pod named `secure-pod` in namespace `default`:
   - Image: nginx
   - Run as user ID 1000
   - Run as non-root
   - Read-only root filesystem
   - Drop all capabilities

**Verification**:
```bash
kubectl get pod secure-pod
kubectl exec secure-pod -- id
# Should show uid=1000
```

---

## Question 4 (7%) - Troubleshoot DNS

**Context**: `kubernetes-admin@cluster2`

**Scenario**: Pods cannot resolve service names via DNS.

**Tasks**:
1. Identify the DNS issue
2. Fix CoreDNS
3. Verify DNS resolution works

**Verification**:
```bash
kubectl run test --image=busybox --restart=Never --rm -it -- nslookup kubernetes.default
# Should resolve successfully
```

---

## Question 5 (6%) - Job and CronJob

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a Job named `pi-job` that calculates pi to 2000 digits (use perl image)
2. Create a CronJob named `cleanup` that runs every day at 2 AM:
   - Image: busybox
   - Command: `echo "Cleaning up..."`

**Verification**:
```bash
kubectl get jobs
kubectl get cronjobs
kubectl logs job/pi-job
```

---

## Question 6 (8%) - Upgrade Worker Node

**Context**: `kubernetes-admin@cluster2`

**Scenario**: Upgrade worker node `worker-2` from v1.27.0 to v1.28.0.

**Tasks**:
1. Drain the node
2. Upgrade kubeadm, kubelet, and kubectl on the node
3. Uncordon the node
4. Verify node is running v1.28.0

**Verification**:
```bash
kubectl get nodes
# worker-2 should show v1.28.0 and Ready
```

---

## Question 7 (7%) - Resource Quotas and Limits

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create namespace `limited-ns`
2. Create a ResourceQuota:
   - Max 3 pods
   - Max 2 CPU cores (requests)
   - Max 2Gi memory (requests)
3. Create a LimitRange:
   - Default CPU request: 100m
   - Default memory request: 128Mi
4. Try creating 4 pods (4th should fail)

**Verification**:
```bash
kubectl describe resourcequota -n limited-ns
kubectl describe limitrange -n limited-ns
```

---

## Question 8 (5%) - Service Discovery

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create deployment `backend` (nginx, 2 replicas)
2. Expose as ClusterIP service named `backend-svc`
3. Create deployment `frontend` with environment variable `BACKEND_URL=http://backend-svc`
4. Verify frontend can reach backend via service name

**Verification**:
```bash
kubectl exec deployment/frontend -- curl http://backend-svc
```

---

## Question 9 (8%) - Troubleshoot Networking

**Context**: `kubernetes-admin@cluster2`

**Scenario**: Pod `app-1` cannot reach pod `app-2` due to NetworkPolicy.

**Tasks**:
1. Review existing NetworkPolicies
2. Modify or create policies to allow traffic
3. Verify connectivity works

**Verification**:
```bash
kubectl exec app-1 -- curl http://app-2-service
# Should succeed
```

---

## Question 10 (7%) - Static Pod

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. On node `worker-1`, create a static pod named `static-web`:
   - Image: nginx
   - Manifest location: `/etc/kubernetes/manifests/`
2. Verify the pod appears in `kubectl get pods`

**Verification**:
```bash
kubectl get pods | grep static-web-worker-1
```

---

## Question 11 (6%) - Taints and Tolerations

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Taint node `worker-1` with `dedicated=special:NoSchedule`
2. Create a pod that tolerates this taint
3. Verify pod schedules on `worker-1`

**Verification**:
```bash
kubectl get pods -o wide
# Pod should be on worker-1
```

---

## Question 12 (7%) - Rolling Update and Rollback

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create deployment `app` (nginx:1.20, 3 replicas)
2. Update to nginx:1.21 (rolling update)
3. Update to nginx:invalid-tag (will fail)
4. Rollback to previous version
5. Verify rollback succeeded

**Verification**:
```bash
kubectl rollout history deployment/app
kubectl get pods | grep app
# All pods should be Running with nginx:1.21
```

---

## Question 13 (8%) - Restore etcd from Backup

**Context**: `kubernetes-admin@cluster2`

**Scenario**: Cluster state needs to be restored from backup `/opt/etcd-backup.db`.

**Tasks**:
1. Stop API server and etcd
2. Restore etcd from backup
3. Update etcd manifest to use restored data
4. Restart API server and etcd
5. Verify cluster is operational

**Verification**:
```bash
kubectl get nodes
kubectl get pods -A
# Cluster should be functional
```

---

## Question 14 (6%) - Init Containers

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a pod with an init container:
   - Init container: busybox, creates a file `/work-dir/initialized`
   - Main container: nginx, mounts the same volume, reads the file
   - Both containers share an emptyDir volume at `/work-dir`

**Verification**:
```bash
kubectl logs <pod> -c <main-container>
kubectl exec <pod> -- ls /work-dir/initialized
```

---

## Question 15 (10%) - Multi-Service Application

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create namespace `web-stack`
2. Deploy Redis (1 replica, ClusterIP service)
3. Deploy web app (nginx, 3 replicas, depends on Redis)
4. Create NetworkPolicy allowing only web → redis traffic
5. Create HPA for web app (min 3, max 10, target 70% CPU)
6. Create PDB for redis (minAvailable: 1)
7. Verify everything works

**Verification**:
```bash
kubectl get all,pdb,hpa,networkpolicy -n web-stack
# All resources created and healthy
```

---

## 📝 Scoring

| Question | Weight |
|----------|--------|
| Q1 | 5% |
| Q2 | 8% |
| Q3 | 6% |
| Q4 | 7% |
| Q5 | 6% |
| Q6 | 8% |
| Q7 | 7% |
| Q8 | 5% |
| Q9 | 8% |
| Q10 | 7% |
| Q11 | 6% |
| Q12 | 7% |
| Q13 | 8% |
| Q14 | 6% |
| Q15 | 10% |
| **Total** | **100%** |

---

**See `mock-exam-2-solutions.md` for answers.**
