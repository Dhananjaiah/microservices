# Jobs: Parallel Job

**Goal**: Run multiple job pods in parallel.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create parallel job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-work
spec:
  completions: 5
  parallelism: 2
  template:
    spec:
      containers:
      - name: worker
        image: busybox:latest
        command: ['sh', '-c', 'echo "Processing..."; sleep 10; echo "Done!"']
      restartPolicy: Never
EOF

# Watch pods - max 2 at a time
kubectl get pods -l job-name=parallel-work -w &
WATCH_PID=$!

# Wait for all completions
sleep 40

kill $WATCH_PID 2>/dev/null || true

# Check job status - should show 5/5
kubectl get job parallel-work

# View all completed pods
kubectl get pods -l job-name=parallel-work

# Check logs from one pod
POD_NAME=$(kubectl get pods -l job-name=parallel-work -o jsonpath='{.items[0].metadata.name}')
kubectl logs ${POD_NAME}
```

## Verify

- 5 pods created total
- Maximum 2 pods running simultaneously
- Job completes successfully with 5/5

## Cleanup

```bash
kubectl delete job parallel-work
```

## Key Takeaways

- completions: total successful runs needed
- parallelism: max concurrent pods
- Useful for batch processing
- Parallel execution speeds up work
