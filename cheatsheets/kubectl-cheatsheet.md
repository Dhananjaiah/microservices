# kubectl Cheat Sheet

## 🎯 Quick Reference

The fastest kubectl commands for the CKA exam and daily Kubernetes operations.

---

## 🔧 Setup & Configuration

### Contexts and Clusters

```bash
# List all contexts
kubectl config get-contexts

# Show current context
kubectl config current-context

# Switch context (EXAM CRITICAL!)
kubectl config use-context <context-name>

# Set default namespace for current context
kubectl config set-context --current --namespace=<namespace>

# View kubeconfig
kubectl config view

# Get cluster info
kubectl cluster-info

# Check API server health
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
```

---

## 📦 Resource Management (Imperative)

### Pods

```bash
# Create a pod (imperative)
kubectl run nginx --image=nginx

# Create pod with specific restart policy
kubectl run busybox --image=busybox --restart=Never

# Create pod and expose port
kubectl run nginx --image=nginx --port=80

# Create pod with environment variable
kubectl run nginx --image=nginx --env="ENV=prod"

# Create pod with labels
kubectl run nginx --image=nginx --labels="app=web,tier=frontend"

# Create pod with resource limits
kubectl run nginx --image=nginx --requests='cpu=100m,memory=256Mi' --limits='cpu=200m,memory=512Mi'

# Create pod with command
kubectl run busybox --image=busybox --command -- sleep 3600

# Create pod with args
kubectl run busybox --image=busybox -- sh -c "echo hello; sleep 3600"

# Dry run (generate YAML without creating)
kubectl run nginx --image=nginx --dry-run=client -o yaml

# Save YAML to file
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
```

### Deployments

```bash
# Create deployment
kubectl create deployment web --image=nginx

# Create deployment with replicas
kubectl create deployment web --image=nginx --replicas=3

# Generate deployment YAML
kubectl create deployment web --image=nginx --dry-run=client -o yaml > deploy.yaml

# Scale deployment
kubectl scale deployment web --replicas=5

# Set image (rolling update)
kubectl set image deployment/web nginx=nginx:1.21

# Rollout status
kubectl rollout status deployment/web

# Rollout history
kubectl rollout history deployment/web

# Rollback to previous version
kubectl rollout undo deployment/web

# Rollback to specific revision
kubectl rollout undo deployment/web --to-revision=2

# Pause rollout
kubectl rollout pause deployment/web

# Resume rollout
kubectl rollout resume deployment/web
```

### Services

```bash
# Expose deployment as ClusterIP (default)
kubectl expose deployment web --port=80 --target-port=80

# Expose as NodePort
kubectl expose deployment web --port=80 --type=NodePort

# Expose as LoadBalancer
kubectl expose deployment web --port=80 --type=LoadBalancer

# Expose pod
kubectl expose pod nginx --port=80

# Create service from YAML
kubectl create service clusterip web --tcp=80:80

# Generate service YAML
kubectl expose deployment web --port=80 --dry-run=client -o yaml > svc.yaml
```

### ConfigMaps & Secrets

```bash
# Create ConfigMap from literal
kubectl create configmap app-config --from-literal=key1=value1 --from-literal=key2=value2

# Create ConfigMap from file
kubectl create configmap app-config --from-file=config.txt

# Create ConfigMap from directory
kubectl create configmap app-config --from-file=configs/

# Create Secret from literal
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=secret

# Create Secret from file
kubectl create secret generic db-secret --from-file=./username.txt --from-file=./password.txt

# Create TLS Secret
kubectl create secret tls tls-secret --cert=path/to/cert.crt --key=path/to/key.key

# Create Docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.com \
  --docker-username=user \
  --docker-password=pass \
  --docker-email=email@example.com
```

### Namespaces

```bash
# Create namespace
kubectl create namespace dev

# Set default namespace
kubectl config set-context --current --namespace=dev

# List all namespaces
kubectl get namespaces
kubectl get ns

# Delete namespace (and all resources in it!)
kubectl delete namespace dev
```

---

## 🔍 Viewing & Finding Resources

### Get Resources

