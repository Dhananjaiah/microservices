# Kubernetes Troubleshooting Checklist

## 🚨 Quick Triage (First 2 Minutes)

```bash
# 1. Check pod status
kubectl get pods -A

# 2. Check recent events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# 3. Check node health
kubectl get nodes

# 4. Check control plane components
kubectl get pods -n kube-system
```

## 📋 Pod Issues

### Pod Pending
- [ ] Check node resources: `kubectl top nodes`
- [ ] Check pod resources: `kubectl describe pod <name>`
- [ ] Look for: "Insufficient cpu/memory" or taint messages
- [ ] Verify PVC is bound: `kubectl get pvc`
- [ ] Check node selector/affinity matches

### Pod CrashLoopBackOff
- [ ] Check logs: `kubectl logs <pod> --previous`
- [ ] Check events: `kubectl describe pod <pod>`
- [ ] Look for: exit code, error messages
- [ ] Verify environment variables are set
- [ ] Check liveness probe configuration
- [ ] Verify image exists and is correct

### Pod ImagePullBackOff
- [ ] Verify image name is correct
- [ ] Check if image exists in registry
- [ ] Verify ImagePullSecret if private registry
- [ ] Check network connectivity to registry
- [ ] Look at events for specific error

### Pod OOMKilled
- [ ] Check memory limits: `kubectl describe pod <pod>`
- [ ] View actual usage: `kubectl top pod <pod>`
- [ ] Increase memory limit if needed
- [ ] Check for memory leaks in application

## 🌐 Network Issues

### Service Not Accessible
- [ ] Verify service exists: `kubectl get svc`
- [ ] Check endpoints: `kubectl get endpoints <svc>`
- [ ] Verify selector matches pod labels
- [ ] Test from within cluster: `kubectl run test --rm -it --image=busybox`
- [ ] Check NetworkPolicy isn't blocking

### DNS Not Working
- [ ] Check CoreDNS pods: `kubectl get pods -n kube-system -l k8s-app=kube-dns`
- [ ] Test resolution: `kubectl run test --rm -it --image=busybox -- nslookup kubernetes.default`
- [ ] Check CoreDNS logs
- [ ] Verify NetworkPolicy allows DNS (port 53 UDP/TCP)

### NetworkPolicy Blocking Traffic
- [ ] List NetworkPolicies: `kubectl get networkpolicies`
- [ ] Check if default-deny exists
- [ ] Verify ingress/egress rules allow your traffic
- [ ] Test without NetworkPolicy temporarily

## 🖥️ Node Issues

### Node NotReady
- [ ] Check node conditions: `kubectl describe node <node>`
- [ ] On node, check kubelet: `systemctl status kubelet`
- [ ] Check kubelet logs: `journalctl -u kubelet -e`
- [ ] Check disk space: `df -h`
- [ ] Check CNI pods: `kubectl get pods -n calico-system`
- [ ] Verify certificates not expired

### Node Disk Pressure
- [ ] Check disk usage: `df -h`
- [ ] Clean up images: `sudo crictl rmi --prune`
- [ ] Clean up logs: `sudo journalctl --vacuum-time=3d`
- [ ] Check pod logs aren't filling disk

## 🧮 Control Plane Issues

### API Server Down
- [ ] On control plane: `sudo crictl ps | grep apiserver`
- [ ] Check logs: `sudo crictl logs <container-id>`
- [ ] Verify etcd is running
- [ ] Check manifest: `/etc/kubernetes/manifests/kube-apiserver.yaml`
- [ ] Verify certificates

### etcd Down
- [ ] Check etcd pod: `kubectl get pods -n kube-system | grep etcd`
- [ ] Check logs: `sudo crictl logs <container-id>`
- [ ] Verify disk space
- [ ] Check ports 2379/2380 not in use
- [ ] Consider restore from backup

## 🔐 Security/RBAC Issues

### Permission Denied
- [ ] Check permissions: `kubectl auth can-i <verb> <resource> --as=<user>`
- [ ] Verify Role/RoleBinding exists
- [ ] Check ServiceAccount is correct
- [ ] Verify ClusterRole for cluster-scoped resources

## 💾 Storage Issues

### PVC Pending
- [ ] Check PV availability: `kubectl get pv`
- [ ] Verify access modes match
- [ ] Check storage class exists
- [ ] Verify capacity is sufficient
- [ ] Check volumeBindingMode

### PVC Not Mounting
- [ ] Check pod events: `kubectl describe pod <pod>`
- [ ] Verify PVC is bound: `kubectl get pvc`
- [ ] Check node has access to storage
- [ ] Verify mount path doesn't conflict

## ⚡ Performance Issues

### High CPU/Memory Usage
- [ ] Check current usage: `kubectl top pods`
- [ ] Check resource limits
- [ ] Look for resource-intensive pods
- [ ] Check for pods in CrashLoop (CPU spikes)
- [ ] Consider HPA if not configured

### Slow Application
- [ ] Check pod logs for errors
- [ ] Verify readiness probes passing
- [ ] Check service endpoints
- [ ] Test network latency pod-to-pod
- [ ] Check database connection if applicable

## 🛠️ General Debugging Commands

```bash
# Get everything in namespace
kubectl get all -n <namespace>

# Describe any resource
kubectl describe <resource-type> <name> -n <namespace>

# Get logs
kubectl logs <pod> -n <namespace> [-c <container>] [--previous]

# Execute in pod
kubectl exec -it <pod> -n <namespace> -- /bin/sh

# Port forward for local testing
kubectl port-forward <pod> <local-port>:<pod-port> -n <namespace>

# Get events sorted by time
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Check resource usage
kubectl top nodes
kubectl top pods -n <namespace>

# Test connectivity
kubectl run test --image=busybox --restart=Never --rm -it -- sh
```

## 📝 Documentation

Always check:
- Pod events: `kubectl describe pod`
- Service endpoints: `kubectl get endpoints`
- Recent events: `kubectl get events --sort-by='.lastTimestamp'`
- Logs: `kubectl logs`
- Node status: `kubectl describe node`

## 🎯 Exam Tips

1. **Read the question carefully** - note namespace, context, cluster
2. **Check events first** - they usually tell you the problem
3. **Verify your changes** - always kubectl get/describe after
4. **Use --help** - `kubectl <command> --help` for syntax
5. **Don't panic** - methodically work through checklist
