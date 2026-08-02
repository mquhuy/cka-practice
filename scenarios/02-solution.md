# Solution 02: Multi-Container Pod

```bash
# Method 1: Generate and edit
kubectl run sidecar --image=nginx:alpine --restart=Never --labels=app=sidecar --dry-run=client -o yaml > sidecar.yaml
# Edit sidecar.yaml to add second container and volume

# Method 2: Full YAML
cat > sidecar.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: sidecar
  labels:
    app: sidecar
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: main
    image: nginx:alpine
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: logger
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
EOF

kubectl apply -f sidecar.yaml
```

## Verification

```bash
kubectl get pod sidecar
kubectl exec sidecar -c logger -- ls /data
```

## Cleanup

```bash
kubectl delete pod sidecar
rm sidecar.yaml
```
