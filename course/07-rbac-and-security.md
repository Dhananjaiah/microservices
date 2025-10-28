# Module 07 — RBAC and Security

## 🎯 Goals

- **Implement Role-Based Access Control** (RBAC) for users and service accounts
- **Secure pods** with Pod Security Standards and securityContext
- **Manage secrets** and ImagePullSecrets

## 🔐 RBAC Components

```
User/ServiceAccount → RoleBinding → Role → Resources (pods, services, etc.)
                   → ClusterRoleBinding → ClusterRole → Cluster-wide resources
```

## 👤 ServiceAccounts

Pods use ServiceAccounts to authenticate with the API server.

**Create ServiceAccount**:
```bash
kubectl create serviceaccount app-sa
```

**Use in Pod**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  serviceAccountName: app-sa
  containers:
  - name: nginx
    image: nginx
```

**Verify**:
```bash
kubectl get sa
kubectl describe sa app-sa
```

## 🎭 Roles (Namespace-Scoped)

**role.yaml**:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

**Create imperatively**:
```bash
kubectl create role pod-reader --verb=get,list,watch --resource=pods
```

## 🔗 RoleBindings

**rolebinding.yaml**:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: default
```

**Create imperatively**:
```bash
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=default:app-sa
```

## 🌍 ClusterRoles and ClusterRoleBindings

For cluster-wide permissions (nodes, namespaces, etc.).

**Create ClusterRole**:
```bash
kubectl create clusterrole node-reader --verb=get,list,watch --resource=nodes
```

**Create ClusterRoleBinding**:
```bash
kubectl create clusterrolebinding read-nodes --clusterrole=node-reader --user=john
```

## ✅ Check Permissions

```bash
# Can I create pods?
kubectl auth can-i create pods

# Can app-sa list pods?
kubectl auth can-i list pods --as=system:serviceaccount:default:app-sa

# Can user john create deployments?
kubectl auth can-i create deployments --as=john

# List all permissions for user
kubectl auth can-i --list --as=john
```

## 🔒 Pod Security

### securityContext (Pod/Container Level)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: nginx
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
```

### Pod Security Standards

Three levels: **Privileged**, **Baseline**, **Restricted**

**Enforce restricted on namespace**:
```bash
kubectl label namespace default pod-security.kubernetes.io/enforce=restricted
```

## 🤐 Secrets

**Create secret**:
```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123
```

**Use as environment variables**:
```yaml
env:
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: username
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

**Use as volume**:
```yaml
volumes:
- name: secret-volume
  secret:
    secretName: db-secret
volumeMounts:
- name: secret-volume
  mountPath: /etc/secrets
  readOnly: true
```

**ImagePullSecrets** (private registry):
```bash
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.com \
  --docker-username=user \
  --docker-password=pass

# Use in pod
imagePullSecrets:
- name: regcred
```

## 🧪 Mini-Lab: RBAC Setup (15 minutes)

```bash
# Create namespace
kubectl create namespace secure-app

# Create ServiceAccount
kubectl create sa app-sa -n secure-app

# Create Role (read pods only)
kubectl create role pod-reader --verb=get,list --resource=pods -n secure-app

# Create RoleBinding
kubectl create rolebinding app-read-pods --role=pod-reader --serviceaccount=secure-app:app-sa -n secure-app

# Test permissions
kubectl auth can-i get pods -n secure-app --as=system:serviceaccount:secure-app:app-sa
# Should return: yes

kubectl auth can-i create pods -n secure-app --as=system:serviceaccount:secure-app:app-sa
# Should return: no
```

## ❌ Common Mistakes

1. **Forgetting namespace in RoleBinding subjects**
2. **Using ClusterRole for namespace resources** (use Role instead)
3. **Storing secrets in ConfigMaps** (use Secrets)
4. **Not base64-decoding secrets** (`kubectl get secret -o jsonpath='{.data.password}' | base64 -d`)
5. **Running pods as root** unnecessarily

---

**Next**: Module 08 — Observability and Logging
