# CKA Practice Q&A Index

All your questions and answers from practice sessions, organized by scenario.

## Files

| File | Topics |
|------|--------|
| [01-qa.md](01-qa.md) | Deployments, grading, rollback, dry-run |
| [02-qa.md](02-qa.md) | Multi-container pods, volumes |
| [03-qa.md](03-qa.md) | Node maintenance, cordon, drain, DaemonSets |
| [09-qa.md](09-qa.md) | Scheduling, node affinity, taints, tolerations |
| [services-qa.md](services-qa.md) | Services, ports, NodePort vs ClusterIP |
| [general-qa.md](general-qa.md) | Exam format, grading, cleanup, tips |

## Quick Reference

### Core Concepts
- **Exam grading**: Checks cluster state, not commands
- **Imperative commands**: Faster than YAML for simple tasks
- **dry-run**: Generate YAML without creating (`--dry-run=client -o yaml`)

### Services & Ports
```
External → NodePort (30000-32767)
         → Service Port (ClusterIP)
         → TargetPort (container)
         → ContainerPort (app listens)
```

### Scheduling
- **Node selector**: Hard requirement (must match)
- **Required affinity**: Hard requirement (must match)
- **Preferred affinity**: Soft preference (weighted scoring)
- **Taints**: Repel pods
- **Tolerations**: Allow past taints

### Maintenance
```bash
kubectl cordon <node>     # Mark unschedulable
kubectl drain <node>     # Evict pods
kubectl uncordon <node>   # Make schedulable
```

### Common Issues
- `create svc` doesn't specify NodePort → use `expose`
- `create svc` creates orphan → no selector/endpoints
- `drain` fails → add `--ignore-daemonsets`
- Taint removal → must match `key=value:effect-`

## Study Tips
1. Practice daily with these scenarios
2. Use `--help` during exam
3. Focus on completing tasks
4. Skip and return if stuck
5. Grade yourself to identify gaps
