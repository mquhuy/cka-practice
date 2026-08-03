# Scenario 14: Init Containers

**Time:** 6 minutes | **Difficulty:** Medium

---

## Context

Init containers run before main containers. They're used for setup tasks, waiting for services, or downloading dependencies. All init containers must complete successfully before the main container starts.

---

## Tasks

### 1. Create pod with init container
Create a pod named `init-pod` with:
- **Init container**: `busybox` running `sleep 10` (simulates setup)
- **Main container**: `nginx`
- The init container runs first, then nginx starts

### 2. Verify init container completed
Check that the init container completed and the main pod is running.

### 3. Create multi-init pod
Create a pod named `multi-init-pod` with:
- **Init container 1**: `busybox` running `echo "First init" > /work-done/data`
- **Init container 2**: `busybox` running `cat /work-done/data`
- **Main container**: `nginx` with emptyDir volume at `/data`
- Both init containers share the same emptyDir volume

### 4. Check pod status
Verify all init containers completed and the main container is running.

---

## Hints

<details>
<summary>Init container YAML structure</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
  - name: setup
    image: busybox
    command: ['sh', '-c', 'sleep 10']
  containers:
  - name: nginx
    image: nginx
```
</details>

<details>
<summary>Shared volume between init and main</summary>

```yaml
spec:
  volumes:
  - name: work-dir
    emptyDir: {}
  initContainers:
  - name: first
    image: busybox
    volumeMounts:
    - name: work-dir
      mountPath: /work-done
  containers:
  - name: main
    image: nginx
    volumeMounts:
    - name: work-dir
      mountPath: /data
```
</details>

---

## Verification

```bash
# Check pod status (shows Init: status)
kubectl get pod init-pod

# Check init container logs
kubectl logs init-pod -c setup

# Check events to see init container progress
kubectl describe pod init-pod | grep -A 5 "Init:"

# Verify multi-init pod
kubectl get pod multi-init-pod
kubectl logs multi-init-pod -c first
kubectl logs multi-init-pod -c second
```
