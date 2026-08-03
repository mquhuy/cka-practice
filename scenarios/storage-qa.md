# Storage - Q&A

## Questions & Answers

### Q: What is `emptyDir: {}`?
**A:** Temporary volume created when pod starts, deleted when pod stops. Empty at creation. Used for sharing data between containers in same pod, or as scratch space. Data lost when pod dies.

**Lifecycle:**
- Created: Pod starts
- Deleted: Pod stops
- Content: Gone forever when pod dies

**Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  containers:
  - name: writer
    image: busybox
    volumeMounts:
    - name: shared-data
      mountPath: /data
    command: ["/bin/sh", "-c"]
    args: ["echo hello > /data/file.txt"]
  - name: reader
    image: busybox
    volumeMounts:
    - name: shared-data
      mountPath: /data
    command: ["/bin/sh", "-c", "sleep 10; cat /data/file.txt"]
  volumes:
  - name: shared-data
    emptyDir: {}              # tmp storage on node disk

# RAM-backed (faster, limited by memory)
  volumes:
  - name: cache
    emptyDir:
      medium: Memory          # Uses tmpfs (RAM)
```

**Use cases:**
1. Multi-container pods share data
2. Scratch space for processing
3. Cache before persisting elsewhere

**Not for persistent data** — use PV/PVC instead.

---

## Key Commands
```bash
# Pod with emptyDir
kubectl run pod-with-volume --image=nginx --restart=Never --dry-run=client -o yaml > pod.yaml
# Then edit to add volumes and volumeMounts

# Check volume mounts
kubectl describe pod <name> | grep -A 5 "Mounts:"
```
