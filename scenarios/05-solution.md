# Solution 05: PV and PVC

```bash
# Create PV
cat > logs-pv.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: logs-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /tmp/logs
EOF

kubectl apply -f logs-pv.yaml

# Create PVC
cat > logs-pvc.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: logs-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: manual
EOF

kubectl apply -f logs-pvc.yaml

# Verify bound
kubectl get pv,pvc
kubectl get pvc logs-pvc -o jsonpath='{.status.phase}'
```

## Cleanup

```bash
kubectl delete pvc logs-pvc
kubectl delete pv logs-pv
rm logs-pv.yaml logs-pvc.yaml
```
