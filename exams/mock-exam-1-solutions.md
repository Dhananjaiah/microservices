# CKA Mock Exam 1 - Solutions

## Question 1 - Create Namespace and Deploy

```bash
kubectl create namespace web-app
kubectl create deployment nginx-deploy --image=nginx:1.21 --replicas=3 -n web-app
kubectl expose deployment nginx-deploy --port=80 --type=NodePort -n web-app

# Verify
kubectl get all -n web-app
```

## Question 2 - RBAC Setup

```bash
kubectl create serviceaccount app-reader
kubectl create role pod-reader --verb=get,list,watch --resource=pods
kubectl create rolebinding app-reader-binding --role=pod-reader --serviceaccount=default:app-reader

# Verify
kubectl auth can-i list pods --as=system:serviceaccount:default:app-reader
```

## Question 3 - Troubleshoot Failing Deployment

```bash
# Diagnose
kubectl get pods -n production
kubectl describe pod <pod-name> -n production
# Look for image name error

# Fix (example: image name typo)
kubectl set image deployment/broken-app broken-app=nginx:latest -n production

# Verify
kubectl get pods -n production
```

## Question 4 - Persistent Storage

```yaml
# pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data
---
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl get pv,pvc
```

## Question 5 - Scale and Update

```bash
kubectl scale deployment web-server --replicas=5
kubectl set image deployment/web-server nginx=nginx:1.22
kubectl rollout status deployment/web-server
kubectl get deployment web-server
```

## Question 6 - NetworkPolicy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: secure
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

```bash
kubectl apply -f networkpolicy.yaml
```

## Question 7 - etcd Backup

```bash
# SSH to control plane node
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup-$(date +%Y%m%d).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify
sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup-*.db --write-out=table
```

## Question 8 - Node Maintenance

```bash
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data
kubectl get pods -A -o wide | grep worker-1

# After maintenance
kubectl uncordon worker-1
```

## Question 9 - Multi-Container Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-pod
spec:
  containers:
  - name: nginx
    image: nginx
  - name: logger
    image: busybox
    command: ["sh", "-c", "while true; do echo $(date); sleep 5; done"]
```

```bash
kubectl apply -f multi-pod.yaml
kubectl get pod multi-pod
kubectl logs multi-pod -c logger
```

## Question 10 - Upgrade Control Plane

```bash
# On control plane node
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.28.0-00
sudo apt-mark hold kubeadm

sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.28.0

kubectl drain <control-plane-node> --ignore-daemonsets

sudo apt-mark unhold kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00
sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl uncordon <control-plane-node>
kubectl get nodes
```

## Question 11 - ConfigMap and Secret

```bash
kubectl create configmap app-config --from-literal=env=production --from-literal=debug=false
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=secret123
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["sleep", "3600"]
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: db-secret
```

```bash
kubectl apply -f pod.yaml
kubectl exec config-pod -- env | grep -E "env|debug|username|password"
```

## Question 12 - Service and Ingress

```bash
kubectl create deployment web --image=nginx --replicas=2
kubectl expose deployment web --port=80
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
```

```bash
kubectl apply -f ingress.yaml
```

## Question 13 - DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: logger
  namespace: monitoring
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
        command: ["sh", "-c", "while true; do echo 'Logging from '$(hostname); sleep 10; done"]
```

```bash
kubectl create namespace monitoring
kubectl apply -f daemonset.yaml
kubectl get ds logger -n monitoring
```

## Question 14 - Troubleshoot Node NotReady

```bash
# Diagnose
kubectl describe node worker-2
# Look for kubelet issues

# SSH to worker-2
sudo systemctl status kubelet
sudo journalctl -u kubelet -e

# Common fix
sudo systemctl restart kubelet

# Verify
kubectl get nodes
```

## Question 15 - StatefulSet

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: database
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: database
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_PASSWORD
          value: mysecret
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

```bash
kubectl create namespace database
kubectl apply -f statefulset.yaml
kubectl get sts,pods,pvc -n database
```

---

**Scoring Guide**:
- Full points: Task completed correctly and verified
- Partial points: Task partially completed or minor errors
- No points: Task not attempted or completely incorrect
