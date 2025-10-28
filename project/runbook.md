# FoodCart SRE Runbook

## 🚨 Alert Response Playbooks

### Alert: Pods CrashLooping

**Severity**: High  
**Service**: Any

**Triage Steps**:
1. Identify affected pods:
   ```bash
   kubectl get pods -n foodcart | grep -i crash
   ```

2. Check pod logs:
   ```bash
   kubectl logs <pod-name> -n foodcart --previous
   ```

3. Check events:
   ```bash
   kubectl describe pod <pod-name> -n foodcart
   ```

**Common Causes & Fixes**:
- **Database connection failure** → Verify postgres is running, check credentials
- **Missing environment variable** → Add required env vars to deployment
- **Out of memory** → Increase memory limits
- **Application error** → Review logs, rollback if needed

**Resolution**:
```bash
# If config issue
kubectl edit deployment <name> -n foodcart

# If need to rollback
kubectl rollout undo deployment/<name> -n foodcart

# Restart pods
kubectl rollout restart deployment/<name> -n foodcart
```

---

### Alert: Database Connection Issues

**Severity**: Critical  
**Service**: postgres

**Triage Steps**:
1. Check postgres pod status:
   ```bash
   kubectl get pods -n foodcart -l app=postgres
   ```

2. Check postgres logs:
   ```bash
   kubectl logs postgres-0 -n foodcart
   ```

3. Test connectivity from application:
   ```bash
   kubectl exec -n foodcart deployment/menu -- nc -zv postgres 5432
   ```

**Common Causes & Fixes**:
- **Postgres pod not running** → Check PVC, restart pod
- **NetworkPolicy blocking** → Verify NetworkPolicy allows traffic
- **Wrong credentials** → Check secret values
- **Disk full** → Check PVC size, clean up data

**Resolution**:
```bash
# Restart postgres pod
kubectl delete pod postgres-0 -n foodcart

# Check PVC status
kubectl get pvc -n foodcart

# Verify secret
kubectl get secret postgres-secret -n foodcart -o yaml
```

---

### Alert: High API Gateway Latency

**Severity**: Medium  
**Service**: api-gateway

**Triage Steps**:
1. Check resource usage:
   ```bash
   kubectl top pods -n foodcart -l app=api-gateway
   ```

2. Check HPA status:
   ```bash
   kubectl get hpa -n foodcart
   ```

3. Check backend service health:
   ```bash
   kubectl get pods -n foodcart -l role=backend
   ```

**Common Causes & Fixes**:
- **High CPU/memory** → HPA should scale, verify it's working
- **Backend services slow** → Check backend logs and resources
- **NetworkPolicy delays** → Verify policies aren't blocking
- **Too few replicas** → Manually scale if HPA not working

**Resolution**:
```bash
# Manually scale if needed
kubectl scale deployment api-gateway --replicas=10 -n foodcart

# Check HPA
kubectl describe hpa api-gateway-hpa -n foodcart

# Restart if unresponsive
kubectl rollout restart deployment/api-gateway -n foodcart
```

---

### Alert: Service Unavailable

**Severity**: Critical  
**Service**: Any

**Triage Steps**:
1. Check service endpoints:
   ```bash
   kubectl get svc <service-name> -n foodcart
   kubectl get endpoints <service-name> -n foodcart
   ```

2. Check pods backing the service:
   ```bash
   kubectl get pods -n foodcart -l app=<app-label>
   ```

3. Test from inside cluster:
   ```bash
   kubectl run test -n foodcart --image=busybox --restart=Never --rm -it -- wget -O- http://<service-name>:<port>
   ```

**Common Causes & Fixes**:
- **No healthy pods** → Check readiness probes, fix pod issues
- **Selector mismatch** → Verify service selector matches pod labels
- **Wrong port** → Check service port vs pod containerPort
- **NetworkPolicy** → Verify policies allow traffic

**Resolution**:
```bash
# Check selector and labels match
kubectl get svc <service-name> -n foodcart -o yaml | grep selector
kubectl get pods -n foodcart --show-labels

# Fix selector if mismatched
kubectl patch svc <service-name> -n foodcart -p '{"spec":{"selector":{"app":"correct-label"}}}'
```

---

### Alert: PVC Not Bound

**Severity**: High  
**Service**: postgres

**Triage Steps**:
1. Check PVC status:
   ```bash
   kubectl get pvc -n foodcart
   ```

