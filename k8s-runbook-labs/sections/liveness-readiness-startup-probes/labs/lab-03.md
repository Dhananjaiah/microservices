# Probes: Startup Probe

**Goal**: Use startup probe for slow-starting applications.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create pod with startup probe (simulates slow start)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: startup-demo
spec:
  containers:
  - name: slow-app
    image: busybox:latest
    command: ['sh', '-c', 'echo "Starting..."; sleep 30; touch /tmp/started; echo "Ready!"; sleep 600']
    startupProbe:
      exec:
        command:
        - cat
        - /tmp/started
      initialDelaySeconds: 0
      periodSeconds: 5
      failureThreshold: 30
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/started
      periodSeconds: 5
EOF

# Watch pod startup
kubectl get pod startup-demo -w &
WATCH_PID=$!

# Pod won't be Ready until startup probe succeeds
sleep 35

kill $WATCH_PID 2>/dev/null || true

# Check pod status
kubectl get pod startup-demo

# Describe to see probe status
kubectl describe pod startup-demo | grep -A 15 "Conditions:"
```

## Verify

- Pod takes ~30s to become Ready
- Startup probe succeeds before liveness activates
- No restarts during slow startup

## Cleanup

```bash
kubectl delete pod startup-demo
```

## Key Takeaways

- Startup probe protects slow-starting apps
- Liveness/readiness disabled until startup succeeds
- Use for legacy apps with long initialization
- failureThreshold * periodSeconds = max startup time
