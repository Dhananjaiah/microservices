# Module 04 — Workloads and Scheduling

## 🎯 Goals

- **Deploy applications using Pods, Deployments, StatefulSets, DaemonSets, Jobs, and CronJobs**
- **Configure resource requests/limits, probes, and autoscaling**
- **Control pod placement using node selectors, affinity, taints, and tolerations**

## 📦 Workload Resources

### Pods

Pods are the smallest deployable units. A pod wraps one or more containers with shared storage/network.

**Create a simple pod**:
```bash
kubectl run nginx --image=nginx
```

**Generate YAML**:
```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
```

**pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

**Apply**:
```bash
kubectl apply -f pod.yaml
```

**Verify**:
```bash
kubectl get pods
kubectl describe pod nginx
kubectl logs nginx
```

**Delete**:
```bash
kubectl delete pod nginx
```

---

### Deployments

Deployments manage ReplicaSets, which manage Pods. Use Deployments for stateless applications.

**Create deployment**:
```bash
kubectl create deployment web --image=nginx --replicas=3
```

**Generate YAML**:
```bash
kubectl create deployment web --image=nginx --replicas=3 --dry-run=client -o yaml > deployment.yaml
```

**deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

**Apply**:
```bash
kubectl apply -f deployment.yaml
```

**Verify**:
```bash
kubectl get deployment
kubectl get replicaset
kubectl get pods -l app=web
```

**Update image (rolling update)**:
```bash
kubectl set image deployment/web nginx=nginx:1.22
kubectl rollout status deployment/web
```

**Rollback**:
```bash
kubectl rollout undo deployment/web
```

---

### StatefulSets

StatefulSets are for stateful applications that need stable network identities and persistent storage.

**statefulset.yaml**:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

Pods are named: web-0, web-1, web-2 (ordered, stable names).

---

### DaemonSets

DaemonSets run one pod per node (e.g., log collectors, monitoring agents).

**daemonset.yaml**:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: logger
spec:
  selector:
    matchLabels:
      app: logger
  template:
    metadata:
      labels:
        app: logger
    spec:
      containers:
      - name: logger
        image: busybox
        command: ["sh", "-c", "while true; do echo $(date); sleep 10; done"]
```

**Apply**:
```bash
kubectl apply -f daemonset.yaml
```

**Verify** (one pod per node):
```bash
kubectl get pods -l app=logger -o wide
```

---

### Jobs

Jobs create pods that run to completion (batch tasks).

**job.yaml**:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

**Apply**:
```bash
kubectl apply -f job.yaml
```

**Verify**:
```bash
kubectl get jobs
kubectl logs job/pi
```

---

### CronJobs

CronJobs create Jobs on a schedule.

**cronjob.yaml**:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"  # Every minute
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["sh", "-c", "date; echo Hello from CronJob"]
          restartPolicy: OnFailure
```

**Apply**:
```bash
kubectl apply -f cronjob.yaml
```

**Verify**:
```bash
kubectl get cronjobs
kubectl get jobs
```

---

## 🩺 Health Checks (Probes)

### Liveness Probe

Restarts container if probe fails.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 3
  periodSeconds: 3
```

### Readiness Probe

Removes pod from Service endpoints if probe fails (pod not ready to serve traffic).

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Startup Probe

Delays liveness/readiness checks for slow-starting apps.

```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

---

## 📊 Resource Requests and Limits

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

- **Requests**: Scheduler uses this to find a node with enough resources
- **Limits**: Container cannot use more than this (OOMKilled if exceeded)

**Verify**:
```bash
kubectl top pods
kubectl top nodes
```

---

## 🎯 Pod Scheduling

### Node Selector

Simple node selection by label.

```yaml
nodeSelector:
  disktype: ssd
```

**Label a node**:
```bash
kubectl label node w1 disktype=ssd
```

### Node Affinity

More flexible than nodeSelector.

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: disktype
          operator: In
          values:
          - ssd
```

### Taints and Tolerations

Taints repel pods; tolerations allow pods to be scheduled on tainted nodes.

**Taint a node**:
```bash
kubectl taint node w1 key=value:NoSchedule
```

**Toleration in pod**:
```yaml
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"
```

**Remove taint**:
```bash
kubectl taint node w1 key=value:NoSchedule-
```

---

## 🧪 Mini-Lab: Deploy Multi-Tier App (15 minutes)

**Task 1**: Deploy backend
```bash
kubectl create deployment backend --image=redis --replicas=1
kubectl expose deployment backend --port=6379
```

**Task 2**: Deploy frontend
```bash
kubectl create deployment frontend --image=nginx --replicas=3
kubectl expose deployment frontend --port=80 --type=NodePort
```

**Task 3**: Scale frontend
```bash
kubectl scale deployment frontend --replicas=5
```

**Cleanup**:
```bash
kubectl delete deployment backend frontend
kubectl delete service backend frontend
```

---

## 🎯 Exam Drill: Workloads (15 minutes)

**Tasks**:
1. Create a deployment with 3 replicas (3 min)
2. Add resource requests/limits (2 min)
3. Add liveness probe (2 min)
4. Create a Job that runs once (3 min)
5. Create a CronJob that runs every 5 minutes (5 min)

---

## ❌ Common Mistakes

1. **Forgetting selector labels match template labels** in Deployments
2. **Setting limits too low** → OOMKilled
3. **Not testing probes** → wrong path/port causes CrashLoop
4. **Confusing NodePort with LoadBalancer**
5. **Not using --dry-run to generate YAML**

---

**Next**: Module 05 — Services and Networking
