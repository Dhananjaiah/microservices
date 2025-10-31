# ConfigMaps: Create from Literal

**Goal**: Create ConfigMap from literal values.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create ConfigMap from literals
kubectl create configmap app-config \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=MAX_CONNECTIONS=100 \
  --from-literal=API_URL=https://api.example.com

# View ConfigMap
kubectl get configmap app-config

# Describe ConfigMap
kubectl describe configmap app-config

# View ConfigMap YAML
kubectl get configmap app-config -o yaml

# Edit ConfigMap
kubectl edit configmap app-config

# Create from file
echo "database=postgresql" > /tmp/db.properties
echo "port=5432" >> /tmp/db.properties
kubectl create configmap db-config --from-file=/tmp/db.properties

# View file-based ConfigMap
kubectl get configmap db-config -o yaml
```

## Verify

- ConfigMap contains specified key-value pairs
- Can view and edit ConfigMap
- File contents stored as single key

## Cleanup

```bash
kubectl delete configmap app-config db-config
rm -f /tmp/db.properties
```

## Key Takeaways

- ConfigMaps store configuration data
- Created from literals, files, or directories
- Separate config from application code
- Non-confidential data only (use Secrets for sensitive data)
