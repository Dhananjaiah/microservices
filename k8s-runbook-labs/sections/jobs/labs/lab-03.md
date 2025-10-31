# Jobs: CronJob

**Goal**: Create a scheduled job using CronJob.

## Prereqs

- kind or minikube cluster running
- `kubectl` configured

## Steps

```bash
# Create CronJob (runs every minute)
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cron
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:latest
            command: ['sh', '-c', 'date; echo "Hello from CronJob!"']
          restartPolicy: OnFailure
EOF

# Get CronJob status
kubectl get cronjob hello-cron

# Wait for first job to run (wait ~1 minute)
echo "Waiting for CronJob to trigger..."
sleep 70

# Check jobs created by CronJob
kubectl get jobs -l job-name

# Check pods
kubectl get pods -l job-name

# View logs from latest pod
LATEST_POD=$(kubectl get pods -l job-name --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
kubectl logs ${LATEST_POD}

# Describe CronJob
kubectl describe cronjob hello-cron
```

## Verify

- CronJob creates new Job every minute
- Each Job creates a pod
- Pods complete successfully
- History preserved for recent jobs

## Cleanup

```bash
kubectl delete cronjob hello-cron
# Cleanup any remaining jobs
kubectl delete jobs -l job-name 2>/dev/null || true
```

## Key Takeaways

- CronJob uses cron schedule syntax
- Creates Jobs on schedule
- successfulJobsHistoryLimit/failedJobsHistoryLimit control cleanup
- Useful for periodic tasks (backups, reports)
