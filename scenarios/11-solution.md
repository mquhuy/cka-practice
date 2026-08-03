# Scenario 11: Solution

## Solution

### 1. Create a Job
```bash
kubectl create job pi-job --image=perl:5.34 -- perl -Mbignum=bpi -wle 'print bpi(2000)'

# Or with YAML
kubectl create job pi-job --image=perl:5.34 --dry-run=client -o yaml -- perl -Mbignum=bpi -wle 'print bpi(2000)' > job.yaml
kubectl apply -f job.yaml
```

### 2. Verify Job completion
```bash
# Check Job status (should show Completions: 1/1)
kubectl get jobs

# Wait for completion
kubectl wait --for=condition=complete job/pi-job --timeout=60s

# View the output (π to 2000 places)
kubectl logs -l job-name=pi-job

# Or find the pod specifically
POD=$(kubectl get pods -l job-name=pi-job -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD
```

### 3. Create a CronJob
```bash
kubectl create cj hello-cj --schedule="*/1 * * * *" --image=busybox -- echo "Hello Kubernetes"

# Edit to add retention limits
kubectl edit cj hello-cj

# Add these lines under spec:
# successfulJobsHistoryLimit: 3
# failedJobsHistoryLimit: 1
```

Or with YAML:
```bash
kubectl create cj hello-cj --schedule="*/1 * * * *" --image=busybox -- echo "Hello Kubernetes" --dry-run=client -o yaml > cj.yaml
```

Then edit the YAML to add:
```yaml
spec:
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

Apply:
```bash
kubectl apply -f cj.yaml
```

### 4. Cleanup
```bash
# Delete Job
kubectl delete job pi-job

# Delete CronJob (this also deletes associated jobs)
kubectl delete cj hello-cj

# Verify cleanup
kubectl get jobs
kubectl get cj
```

---

## Key Points

**Jobs:**
- Run to completion (one or more pods)
- `completions`: How many successful pods needed
- `parallelism`: How many running in parallel
- Backoff limits for retries

**CronJobs:**
- Scheduled jobs (cron syntax)
- `successfulJobsHistoryLimit`: Keep old successful jobs
- `failedJobsHistoryLimit`: Keep old failed jobs
- `.spec.schedule`: Cron format (min hour day month dow)

**Cron syntax:**
```
*/1 * * * *  # Every minute
0 */2 * * *  # Every 2 hours
0 0 * * *    # Daily at midnight
0 9 * * 1-5  # 9am weekdays
```
