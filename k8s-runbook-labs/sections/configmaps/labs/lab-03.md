# ConfigMaps: Volume Mount

**Goal**: Mount ConfigMap as files in pod.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create ConfigMap with file-like data
kubectl create configmap nginx-config \
  --from-literal=index.html='<h1>Hello from ConfigMap!</h1>'

# Create pod with ConfigMap mounted as volume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-volume-pod
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    volumeMounts:
    - name: config-volume
      mountPath: /usr/share/nginx/html
      readOnly: true
    ports:
    - containerPort: 80
  volumes:
  - name: config-volume
    configMap:
      name: nginx-config
EOF

# Wait for pod
sleep 10

# Check if file exists in pod
kubectl exec config-volume-pod -- ls -la /usr/share/nginx/html

# View file content
kubectl exec config-volume-pod -- cat /usr/share/nginx/html/index.html

# Test nginx serving the config
kubectl exec config-volume-pod -- wget -O- http://localhost:80
```

## Verify

- ConfigMap mounted as files
- File content matches ConfigMap
- Nginx serves config content

## Cleanup

```bash
kubectl delete pod config-volume-pod
kubectl delete configmap nginx-config
```

## Key Takeaways

- ConfigMaps can mount as volumes
- Each key becomes a file
- Useful for configuration files
- Changes reflected in pod (with small delay)