```bash
# Get pods (current namespace)
kubectl get pods
kubectl get po

# Get all pods (all namespaces)
kubectl get pods -A
kubectl get pods --all-namespaces

# Get pods with more details
kubectl get pods -o wide

# Get pods with labels
kubectl get pods --show-labels

# Get pods with specific label
kubectl get pods -l app=web
kubectl get pods --selector=app=web

# Get pods and sort by creation time
kubectl get pods --sort-by=.metadata.creationTimestamp

# Get pods and show node they're running on
kubectl get pods -o wide

# Get all resources in namespace
kubectl get all

# Get all resources in all namespaces
kubectl get all -A

# Get specific resource types
kubectl get pods,services,deployments

# Get with custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

# Get with JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# Watch resources (auto-refresh)
kubectl get pods -w
kubectl get pods --watch
```

### Describe Resources

```bash
# Describe pod (detailed info)
kubectl describe pod nginx

# Describe deployment
kubectl describe deployment web

# Describe node
kubectl describe node node1

# Describe service
kubectl describe service web

# Describe with namespace
kubectl describe pod nginx -n dev
```

### Logs

```bash
# Get pod logs
kubectl logs nginx

# Get logs from previous container (after crash)
kubectl logs nginx --previous

# Get logs for specific container in pod
kubectl logs nginx -c sidecar

# Follow logs (tail -f)
kubectl logs nginx -f
kubectl logs nginx --follow

# Get last 50 lines
kubectl logs nginx --tail=50

# Get logs since specific time
kubectl logs nginx --since=1h
kubectl logs nginx --since=2024-01-01T00:00:00Z

# Get logs for all pods with label
kubectl logs -l app=web

# Get logs for all containers in pod
kubectl logs nginx --all-containers=true
```

### Events

```bash
# Get events (current namespace)
kubectl get events

# Get events (all namespaces)
kubectl get events -A

# Get events sorted by timestamp
kubectl get events --sort-by='.lastTimestamp'

# Watch events
kubectl get events -w

# Get events for specific resource
kubectl get events --field-selector involvedObject.name=nginx
```

---

## 🛠️ Editing & Updating Resources

### Edit Resources

```bash
# Edit pod (opens in $EDITOR)
kubectl edit pod nginx

# Edit deployment
kubectl edit deployment web

# Edit with specific editor
KUBE_EDITOR="nano" kubectl edit deployment web

# Replace resource from file
kubectl replace -f pod.yaml

# Replace with force (delete and recreate)
kubectl replace -f pod.yaml --force
```

### Patch Resources

```bash
# Patch deployment (merge)
kubectl patch deployment web -p '{"spec":{"replicas":5}}'

# Patch with JSON
kubectl patch deployment web --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value":5}]'

# Patch node (add label)
kubectl patch node node1 -p '{"metadata":{"labels":{"disktype":"ssd"}}}'
```

### Set Commands

```bash
# Set image
kubectl set image deployment/web nginx=nginx:1.21

# Set resources
kubectl set resources deployment web --limits=cpu=200m,memory=512Mi --requests=cpu=100m,memory=256Mi

# Set service account
kubectl set serviceaccount deployment web sa-name

# Set environment variable
kubectl set env deployment/web ENV=prod

# Set environment from ConfigMap
kubectl set env deployment/web --from=configmap/app-config

# Set environment from Secret
kubectl set env deployment/web --from=secret/db-secret
```

### Label & Annotate

```bash
# Add label to pod
kubectl label pod nginx tier=frontend

# Add label to node
kubectl label node node1 disktype=ssd

# Remove label
kubectl label pod nginx tier-

# Overwrite existing label
kubectl label pod nginx tier=backend --overwrite

# Add annotation
kubectl annotate pod nginx description="My nginx pod"

# Remove annotation
kubectl annotate pod nginx description-

# Show labels
kubectl get pods --show-labels
```

---

## 🗑️ Deleting Resources

