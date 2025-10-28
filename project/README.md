# FoodCart — End-to-End Kubernetes Project

## 📋 Overview

**FoodCart** is a cloud-native food ordering application demonstrating real-world Kubernetes concepts from the CKA exam.

**Architecture**:
```
User → Ingress → Frontend → API Gateway → Menu/Orders/Payments Services → PostgreSQL
                                ↓
                          Redis Cache
```

## 🏗️ Components

| Service | Technology | Purpose |
|---------|------------|---------|
| **frontend** | nginx | Serves static UI |
| **api-gateway** | nginx | Routes requests to backend |
| **menu** | Python/Flask | Menu catalog service |
| **orders** | Python/Flask | Order management |
| **payments** | Python/Flask | Payment processing (mock) |
| **postgres** | PostgreSQL 15 | Database (StatefulSet) |
| **redis** | Redis | Caching layer |

## 🎯 Kubernetes Concepts Demonstrated

- ✅ **Deployments** (frontend, api-gateway, services)
- ✅ **StatefulSet** (postgres with persistent storage)
- ✅ **Services** (ClusterIP for internal, NodePort/Ingress for external)
- ✅ **ConfigMaps** (application configuration)
- ✅ **Secrets** (database passwords)
- ✅ **PersistentVolumes** (postgres data)
- ✅ **HorizontalPodAutoscaler** (api-gateway autoscaling)
- ✅ **PodDisruptionBudget** (postgres high availability)
- ✅ **NetworkPolicies** (service-to-service security)
- ✅ **Ingress** (HTTP routing)
- ✅ **Probes** (liveness, readiness)
- ✅ **Resource Limits** (CPU/memory requests/limits)
- ✅ **RBAC** (service accounts for components)

## 📁 Project Structure

```
/project/
├── README.md (this file)
├── manifests/
│   ├── 00-namespace.yaml
│   ├── 01-postgres-pv.yaml
│   ├── 02-postgres.yaml
│   ├── 03-redis.yaml
│   ├── 04-menu-service.yaml
│   ├── 05-orders-service.yaml
│   ├── 06-payments-service.yaml
│   ├── 07-api-gateway.yaml
│   ├── 08-frontend.yaml
│   ├── 09-ingress.yaml
│   ├── 10-hpa.yaml
│   ├── 11-pdb.yaml
│   └── 12-network-policies.yaml
├── scripts/
│   ├── deploy.sh
│   ├── seed-data.sh
│   ├── load-test.sh
│   └── chaos-inject.sh
└── runbook.md
```

## 🚀 Quick Start

### 1. Deploy All Components

```bash
cd project

# Deploy in order (dependencies first)
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-postgres-pv.yaml
kubectl apply -f manifests/02-postgres.yaml
kubectl apply -f manifests/03-redis.yaml
kubectl apply -f manifests/04-menu-service.yaml
kubectl apply -f manifests/05-orders-service.yaml
kubectl apply -f manifests/06-payments-service.yaml
kubectl apply -f manifests/07-api-gateway.yaml
kubectl apply -f manifests/08-frontend.yaml
kubectl apply -f manifests/09-ingress.yaml
kubectl apply -f manifests/10-hpa.yaml
kubectl apply -f manifests/11-pdb.yaml
kubectl apply -f manifests/12-network-policies.yaml

# Or use the script
./scripts/deploy.sh
```

### 2. Verify Deployment

```bash
kubectl get all -n foodcart
kubectl get pvc -n foodcart
kubectl get networkpolicies -n foodcart
```

**Expected**: All pods Running, PVC Bound, services created.

### 3. Access the Application

```bash
# Get frontend URL (NodePort)
kubectl get service frontend -n foodcart
# Access at http://<NODE_IP>:<NODE_PORT>

# Or via Ingress (if configured)
# Access at http://foodcart.local (add to /etc/hosts)
```

### 4. Seed Test Data

```bash
./scripts/seed-data.sh
```

### 5. Run Load Test

