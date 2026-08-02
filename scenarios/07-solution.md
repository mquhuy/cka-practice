# Solution 07: Troubleshooting

```bash
# Setup
kubectl run broken --image=alpine --restart=Never --command -- /bin/sh -c "exit 1"

# 1. Check status
kubectl get pods
kubectl describe pod broken | grep State

# 2. Debug
kubectl logs broken
kubectl logs broken --previous
kubectl get events --sort-by='.lastTimestamp'

# 3. Fix - replace with working pod
kubectl delete pod broken --force --grace-period=0
kubectl run fixed --image=nginx:alpine --restart=Never -- sleep 3600

# OR edit the pod (not recommended for CrashLoop)
kubectl edit pod broken
# Change command to: ["sleep", "3600"]

# 4. Verify
kubectl get pods
```

## Common CrashLoop Causes

- Command exits non-zero
- Missing required config/secrets
- Image pull errors
- Failed health checks
- Missing volumes

## Cleanup

```bash
kubectl delete pod broken fixed
```
