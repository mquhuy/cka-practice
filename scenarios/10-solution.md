# Solution 10: ConfigMap

```bash
# 1. Create ConfigMap
kubectl create configmap app-config \
  --from-literal=database.url=postgres://localhost:5432 \
  --from-literal=cache.ttl=60s

# Verify
kubectl get configmap app-config -o yaml

# 2. Create pod with ConfigMap volume (YAML)
cat > config-pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: config-test
spec:
  volumes:
  - name: config
    configMap:
      name: app-config
  containers:
  - name: main
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: config
      mountPath: /etc/config
EOF

kubectl apply -f config-pod.yaml

# 3. Verify
kubectl exec config-test -- ls /etc/config
kubectl exec config-test -- cat /etc/config/database.url
kubectl exec config-test -- cat /etc/config/cache.ttl
```

## Cleanup

```bash
kubectl delete pod config-test
kubectl delete configmap app-config
rm config-pod.yaml
```
