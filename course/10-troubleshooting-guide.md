# Module 10 — Troubleshooting Guide

## 🎯 Goals

- **Systematically debug common Kubernetes failures**
- **Use the right tools for each problem type**
- **Fix cluster, network, and application issues**

## 🔍 Troubleshooting Methodology

```
1. Identify symptoms (pod status, logs, events)
2. Gather data (kubectl get, describe, logs)
3. Formulate hypothesis (what could cause this?)
4. Test hypothesis (change one thing, verify)
5. Implement fix
6. Verify and document
```

## 🚨 Common Pod Failures

### CrashLoopBackOff

**Symptom**: Pod repeatedly crashes and restarts.

**Debug**:
```bash
kubectl get pods
# STATUS: CrashLoopBackOff

kubectl describe pod <pod>
# Check: Last State, Exit Code

kubectl logs <pod>
kubectl logs <pod> --previous  # Logs before crash
```

**Common causes**:
1. Application error (check logs)
2. Missing environment variables
3. Port already in use
4. Liveness probe failing
5. Insufficient resources (OOMKilled)

**Fix example** (missing env var):
```bash
kubectl set env deployment/<name> REQUIRED_VAR=value
```

---

### ImagePullBackOff

**Symptom**: Cannot pull container image.

**Debug**:
```bash
kubectl describe pod <pod>
# Check: Events section

# Look for:
# - "Failed to pull image"
# - "image not found"
# - "unauthorized"
```

**Common causes**:
1. **Typo in image name** → Fix image name
2. **Image doesn't exist** → Build and push image
3. **Private registry, no secret** → Create ImagePullSecret
4. **Network issue** → Check DNS, internet connectivity

**Fix** (ImagePullSecret):
```bash
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<user> \
  --docker-password=<pass>

# Add to deployment
kubectl patch deployment <name> -p '{"spec":{"template":{"spec":{"imagePullSecrets":[{"name":"regcred"}]}}}}'
```

---

### Pending

**Symptom**: Pod stuck in Pending state.

**Debug**:
```bash
kubectl describe pod <pod>
# Check: Events section

# Common messages:
# - "Insufficient cpu"
# - "Insufficient memory"
# - "0/3 nodes are available: 3 node(s) had taint..."
# - "No nodes available"
```

**Common causes**:
1. **Insufficient resources** → Scale nodes or reduce requests
2. **Taints without tolerations** → Add tolerations
3. **Node selector mismatch** → Fix labels or selector
4. **PVC not bound** → Check PV availability

**Fix** (insufficient resources):
```bash
# Check node resources
kubectl top nodes

# Reduce pod requests
kubectl set resources deployment/<name> --requests=cpu=100m,memory=128Mi
```

---

### OOMKilled (Out of Memory)

**Symptom**: Container killed due to memory limit exceeded.

**Debug**:
```bash
kubectl describe pod <pod>
# Last State: Terminated, Reason: OOMKilled

kubectl top pod <pod>
# Check memory usage
```

**Fix**:
```bash
# Increase memory limit
kubectl set resources deployment/<name> --limits=memory=512Mi --requests=memory=256Mi
```

---

## 🌐 Network Troubleshooting

### Pod-to-Pod Communication Fails

**Debug**:
```bash
# Get pod IPs
kubectl get pods -o wide

# Test connectivity
kubectl run test --image=busybox --restart=Never --rm -it -- ping <pod-ip>
kubectl run test --image=busybox --restart=Never --rm -it -- nc -zv <pod-ip> <port>
```

**Common causes**:
1. **NetworkPolicy blocking traffic** → Check and adjust NetworkPolicies
2. **CNI not working** → Check CNI pods
3. **Firewall rules** → Check node firewalls

**Check CNI**:
```bash
kubectl get pods -n calico-system
# All should be Running
```

---

### Service Not Accessible

**Debug**:
```bash
kubectl get service <svc>
# Check: CLUSTER-IP, PORT(S), ENDPOINTS

kubectl get endpoints <svc>
# Should show pod IPs

# Test from within cluster
kubectl run test --image=busybox --restart=Never --rm -it -- wget -O- http://<service>:<port>
```

**Common causes**:
1. **Service selector doesn't match pod labels** → Fix selector or labels
2. **No endpoints** → Pods not ready (check readiness probe)
3. **Wrong port** → Check service port vs targetPort