2. Check available PVs:
   ```bash
   kubectl get pv
   ```

3. Check PVC events:
   ```bash
   kubectl describe pvc <pvc-name> -n foodcart
   ```

**Common Causes & Fixes**:
- **No matching PV** → Create PV with matching specs
- **Access mode mismatch** → Fix PV or PVC access mode
- **Insufficient capacity** → Create larger PV
- **StorageClass issue** → Verify StorageClass exists

**Resolution**:
```bash
# Create matching PV
kubectl apply -f pv.yaml

# Verify binding
kubectl get pvc -n foodcart -w
```

---

## 🛠️ Maintenance Procedures

### Procedure: Deploy New Version

```bash
# 1. Update image tag
kubectl set image deployment/<name> <container>=<image>:<new-tag> -n foodcart

# 2. Watch rollout
kubectl rollout status deployment/<name> -n foodcart

# 3. Verify
kubectl get pods -n foodcart -l app=<name>

# 4. Test functionality
kubectl run test -n foodcart --image=curlimages/curl --restart=Never --rm -it -- curl http://<service>:<port>/health

# 5. Rollback if issues
kubectl rollout undo deployment/<name> -n foodcart
```

### Procedure: Scale Service

```bash
# Manual scale
kubectl scale deployment/<name> --replicas=<count> -n foodcart

# Verify
kubectl get deployment/<name> -n foodcart
kubectl get pods -n foodcart -l app=<name>
```

### Procedure: Backup Database

```bash
# Create backup
kubectl exec postgres-0 -n foodcart -- pg_dump -U foodcart foodcart > /tmp/foodcart-backup-$(date +%Y%m%d).sql

# Verify backup
ls -lh /tmp/foodcart-backup-*.sql

# Upload to S3/GCS (example)
# aws s3 cp /tmp/foodcart-backup-*.sql s3://backups/foodcart/
```

### Procedure: Restore Database

```bash
# Copy backup to pod
kubectl cp /tmp/foodcart-backup.sql foodcart/postgres-0:/tmp/

# Restore
kubectl exec postgres-0 -n foodcart -- psql -U foodcart -d foodcart -f /tmp/foodcart-backup.sql

# Verify
kubectl exec postgres-0 -n foodcart -- psql -U foodcart -d foodcart -c "\dt"
```

---

## 📊 Monitoring Commands

### Check Overall Health

```bash
kubectl get all -n foodcart
kubectl get pvc -n foodcart
kubectl top pods -n foodcart
kubectl get events -n foodcart --sort-by='.lastTimestamp' | tail -20
```

### Check Specific Service

```bash
kubectl get deployment <name> -n foodcart
kubectl get pods -n foodcart -l app=<name>
kubectl logs -n foodcart deployment/<name> --tail=50
kubectl describe deployment <name> -n foodcart
```

### Check Resource Usage

```bash
kubectl top nodes
kubectl top pods -n foodcart
kubectl top pods -n foodcart --sort-by=cpu
kubectl top pods -n foodcart --sort-by=memory
```

---

## 🔍 Debugging Commands

### Debug Pod Issues

```bash
# Get pod status
kubectl get pods -n foodcart

# Describe pod
kubectl describe pod <pod-name> -n foodcart

# Get logs
kubectl logs <pod-name> -n foodcart
kubectl logs <pod-name> -n foodcart --previous

# Execute in pod
kubectl exec -it <pod-name> -n foodcart -- /bin/sh

# Port forward for local testing
kubectl port-forward <pod-name> 8080:80 -n foodcart
```

### Debug Network Issues

```bash
# Test DNS
kubectl run test -n foodcart --image=busybox --restart=Never --rm -it -- nslookup <service-name>

# Test connectivity
kubectl run test -n foodcart --image=busybox --restart=Never --rm -it -- nc -zv <service-name> <port>

# Check NetworkPolicies
kubectl get networkpolicies -n foodcart
kubectl describe networkpolicy <name> -n foodcart
```

---

## 📞 Escalation

- **Severity 1 (Critical)**: Page on-call engineer immediately
- **Severity 2 (High)**: Notify in Slack, escalate if not resolved in 30 min
- **Severity 3 (Medium)**: Create ticket, resolve during business hours
- **Severity 4 (Low)**: Create ticket for backlog

**On-Call Contact**: See PagerDuty schedule  
**Slack Channel**: #foodcart-alerts  
**Documentation**: confluence.example.com/foodcart