```bash
# Delete pod
kubectl delete pod nginx

# Delete deployment
kubectl delete deployment web

# Delete service
kubectl delete service web

# Delete from file
kubectl delete -f pod.yaml

# Delete all pods with label
kubectl delete pods -l app=web

# Delete all pods in namespace
kubectl delete pods --all

# Delete all resources in namespace
kubectl delete all --all

# Delete namespace (and everything in it)
kubectl delete namespace dev

# Force delete pod (immediate, no graceful shutdown)
kubectl delete pod nginx --grace-period=0 --force

# Delete with cascade (default, deletes dependent resources)
kubectl delete deployment web --cascade=foreground

# Delete without cascade (leaves pods running)
kubectl delete deployment web --cascade=orphan
```

---

## 🔐 RBAC & Security

### Service Accounts

```bash
# Create service account
kubectl create serviceaccount sa-name

# Get service accounts
kubectl get serviceaccounts
kubectl get sa

# Describe service account
kubectl describe sa sa-name
```

### Roles & RoleBindings

```bash
# Create role (namespace-scoped)
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Create clusterrole (cluster-scoped)
kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods

# Create rolebinding
kubectl create rolebinding user-pod-reader --role=pod-reader --user=john

# Create clusterrolebinding
kubectl create clusterrolebinding user-pod-reader --clusterrole=pod-reader --user=john

# Bind to service account
kubectl create rolebinding sa-pod-reader --role=pod-reader --serviceaccount=default:sa-name

# Check permissions
kubectl auth can-i create pods
kubectl auth can-i create pods --as john
kubectl auth can-i create pods --as system:serviceaccount:default:sa-name -n dev

# List permissions for user
kubectl auth can-i --list --as john
```

---

## 💾 Storage

### PersistentVolumes & PersistentVolumeClaims

```bash
# Get PVs
kubectl get pv

# Get PVCs
kubectl get pvc

# Describe PV
kubectl describe pv pv-name

# Describe PVC
kubectl describe pvc pvc-name

# Create PVC from YAML
kubectl apply -f pvc.yaml

# Delete PVC
kubectl delete pvc pvc-name
```

---

## 🌐 Networking

### Network Policies

```bash
# Get network policies
kubectl get networkpolicies
kubectl get netpol

# Describe network policy
kubectl describe networkpolicy deny-all

# Apply network policy
kubectl apply -f netpol.yaml
```

### Ingress

```bash
# Get ingress
kubectl get ingress
kubectl get ing

# Describe ingress
kubectl describe ingress my-ingress

# Apply ingress
kubectl apply -f ingress.yaml
```

---

## 📊 Debugging & Troubleshooting

### Interactive Debugging

```bash
# Execute command in pod
kubectl exec nginx -- ls /

# Interactive shell in pod
kubectl exec -it nginx -- /bin/bash
kubectl exec -it nginx -- sh

# Execute in specific container
kubectl exec -it nginx -c sidecar -- /bin/bash

# Copy files to/from pod
kubectl cp nginx:/tmp/file.txt ./file.txt
kubectl cp ./file.txt nginx:/tmp/file.txt
```

### Port Forwarding

```bash
# Forward local port to pod
kubectl port-forward nginx 8080:80

# Forward to deployment
kubectl port-forward deployment/web 8080:80

# Forward to service
kubectl port-forward service/web 8080:80

# Listen on all interfaces
kubectl port-forward --address 0.0.0.0 nginx 8080:80
```

### Run Temporary Pods

```bash
# Run temporary pod for testing
kubectl run test --image=busybox --restart=Never --rm -it -- sh

# Run with specific command
kubectl run test --image=curlimages/curl --restart=Never --rm -it -- curl http://web:80

# Run for DNS testing
kubectl run test-dns --image=busybox --restart=Never --rm -it -- nslookup kubernetes.default

# Run nginx and expose it
kubectl run nginx --image=nginx --restart=Never --expose --port=80
```

### Resource Usage

```bash
# Get node resource usage (requires metrics-server)
kubectl top nodes

# Get pod resource usage
kubectl top pods

# Get pod resource usage in all namespaces
kubectl top pods -A

# Get resource usage for specific pod
kubectl top pod nginx

# Sort by CPU
kubectl top pods --sort-by=cpu

# Sort by memory
kubectl top pods --sort-by=memory
```

