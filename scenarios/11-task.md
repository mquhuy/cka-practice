# Scenario 11: Jobs & CronJobs

**Time:** 6 minutes | **Difficulty:** Medium

---

## Tasks

### 1. Create a Job
Create a Job named `pi-job` that runs the image `perl:5.34` with the command to calculate π to 2000 decimal places. The Job should complete successfully.

### 2. Verify Job completion
Check that the Job completed successfully and view the output.

### 3. Create a CronJob
Create a CronJob named `hello-cj` that:
- Runs every minute
- Uses image `busybox`
- Runs command: `echo "Hello Kubernetes"`
- Should retain successful jobs for 3, failed jobs for 1

### 4. Cleanup
Delete the Job and CronJob when done.

---

## Hints

<details>
<summary>Job syntax</summary>

```bash
kubectl create job pi-job --image=perl:5.34 -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```
</details>

<details>
<summary>CronJob syntax</summary>

```bash
kubectl create cj hello-cj --schedule="*/1 * * * *" --image=busybox -- echo "Hello Kubernetes"
```
</details>

<details>
<summary>CronJob retention</summary>

```bash
# After creating, edit to add:
# successfulJobsHistoryLimit: 3
# failedJobsHistoryLimit: 1
kubectl edit cj hello-cj
```
</details>

---

## Verification

```bash
# Check Job status
kubectl get jobs
kubectl describe job pi-job

# Check Job output (from pod logs)
kubectl logs -l job-name=pi-job

# Check CronJob
kubectl get cj
kubectl describe cj hello-cj

# Check CronJob jobs
kubectl get jobs -l cronjob=hello-cj
```
