# Probes: Liveness Probe

**Goal**: Use liveness probe to restart unhealthy containers.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create pod with liveness probe that will fail
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: liveness-demo
spec:
  containers:
  - name: app
    image: busybox:latest
    command: ['sh', '-c', 'touch /tmp/healthy; sleep 30; rm /tmp/healthy; sleep 600']
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

# Watch pod - it will restart after /tmp/healthy is removed
kubectl get pods liveness-demo -w &
WATCH_PID=$!

# Wait for liveness probe to fail and restart
sleep 45

kill $WATCH_PID 2>/dev/null || true

# Check restart count
kubectl get pod liveness-demo

# Describe pod to see liveness events
kubectl describe pod liveness-demo | grep -A 10 "Events:"
```

## Verify

- Pod restarts automatically
- Restart count increases
- Events show liveness probe failure

## Cleanup

```bash
kubectl delete pod liveness-demo
```

## Key Takeaways

- Liveness probe detects unhealthy containers
- Failed liveness causes container restart
- Use for applications that might hang/deadlock
- Don't use for startup delays (use startupProbe)
