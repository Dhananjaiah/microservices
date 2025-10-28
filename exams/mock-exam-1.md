# CKA Mock Exam 1

## ⏱️ Time Limit: 2 Hours
## 📊 Passing Score: 66% (10/15 questions)

**Instructions**:
- Switch to the correct context before each question
- All questions are performance-based (no multiple choice)
- You may use kubernetes.io documentation
- Verify your work after each question

---

## Question 1 (4%) - Create a Namespace and Deploy

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a namespace called `web-app`
2. Create a deployment named `nginx-deploy` in the `web-app` namespace:
   - Image: `nginx:1.21`
   - Replicas: 3
3. Expose the deployment as a NodePort service on port 80

**Verification**:
```bash
kubectl get ns web-app
kubectl get deployment nginx-deploy -n web-app
kubectl get svc nginx-deploy -n web-app
```

---

## Question 2 (7%) - RBAC Setup

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a ServiceAccount named `app-reader` in namespace `default`
2. Create a Role named `pod-reader` that allows `get`, `list`, and `watch` on `pods`
3. Create a RoleBinding that binds the `pod-reader` role to the `app-reader` ServiceAccount
4. Verify the ServiceAccount can list pods

**Verification**:
```bash
kubectl auth can-i list pods --as=system:serviceaccount:default:app-reader
# Should return: yes
```

---

## Question 3 (8%) - Troubleshoot a Failing Deployment

**Context**: `kubernetes-admin@cluster2`

**Scenario**: The deployment `broken-app` in namespace `production` has pods in `ImagePullBackOff` state.

**Tasks**:
1. Identify the issue
2. Fix the deployment so pods run successfully
3. Verify all 3 replicas are running

**Hint**: Check the image name in the deployment spec.

**Verification**:
```bash
kubectl get pods -n production | grep broken-app
# All should show Running
```

---

## Question 4 (6%) - Persistent Storage

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a PersistentVolume named `pv-data`:
   - Capacity: 2Gi
   - Access Mode: ReadWriteOnce
   - Host Path: /mnt/data
   - Reclaim Policy: Retain
2. Create a PersistentVolumeClaim named `pvc-data` requesting 1Gi
3. Verify the PVC is bound to the PV

**Verification**:
```bash
kubectl get pv pv-data
kubectl get pvc pvc-data
# PVC should show Bound status
```

---

## Question 5 (5%) - Scale and Update

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Scale the deployment `web-server` in namespace `default` to 5 replicas
2. Update the image to `nginx:1.22`
3. Check the rollout status

**Verification**:
```bash
kubectl get deployment web-server
# Should show 5/5 ready replicas
kubectl rollout history deployment/web-server
```

---

## Question 6 (7%) - NetworkPolicy

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. In namespace `secure`, create a NetworkPolicy named `backend-policy` that:
   - Applies to pods with label `app=backend`
   - Denies all ingress traffic by default
   - Allows ingress only from pods with label `app=frontend` on port 8080
2. Test that the policy works

**Verification**:
```bash
kubectl get networkpolicy backend-policy -n secure
kubectl describe networkpolicy backend-policy -n secure
```

---

## Question 7 (10%) - etcd Backup

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a snapshot of the etcd database
2. Save it to `/tmp/etcd-backup-$(date +%Y%m%d).db`
3. Verify the snapshot was created successfully

**Note**: You may need to SSH to the control plane node.

**Verification**:
```bash
ls -lh /tmp/etcd-backup-*.db
# File should exist and have non-zero size
```

---

## Question 8 (4%) - Node Maintenance

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Drain the node `worker-1` to prepare for maintenance
2. Ensure DaemonSet pods are ignored
3. Verify no non-DaemonSet pods are running on `worker-1`

**Verification**:
```bash
kubectl get nodes
# worker-1 should show SchedulingDisabled
kubectl get pods -A -o wide | grep worker-1
# Only DaemonSet pods should remain
```

---

## Question 9 (6%) - Create a Multi-Container Pod

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a pod named `multi-pod` in namespace `default` with two containers:
   - Container 1: name=nginx, image=nginx
   - Container 2: name=logger, image=busybox, command: `sh -c "while true; do echo $(date); sleep 5; done"`
