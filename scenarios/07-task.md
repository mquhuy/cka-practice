# Task 07: Troubleshooting CrashLoopBackOff

Debug and fix a failing pod.

## Setup (run first)

```bash
kubectl run broken --image=alpine --restart=Never --command -- /bin/sh -c "exit 1"
```

## Requirements

1. Identify pod is in CrashLoopBackOff state
2. Find root cause using logs/describe/events
3. Fix the pod to run successfully
4. Verify pod stays Running

## Verification

```bash
kubectl get pod broken
kubectl logs broken
kubectl describe pod broken | grep -A20 Events:
```

## Hints

- `kubectl logs <pod>` - current logs
- `kubectl logs <pod> --previous` - previous attempt logs
- `kubectl describe pod <pod>` - events and state
- `kubectl get events` - cluster events
