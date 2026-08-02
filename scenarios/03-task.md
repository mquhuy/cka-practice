# Task 03: Node Maintenance

Perform maintenance on worker nodes.

## Requirements

1. List all nodes and their roles
2. Cordon node `cka-practice-worker` (mark unschedulable)
3. Drain node `cka-practice-worker` (respect DaemonSets)
4. Verify pods moved to other nodes
5. Uncordon node (make schedulable again)
6. Verify node is Ready

## Verification

```bash
kubectl get nodes
kubectl describe node cka-practice-worker | grep -A5 Taints
kubectl get pods -o wide
```

## Hints

- `kubectl cordon` - mark unschedulable
- `kubectl drain` - evict all pods
- `kubectl uncordon` - mark schedulable
- `--ignore-daemonsets` for drain