2. Verify both containers are running

**Verification**:
```bash
kubectl get pod multi-pod
# Should show 2/2 Ready
kubectl logs multi-pod -c logger
# Should show timestamped logs
```

---

## Question 10 (7%) - Upgrade Control Plane

**Context**: `kubernetes-admin@cluster2`

**Scenario**: The cluster is running Kubernetes v1.27.0. Upgrade the control plane to v1.28.0.

**Tasks**:
1. Upgrade kubeadm to v1.28.0
2. Run `kubeadm upgrade plan`
3. Perform the upgrade with `kubeadm upgrade apply`
4. Upgrade kubelet and kubectl on the control plane
5. Verify the control plane is running v1.28.0

**Verification**:
```bash
kubectl get nodes
# Control plane should show v1.28.0
```

---

## Question 11 (5%) - ConfigMap and Secret

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a ConfigMap named `app-config` with data:
   - `env=production`
   - `debug=false`
2. Create a Secret named `db-secret` with:
   - `username=admin`
   - `password=secret123`
3. Create a pod named `config-pod` that uses both as environment variables

**Verification**:
```bash
kubectl exec config-pod -- env | grep -E "env|debug|username|password"
```

---

## Question 12 (8%) - Service and Ingress

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a deployment `web` with nginx, 2 replicas
2. Expose it as a ClusterIP service on port 80
3. Create an Ingress resource:
   - Host: `web.example.com`
   - Path: `/`
   - Backend: the service you created

**Verification**:
```bash
kubectl get ingress
kubectl describe ingress <name>
```

---

## Question 13 (6%) - DaemonSet

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a DaemonSet named `logger` in namespace `monitoring`:
   - Image: busybox
   - Command: `sh -c "while true; do echo 'Logging from '$(hostname); sleep 10; done"`
2. Verify one pod runs on each worker node

**Verification**:
```bash
kubectl get daemonset logger -n monitoring
kubectl get pods -n monitoring -o wide
# Should see one pod per node
```

---

## Question 14 (7%) - Troubleshoot Node NotReady

**Context**: `kubernetes-admin@cluster2`

**Scenario**: Node `worker-2` is in NotReady state.

**Tasks**:
1. Identify why the node is NotReady
2. Fix the issue
3. Verify the node becomes Ready

**Hint**: Check kubelet status on the node.

**Verification**:
```bash
kubectl get nodes
# worker-2 should show Ready
```

---

## Question 15 (10%) - StatefulSet with Persistent Storage

**Context**: `kubernetes-admin@cluster1`

**Tasks**:
1. Create a StatefulSet named `postgres` in namespace `database`:
   - Image: postgres:15
   - Replicas: 3
   - Environment variable: `POSTGRES_PASSWORD=mysecret`
   - VolumeClaimTemplate: 1Gi storage, ReadWriteOnce
   - Service name: `postgres`
2. Create the headless service
3. Verify all 3 pods are running with their own PVCs

**Verification**:
```bash
kubectl get statefulset postgres -n database
kubectl get pods -n database
kubectl get pvc -n database
# Should see 3 PVCs: postgres-postgres-0, postgres-postgres-1, postgres-postgres-2
```

---

## 📝 Scoring

| Question | Weight | Points |
|----------|--------|--------|
| Q1 | 4% | |
| Q2 | 7% | |
| Q3 | 8% | |
| Q4 | 6% | |
| Q5 | 5% | |
| Q6 | 7% | |
| Q7 | 10% | |
| Q8 | 4% | |
| Q9 | 6% | |
| Q10 | 7% | |
| Q11 | 5% | |
| Q12 | 8% | |
| Q13 | 6% | |
| Q14 | 7% | |
| Q15 | 10% | |
| **Total** | **100%** | |

**Passing Score**: 66%

---

**Good luck! Remember to verify each answer before moving to the next question.**

**See `mock-exam-1-solutions.md` for answers (only after completing the exam!).**
