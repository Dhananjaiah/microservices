# Probes: Readiness Probe

**Goal**: Use readiness probe to control traffic routing.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create deployment with readiness probe
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-ready
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        ports:
        - containerPort: 80
EOF

# Create service
kubectl expose deployment web-ready --port=80

# Wait for pods
sleep 10

# Check pod readiness
kubectl get pods -l app=web

# Check service endpoints (should include ready pods only)
kubectl get endpoints web-ready

# Make one pod unready by breaking nginx
POD_NAME=$(kubectl get pods -l app=web -o jsonpath='{.items[0].metadata.name}')
kubectl exec ${POD_NAME} -- rm /usr/share/nginx/html/index.html

# Wait for readiness probe to fail
sleep 10

# Check endpoints - broken pod removed
kubectl get endpoints web-ready

# Check pod status - still Running but not Ready
kubectl get pods -l app=web
```

## Verify

- Ready pods receive traffic
- Unready pods excluded from service endpoints
- Pod status shows 0/1 Ready when probe fails

## Cleanup

```bash
kubectl delete deployment web-ready
kubectl delete service web-ready
```

## Key Takeaways

- Readiness controls traffic routing
- Failed readiness removes pod from service
- Pod not restarted (unlike liveness)
- Use during initialization or temporary issues
