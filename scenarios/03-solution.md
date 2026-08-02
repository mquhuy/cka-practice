# Solution 03: Node Maintenance

```bash
# 1. List nodes
kubectl get nodes -o wide

# 2. Cordon node
kubectl cordon cka-practice-worker

# 3. Drain node
kubectl drain cka-practice-worker --ignore-daemonsets --force

# 4. Verify pods moved
kubectl get pods -o wide

# 5. Uncordon
kubectl uncordon cka-practice-worker

# 6. Verify
kubectl get nodes
```

## Notes

- Cordon prevents new pods scheduling
- Drain evicts existing pods
- DaemonSets are ignored with --ignore-daemonsets flag
- --force overrides when pods aren't managed by controller
