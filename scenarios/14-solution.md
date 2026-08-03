# Scenario 14: Solution

## Solution

### 1. Create pod with init container

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

```bash
kubectl apply -f - <<EOF
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
EOF
```

### 2. Verify init container completed
```bash
# Watch the pod start (shows Init: 1/1)
kubectl get pod init-pod -w

# After 10 seconds, should show Running
kubectl get pod init-pod

# Check init container logs
kubectl logs init-pod -c setup

# Check events
kubectl describe pod init-pod | grep -A 10 "Init Containers"
```

### 3. Create multi-init pod

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: multi-init-pod
spec:
  volumes:
  - name: work-dir
    emptyDir: {}
  initContainers:
  - name: first
    image: busybox
    command: ['sh', '-c', 'echo "First init" > /work-done/data']
    volumeMounts:
    - name: work-dir
      mountPath: /work-done
  - name: second
    image: busybox
    command: ['sh', '-c', 'cat /work-done/data']
    volumeMounts:
    - name: work-dir
      mountPath: /work-done
  containers:
  - name: main
    image: nginx
    volumeMounts:
    - name: work-dir
      mountPath: /data
EOF
```

### 4. Check pod status
```bash
# Check status
kubectl get pod multi-init-pod

# Should see:
# NAME            STATUS   ...    INIT:   Ready
# multi-init-pod  Running  ...    2/2     1/1

# Check logs from each init container
kubectl logs multi-init-pod -c first
kubectl logs multi-init-pod -c second

# Verify data exists in main container
kubectl exec multi-init-pod -- cat /data/data
# Output: First init
```

---

## Key Points

**Init Container Properties:**
- Run sequentially (in order listed)
- Must all complete before main containers start
- Can share volumes with main containers
- Separate lifecycle from main containers
- Useful for setup, waiting for dependencies, cloning data

**Common Use Cases:**
1. **Wait for service**: `nslookup` or `wget` loop
2. **Clone git repo**: Before app starts
3. **Download files**: From S3, GCS, etc.
4. **Database migrations**: Before app connects
5. **Config generation**: Generate config files

**Exam Tips:**
- Init containers run in order
- If any init fails, pod restarts
- Init containers can have different images than main
- Shared volumes enable data passing between init → main

**Debugging:**
```bash
# Check init container status
kubectl describe pod <name> | grep "Init Containers"

# Check specific init container logs
kubectl logs <name> -c <init-container-name>

# Restart count includes init containers
kubectl get pod <name> -o jsonpath='{.status.initContainerStatuses}'
```