```bash
./scripts/load-test.sh
```

**Watch HPA scale**:
```bash
watch kubectl get hpa -n foodcart
```

## 🧪 Testing & Troubleshooting

### Test Database Connection

```bash
kubectl exec -it postgres-0 -n foodcart -- psql -U foodcart -d foodcart -c "\dt"
```

### Test Service Discovery

```bash
kubectl run test -n foodcart --image=busybox --restart=Never --rm -it -- nslookup menu-service
```

### Test NetworkPolicies

```bash
# Should work (api-gateway to menu)
kubectl exec -n foodcart deployment/api-gateway -- curl http://menu-service:8080/health

# Should fail (frontend to menu directly - blocked by NetworkPolicy)
kubectl exec -n foodcart deployment/frontend -- curl http://menu-service:8080/health
```

### View Logs

```bash
kubectl logs -n foodcart deployment/api-gateway -f
kubectl logs -n foodcart deployment/menu -f
kubectl logs -n foodcart postgres-0
```

## 📊 Monitoring

```bash
# Check resource usage
kubectl top pods -n foodcart

# Check HPA status
kubectl get hpa -n foodcart

# Check events
kubectl get events -n foodcart --sort-by='.lastTimestamp'
```

## 🔧 Maintenance Tasks

### Scale Services

```bash
kubectl scale deployment api-gateway --replicas=5 -n foodcart
kubectl scale deployment menu --replicas=3 -n foodcart
```

### Update Image (Rolling Update)

```bash
kubectl set image deployment/menu menu=menu-service:v2 -n foodcart
kubectl rollout status deployment/menu -n foodcart
```

### Rollback

```bash
kubectl rollout undo deployment/menu -n foodcart
```

### Backup Database

```bash
kubectl exec postgres-0 -n foodcart -- pg_dump -U foodcart foodcart > /tmp/foodcart-backup.sql
```

## 🧨 Chaos Engineering

Use the chaos injection script to test resilience:

```bash
# Kill random pods
./scripts/chaos-inject.sh kill-pods

# Simulate network partition
./scripts/chaos-inject.sh network-partition

# Restart database
./scripts/chaos-inject.sh restart-db
```

Then use the runbook to recover!

## 🔐 Security Features

1. **NetworkPolicies**: Services can only talk to their dependencies
2. **Secrets**: Database passwords stored securely
3. **RBAC**: Each service has its own ServiceAccount
4. **Pod Security**: Containers run as non-root
5. **Resource Limits**: Prevent resource exhaustion

## 📈 Scalability Features

1. **HPA**: api-gateway autoscales based on CPU
2. **PDB**: Ensures postgres availability during maintenance
3. **StatefulSet**: postgres with stable identity and storage
4. **Redis Caching**: Reduces database load

## 🧹 Cleanup

```bash
kubectl delete namespace foodcart
# Also delete PVs if needed
kubectl delete pv postgres-pv
```

## 📚 Learning Exercises

### Exercise 1: Add a New Service
Create a "notifications" service that sends order confirmations.

### Exercise 2: Implement Blue-Green Deployment
Deploy v2 of menu service alongside v1, test, then switch traffic.

### Exercise 3: Set Up Monitoring
Install Prometheus and Grafana to monitor the application.

### Exercise 4: Implement Backup Strategy
Create a CronJob that backs up postgres daily.

### Exercise 5: Harden Security
Add Pod Security Standards, restrict capabilities, enable seccomp.

---

## 🎓 CKA Exam Relevance

This project covers these CKA exam domains:

- **Cluster Architecture** (understanding components)
- **Workloads & Scheduling** (Deployments, StatefulSets, affinity)
- **Services & Networking** (Services, Ingress, NetworkPolicies)
- **Storage** (PV, PVC, StatefulSets)
- **Troubleshooting** (debugging failures, reading logs/events)

Practice deploying, scaling, updating, and troubleshooting this application to build real-world Kubernetes skills!

---

**See runbook.md for detailed troubleshooting playbooks.**
