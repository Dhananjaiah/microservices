# Module 08 — Observability and Logging

## 🎯 Goals

- **Monitor cluster and application health** using metrics and logs
- **Debug issues** with kubectl logs, describe, and events
- **Install metrics-server** for resource monitoring

## 📊 Metrics Server

**Install metrics-server**:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**Check resource usage**:
```bash
kubectl top nodes
kubectl top pods
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory
```

## 📝 Logs

**View pod logs**:
```bash
kubectl logs nginx
kubectl logs nginx -f  # Follow
kubectl logs nginx --tail=50
kubectl logs nginx --previous  # Previous container (after crash)
kubectl logs nginx -c sidecar  # Specific container
kubectl logs -l app=web  # All pods with label
```

**Node logs** (kubelet, containerd):
```bash
# On node
journalctl -u kubelet -f
journalctl -u containerd -f
```

## 🔍 Debugging Commands

**Describe resources**:
```bash
kubectl describe pod nginx
kubectl describe node w1
kubectl describe deployment web
```

**Get events**:
```bash
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -A
kubectl get events --field-selector involvedObject.name=nginx
```

**Check pod status**:
```bash
kubectl get pods
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pod nginx -o jsonpath='{.status.phase}'
```

**Interactive debugging**:
```bash
kubectl exec -it nginx -- /bin/bash
kubectl exec nginx -- ps aux
kubectl port-forward nginx 8080:80
```

## 🧪 Mini-Lab: Debug Failing Pod (10 minutes)

```bash
# Create a broken pod
kubectl run broken --image=nginx:invalid-tag

# Debug it
kubectl get pods
kubectl describe pod broken
kubectl logs broken
kubectl get events --field-selector involvedObject.name=broken

# Fix it
kubectl delete pod broken
kubectl run fixed --image=nginx
```

## ❌ Common Mistakes

1. **Not checking events first** when troubleshooting
2. **Forgetting --previous for crashed containers**
3. **Not using -f to follow logs in real-time**
4. **Ignoring resource usage** (kubectl top)

---

**Next**: Module 09 — Cluster Maintenance
