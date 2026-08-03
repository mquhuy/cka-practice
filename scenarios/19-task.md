# Scenario 19: StorageClass & Dynamic Provisioning

**Time:** 5 minutes | **Difficulty:** Medium

---

## Context

Instead of manually creating PVs, use StorageClass for dynamic provisioning. Storage provisioner automatically creates PVs when PVCs are created.

---

## Tasks

### 1. Check available storage classes
List all StorageClasses in the cluster.

### 2. Create PVC with dynamic provisioning
Create PVC `dynamic-pvc`:
- **StorageClass**: `standard` (or default)
- **Access mode**: ReadWriteOnce
- **Size**: 1Gi
- PVC should be automatically bound to created PV

### 3. Verify dynamic provisioning
Check that PV was automatically created and bound to PVC.

### 4. Use PVC in pod
Create pod `storage-pod`:
- Mount the PVC at `/data`
- Write a test file to verify it works

---

## Hints

<details>
<summary>Check default StorageClass</summary>

```bash
kubectl get sc
kubectl get sc standard -o yaml

# Mark as default (if not)
kubectl patch sc standard -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
</details>

<details>
<summary>PVC with StorageClass</summary>

```yaml
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
```
</details>

---

## Verification

```bash
# Check PVC bound
kubectl get pvc
kubectl describe pvc dynamic-pvc

# Check PV automatically created
kubectl get pv

# Check pod can write to volume
kubectl exec storage-pod -- cat /data/test.txt
```