**Fix** (selector mismatch):
```bash
# Check pod labels
kubectl get pods --show-labels

# Update service selector
kubectl patch service <name> -p '{"spec":{"selector":{"app":"correct-label"}}}'
```

---

### DNS Not Working

**Debug**:
```bash
# Test DNS resolution
kubectl run test --image=busybox --restart=Never --rm -it -- nslookup kubernetes.default

# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

**Common causes**:
1. **CoreDNS pods not running** → Restart or check logs
2. **NetworkPolicy blocking DNS** → Allow UDP/TCP 53 to kube-dns
3. **Wrong DNS config** → Check /etc/resolv.conf in pod

---

## 🖥️ Node Troubleshooting

### Node NotReady

**Debug**:
```bash
kubectl get nodes
# STATUS: NotReady

kubectl describe node <node>
# Check: Conditions section

# On the node:
sudo systemctl status kubelet
sudo journalctl -u kubelet -e
```

**Common causes**:
1. **kubelet not running** → `sudo systemctl restart kubelet`
2. **Disk pressure** → Clean up disk space
3. **Memory pressure** → Free up memory
4. **CNI issue** → Check CNI pods
5. **Certificate expired** → Rotate certificates

**Fix** (kubelet down):
```bash
# On node
sudo systemctl restart kubelet
sudo systemctl status kubelet
```

---

## 🧮 Control Plane Troubleshooting

### API Server Down

**Symptoms**: kubectl commands fail with "connection refused"

**Debug**:
```bash
# On control plane node
sudo crictl ps | grep kube-apiserver

# Check logs
sudo crictl logs <apiserver-container-id>

# Check static pod manifest
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

**Common causes**:
1. **etcd down** → Check etcd pod
2. **Certificate issue** → Check cert validity
3. **Manifest syntax error** → Fix YAML

---

### etcd Down

**Debug**:
```bash
kubectl get pods -n kube-system | grep etcd
# Or on control plane:
sudo crictl ps | grep etcd

# Check logs
sudo crictl logs <etcd-container-id>
```

**Common causes**:
1. **Disk full** → Clean up disk
2. **Corrupted data** → Restore from backup
3. **Port conflict** → Check port 2379/2380

---

## 🧪 Mini-Lab: Fix Broken Deployments (20 minutes)

**Task 1: Fix CrashLoopBackOff**:
```bash
# Create broken deployment (missing env var)
kubectl create deployment broken --image=nginx
kubectl set env deployment/broken NGINX_PORT=  # Clears it, causes crash (hypothetical)

# Debug and fix
kubectl logs deployment/broken
kubectl set env deployment/broken NGINX_PORT=80
```

**Task 2: Fix ImagePullBackOff**:
```bash
kubectl run test --image=nonexistent/image:tag
kubectl describe pod test
kubectl delete pod test
kubectl run test --image=nginx
```

**Task 3: Fix Pending Pod**:
```bash
kubectl run huge --image=nginx --requests=cpu=100,memory=100Gi
kubectl describe pod huge
kubectl delete pod huge
kubectl run normal --image=nginx --requests=cpu=100m,memory=128Mi
```

---

## 📋 Quick Troubleshooting Checklist

### For Any Issue:
1. **Get status**: `kubectl get pods`
2. **Describe resource**: `kubectl describe pod <name>`
3. **Check events**: `kubectl get events --sort-by='.lastTimestamp'`
4. **View logs**: `kubectl logs <pod>`
5. **Check resources**: `kubectl top nodes && kubectl top pods`

### Pod Not Starting:
- [ ] Image name correct?
- [ ] ImagePullSecret configured (if private)?
- [ ] Sufficient node resources?
- [ ] PVC bound (if using volumes)?
- [ ] Node taints/tolerations match?

### Service Not Working:
- [ ] Service selector matches pod labels?
- [ ] Endpoints populated?
- [ ] Correct ports configured?
- [ ] NetworkPolicy allowing traffic?
- [ ] DNS resolving service name?

### Node Issues:
- [ ] kubelet running?
- [ ] Disk space available?
- [ ] CNI pods running?
- [ ] Certificates valid?

---

## ❌ Common Mistakes

1. **Not checking events first** → Events show the problem immediately
2. **Forgetting --previous for crashed pods** → Old logs are lost
3. **Not verifying labels match selectors** → Services/NetworkPolicies fail
4. **Ignoring resource requests/limits** → OOMKilled or Pending
5. **Not testing after fixes** → Problem might not be solved

---

**Next**: Module 11 — Exam Practice Drills