---

## 🔧 Node Operations

### Node Management

```bash
# Get nodes
kubectl get nodes

# Describe node
kubectl describe node node1

# Cordon node (mark unschedulable)
kubectl cordon node1

# Drain node (evict pods)
kubectl drain node1 --ignore-daemonsets --delete-emptydir-data

# Uncordon node (mark schedulable)
kubectl uncordon node1

# Label node
kubectl label node node1 disktype=ssd

# Taint node
kubectl taint node node1 key=value:NoSchedule

# Remove taint
kubectl taint node node1 key=value:NoSchedule-
```

---

## 📝 Advanced Operations

### Explain Resources

```bash
# Explain resource
kubectl explain pod

# Explain nested fields
kubectl explain pod.spec

# Explain with recursive
kubectl explain pod.spec.containers

# Show all fields
kubectl explain pod --recursive
```

### Apply & Diff

```bash
# Apply configuration
kubectl apply -f pod.yaml

# Apply directory
kubectl apply -f ./manifests/

# Dry run (server-side validation)
kubectl apply -f pod.yaml --dry-run=server

# Dry run (client-side)
kubectl apply -f pod.yaml --dry-run=client

# Show diff before applying
kubectl diff -f pod.yaml

# Apply and record change-cause
kubectl apply -f pod.yaml --record
```

### Wait for Conditions

```bash
# Wait for pod to be ready
kubectl wait --for=condition=ready pod/nginx --timeout=60s

# Wait for all pods to be ready
kubectl wait --for=condition=ready pods --all --timeout=300s

# Wait for deployment to be available
kubectl wait --for=condition=available deployment/web --timeout=300s

# Wait for deletion
kubectl wait --for=delete pod/nginx --timeout=60s
```

---

## 🚀 Exam-Specific Tips

### Speed Aliases (Add to ~/.bashrc)

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdelf='kubectl delete -f'
export do="--dry-run=client -o yaml"
export now="--grace-period=0 --force"
```

**Usage**:
```bash
k run nginx --image=nginx $do > pod.yaml
k delete pod nginx $now
```

### Fast YAML Generation

```bash
# Pod
kubectl run nginx --image=nginx $do > pod.yaml

# Deployment
kubectl create deployment web --image=nginx --replicas=3 $do > deploy.yaml

# Service
kubectl expose deployment web --port=80 $do > svc.yaml

# ConfigMap
kubectl create configmap app-config --from-literal=key=value $do > cm.yaml

# Secret
kubectl create secret generic db-secret --from-literal=pass=secret $do > secret.yaml

# Job
kubectl create job test --image=busybox $do -- echo "hello" > job.yaml

# CronJob
kubectl create cronjob test --image=busybox --schedule="*/5 * * * *" $do -- echo "hello" > cronjob.yaml
```

### Context Switching (Critical!)

```bash
# Always check current context first
kubectl config current-context

# Switch context
kubectl config use-context cluster-name

# Switch and verify
kubectl config use-context cluster-name && kubectl config current-context
```

### Quick Debugging Commands

```bash
# Check if pod is running
kubectl get pod nginx -o jsonpath='{.status.phase}'

# Get pod IP
kubectl get pod nginx -o jsonpath='{.status.podIP}'

# Get pod node
kubectl get pod nginx -o jsonpath='{.spec.nodeName}'

# Get all container images
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}'

# Check events for errors
kubectl get events --sort-by='.lastTimestamp' | grep -i error

# Quick DNS test
kubectl run test --image=busybox --restart=Never --rm -it -- nslookup kubernetes.default
```

---

## 📚 Additional Resources

### Official Documentation
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubectl Commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
- [JSONPath Support](https://kubernetes.io/docs/reference/kubectl/jsonpath/)

### Practice
- Use `kubectl explain` extensively during practice
- Practice typing commands without autocomplete initially
- Create your own cheat sheet with commands you forget

---

**Pro Tip**: During the exam, you can use `kubectl` autocomplete and the official Kubernetes documentation. Practice using both efficiently!
