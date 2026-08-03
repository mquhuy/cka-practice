# CKA Lab Setup

## Cluster Status
- **Name**: cka-practice (kind)
- **Nodes**: 3 (1 control-plane, 2 workers)
- **K8s Version**: 1.33.1
- **Context**: `kind-cka-practice`

## Daily Startup
```bash
# Start cluster if stopped
kind start cka-practice 2>/dev/null || kind create cluster --config=kind-cluster.yaml

# Set context
kubectl config use-context kind-cka-practice

# Verify
kubectl get nodes
kubectl get pods -A
```

## Cluster Cleanup
```bash
# Delete cluster
kind delete cluster --name cka-practice

# Full reset
kind delete clusters --all
```

## Practice Checklist
- [ ] Cluster Architecture (control plane, etcd, workers)
- [ ] Workloads (Deployment, StatefulSet, DaemonSet, Jobs)
- [ ] Services & Networking (ClusterIP, NodePort, Ingress, NetworkPolicy)
- [ ] Storage (PV, PVC, StorageClass)
- [ ] Troubleshooting (logs, events, debug)

## Killercoda (Exam-like interface)
https://killercoda.com/kubernetes

Free scenarios matching CKA domains:
- Kubernetes CKS: Security scenarios
- Kubernetes CKA: Administrator scenarios
- Multi-cluster scenarios

## Next: Practice Scenarios
Run `/practice <domain>` to start hands-on exercises:
- `/practice cluster` - Architecture and components
- `/practice workloads` - Deployments, pods, scaling
- `/practice networking` - Services, ingress, policies
- `/practice storage` - PV, PVC, stateful apps
- `/practice troubleshooting` - Debug broken clusters
