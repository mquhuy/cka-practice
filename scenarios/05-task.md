# Task 05: PersistentVolume and PersistentVolumeClaim

Create static PV and PVC.

## Requirements

1. Create PV `logs-pv`:
   - Storage: 5Gi
   - AccessMode: ReadWriteOnce
   - StorageClass: `manual`
   - HostPath: `/tmp/logs`
2. Create PVC `logs-pvc`:
   - Request: 2Gi
   - AccessMode: ReadWriteOnce
3. Verify PVC bound to PV

## Verification

```bash
kubectl get pv,pvc
kubectl get pvc logs-pvc -o jsonpath='{.status.phase}'
```

## Hints

- PV needs capacity, accessModes, persistentVolumeReclaimPolicy
- PVC needs accessModes, resources.requests.storage
- Same storageClassName for binding
