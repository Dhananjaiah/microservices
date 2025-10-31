# Jobs: Simple Job

**Goal**: Create a job that runs to completion.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create a simple job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-calculator
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:slim
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
EOF

# Watch job status
kubectl get jobs -w &
WATCH_PID=$!

# Wait for completion
sleep 15

kill $WATCH_PID 2>/dev/null || true

# Check job status
kubectl get job pi-calculator

# View pod created by job
kubectl get pods -l job-name=pi-calculator

# Check logs
POD_NAME=$(kubectl get pods -l job-name=pi-calculator -o jsonpath='{.items[0].metadata.name}')
kubectl logs ${POD_NAME} | head -20

# Describe job
kubectl describe job pi-calculator
```

## Verify

- Job status shows 1/1 completions
- Pod status is Completed
- Logs show calculated pi value

## Cleanup

```bash
kubectl delete job pi-calculator
```

## Key Takeaways

- Jobs run pods to completion
- Pod not deleted after completion (for logs)
- backoffLimit controls retry attempts
- restartPolicy must be Never or OnFailure
