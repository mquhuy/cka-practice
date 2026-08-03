# Scenario 19: Solution

## Solution

### 1. Check available storage classes

```bash
# List all StorageClasses
kubectl get sc

# Check default StorageClass (marked with *)
kubectl get sc -o wide

# Get detailed info
kubectl describe sc standard
```

### 2. Create PVC with dynamic provisioning

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  storageClassName: standard
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

### 3. Verify dynamic provisioning

```bash
# Check PVC status (should be Bound)
kubectl get pvc

# Describe PVC to see bound PV
kubectl describe pvc dynamic-pvc

# Check PV was automatically created
kubectl get pv

# Note: PV name is auto-generated (e.g., pvc-uuid)
kubectl describe pv | grep dynamic-pvc
```

### 4. Use PVC in pod

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
spec:
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: dynamic-pvc
  containers:
  - name: writer
    image: busybox
    command: ['sh', '-c', 'echo "Hello Storage" > /data/test.txt && sleep 3600']
    volumeMounts:
    - name: data
      mountPath: /data
EOF

# Verify write worked
kubectl exec storage-pod -- cat /data/test.txt
```

---

## Key Concepts

**StorageClass Components:**
- **Provisioner**: Creates PVs (e.g., `kubernetes.io/aws-ebs`, `kubernetes.io/gce-pd`)
- **Parameters**: Provisioner-specific settings
- **ReclaimPolicy**: Delete or Retain when PVC deleted
- **AllowVolumeExpansion**: Allow resizing PVC

**Dynamic Provisioning Flow:**
1. User creates PVC with `storageClassName`
2. K8s detects storage class
3. Provisioner creates PV automatically
4. PV binds to PVC
5. Pod mounts PVC

**Static vs Dynamic:**
- **Static**: Manually create PV first, then PVC binds to it
- **Dynamic**: Just create PVC, PV created automatically

**Reclaim Policies:**
- `Delete`: PV deleted when PVC deleted (default for dynamic)
- `Retain`: PV remains after PVC deletion (manual cleanup needed)

---

## Exam Tips

**Check default StorageClass:**
```bash
kubectl get sc
# Look for (default) marker
```

**Create PVC without specifying class = uses default:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  # No storageClassName = uses default
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

**Common exam tasks:**
- "Create PVC using dynamic provisioning"
- "Check which storage class is default"
- "Expand PVC size" (requires allowVolumeExpansion: true)

**kind cluster specific:**
- Uses `rancher.io/local-path` provisioner
- Stores data in `/var/local-path-provisioner` on host
