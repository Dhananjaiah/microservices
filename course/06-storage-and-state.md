# Module 06 — Storage and State

## 🎯 Goals

- **Understand persistent storage concepts** (PV, PVC, StorageClass)
- **Deploy stateful applications** with persistent data
- **Configure volume access modes** and reclaim policies

## 💾 Storage Architecture

```
PersistentVolumeClaim (PVC) → PersistentVolume (PV) → Physical Storage
         ↓                            ↓
       Pod mounts PVC            StorageClass (dynamic provisioning)
```

## 📦 PersistentVolume (PV)

Cluster-wide storage resource. Administrator creates PVs.

**pv.yaml**:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data"
```

**Apply**:
```bash
kubectl apply -f pv.yaml
kubectl get pv
```

## 📝 PersistentVolumeClaim (PVC)

Request for storage by a user. Binds to a suitable PV.

**pvc.yaml**:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-local
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

**Apply**:
```bash
kubectl apply -f pvc.yaml
kubectl get pvc
# Status should show Bound to pv-local
```

## 🎛️ Access Modes

- **ReadWriteOnce (RWO)**: Single node read-write
- **ReadOnlyMany (ROX)**: Multiple nodes read-only
- **ReadWriteMany (RWX)**: Multiple nodes read-write

## ♻️ Reclaim Policies

- **Retain**: PV kept after PVC deletion (manual cleanup)
- **Delete**: PV and underlying storage deleted
- **Recycle**: Data scrubbed, PV available again (deprecated)

## 📚 StorageClass

Dynamic provisioning of PVs.

**storageclass.yaml**:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

**Use in PVC**:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic
spec:
  storageClassName: fast
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

## 🗄️ Using PVC in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc-local
```

**Test persistence**:
```bash
kubectl exec app -- sh -c "echo 'test data' > /data/test.txt"
kubectl delete pod app
# Recreate pod, data still there
kubectl apply -f pod.yaml
kubectl exec app -- cat /data/test.txt
```

## 🎯 StatefulSet with PVC

StatefulSets use volumeClaimTemplates for per-pod PVCs.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
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

Each pod gets its own PVC: data-postgres-0, data-postgres-1, data-postgres-2

## 🧪 Mini-Lab: Deploy StatefulSet with Storage (15 minutes)

```bash
# Create StatefulSet
kubectl apply -f statefulset.yaml

# Check PVCs created
kubectl get pvc

# Write data to pod 0
kubectl exec postgres-0 -- sh -c "echo 'persistent data' > /var/lib/postgresql/data/test.txt"

# Delete pod (StatefulSet recreates it)
kubectl delete pod postgres-0

# Verify data persists
kubectl exec postgres-0 -- cat /var/lib/postgresql/data/test.txt
```

## ❌ Common Mistakes

1. **PVC and PV access modes don't match**
2. **Pod deleted before PVC** → data loss if reclaimPolicy is Delete
3. **Using hostPath in production** → not portable across nodes
4. **Forgetting volumeBindingMode** → PV bound before pod scheduled

---

**Next**: Module 07 — RBAC and Security
