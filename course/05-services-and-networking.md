# Module 05 — Services and Networking

## 🎯 Goals

- **Expose applications using Services** (ClusterIP, NodePort, LoadBalancer)
- **Configure Ingress** for HTTP/HTTPS routing
- **Implement NetworkPolicies** for pod-to-pod security

## 🌐 Service Types

### ClusterIP (Default)

Internal cluster IP. Only accessible within the cluster.

```bash
kubectl create deployment web --image=nginx
kubectl expose deployment web --port=80 --target-port=80
```

**Verify**:
```bash
kubectl get service web
# Test from within cluster
kubectl run test --image=busybox --restart=Never --rm -it -- wget -O- http://web
```

### NodePort

Exposes service on each node's IP at a static port (30000-32767).

```bash
kubectl expose deployment web --port=80 --type=NodePort
```

**Access**:
```bash
NODE_PORT=$(kubectl get svc web -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
curl http://$NODE_IP:$NODE_PORT
```

### LoadBalancer

Creates an external load balancer (cloud provider).

```bash
kubectl expose deployment web --port=80 --type=LoadBalancer
```

---

## 🚪 Ingress

Ingress manages external HTTP/HTTPS access to services.

**Install Ingress Controller** (nginx example):
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

**ingress.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: myapp.example.com
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

---

## 🔒 NetworkPolicies

Control pod-to-pod and pod-to-external traffic.

**Deny all ingress**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

**Allow from specific pods**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
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
      port: 6379
```

**Test connectivity**:
```bash
# Should work (frontend to backend)
kubectl exec frontend-xxx -- nc -zv backend-service 6379

# Should fail (other pods to backend)
kubectl run test --image=busybox --restart=Never --rm -it -- nc -zv backend-service 6379
```

---

## 🧪 Mini-Lab: Service Discovery (10 minutes)

```bash
kubectl create deployment backend --image=redis
kubectl expose deployment backend --port=6379

kubectl create deployment frontend --image=nginx
kubectl set env deployment/frontend REDIS_HOST=backend
```

---

## ❌ Common Mistakes

1. **Service selector doesn't match pod labels**
2. **NetworkPolicy doesn't allow DNS** (kube-dns on port 53)
3. **Forgetting to install Ingress Controller**
4. **Wrong service port vs targetPort**

---

**Next**: Module 06 — Storage and State
