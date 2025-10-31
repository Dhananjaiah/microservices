# ConfigMaps: Environment Variables

**Goal**: Use ConfigMap values as environment variables in pods.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create ConfigMap
kubectl create configmap app-config \
  --from-literal=LOG_LEVEL=info \
  --from-literal=APP_PORT=8080

# Create pod using ConfigMap for env vars
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-env-pod
spec:
  containers:
  - name: app
    image: busybox:latest
    command: ['sh', '-c', 'echo "LOG_LEVEL=\$LOG_LEVEL"; echo "APP_PORT=\$APP_PORT"; sleep 3600']
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
    - name: APP_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_PORT
EOF

# Wait for pod
sleep 5

# Check logs - should show env vars
kubectl logs config-env-pod

# Exec into pod to verify
kubectl exec config-env-pod -- env | grep -E "(LOG_LEVEL|APP_PORT)"
```

## Verify

- Environment variables set from ConfigMap
- Pod can access config values
- Values match ConfigMap contents

## Cleanup

```bash
kubectl delete pod config-env-pod
kubectl delete configmap app-config
```

## Key Takeaways

- ConfigMaps inject config as env vars
- Use configMapKeyRef to reference keys
- Pod must be recreated to pick up ConfigMap changes
- Alternative: use envFrom to load all keys
