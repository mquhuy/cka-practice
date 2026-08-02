# CKA Study Tracker

## Progress Checklist

### Week 1: Core Concepts (Day 1-7)
- [ ] Cluster Architecture
  - [ ] Control plane components (API server, etcd, scheduler, controller)
  - [ ] Worker node components (kubelet, kube-proxy, container runtime)
  - [ ] High availability setup
- [ ] Basic kubectl commands
  - [ ] get/describe/logs
  - [ ] create/delete/apply
  - [ ] dry-run YAML generation
- [ ] Pods
  - [ ] Single/multi-container
  - [ ] Probes (liveness, readiness, startup)
  - [ ] Resource requests/limits
- [ ] Deployments
  - [ ] Create, scale, update
  - [ ] Rollout history, rollback
  - [ ] Revision history

**Practice**: `mock-exam-01.md` (Tasks 1-2)

---

### Week 2: Advanced Workloads + Storage (Day 8-14)
- [ ] StatefulSets
  - [ ] Ordinal pod naming
  - [ ] Stable network identity
  - [ ] Persistent volume templates
- [ ] DaemonSets
  - [ ] Node daemon scheduling
  - [ ] Taint/toleration interaction
- [ ] Jobs/CronJobs
  - [ ] Completion handling
  - [ ] Cron schedule syntax
- [ ] Services
  - [ ] ClusterIP, NodePort, LoadBalancer
  - [ ] Endpoints and EndpointSlices
  - [ ] Headless services
- [ ] Storage
  - [ ] PV, PVC lifecycle
  - [ ] StorageClasses and dynamic provisioning
  - [ ] Access modes (RWO, RWX, ROX)

**Practice**: `mock-exam-02.md` (Tasks 1, 4)

---

### Week 3: Networking + RBAC (Day 15-21)
- [ ] Ingress
  - [ ] Ingress rules and controllers
  - [ ] Path and host routing
- [ ] Network Policies
  - [ ] Default deny
  - [ ] Namespace selectors
  - [ ] Port/protocol rules
- [ ] Scheduling
  - [ ] Node selectors
  - [ ] Node affinity (required/preferred)
  - [ ] Taints and tolerations
  - [ ] Pod topology spread
- [ ] RBAC
  - [ ] Service accounts
  - [ ] Roles vs ClusterRoles
  - [ ] RoleBindings vs ClusterRoleBindings
  - [ ] `kubectl auth can-i`

**Practice**: `mock-exam-03.md` (Tasks 2-4)

---

### Week 4: Cluster Operations + Mock Exams (Day 22-28)
- [ ] Cluster installation
  - [ ] kubeadm init workflow
  - [ ] kubeadm join tokens
  - [ ] Container runtime setup (containerd)
- [ ] Cluster maintenance
  - [ ] Node drain/cordon/uncordon
  - [ ] etcd backup/restore
- [ ] Troubleshooting
  - [ ] CrashLoopBackOff
  - [ ] Image pull errors
  - [ ] Network connectivity
  - [ ] DNS issues
- [ ] Mock exams
  - [ ] Full 2-hour timed drills
  - [ ] Killercoda scenarios

**Practice**: `mock-exam-01.md` (Task 3), `mock-exam-02.md` (Task 3), `mock-exam-03.md` (Task 1)

---

## Command Speed Goals

**Must be automatic (< 10 seconds):**
```bash
kubectl run --image= --restart=Never
kubectl expose --port= --type=NodePort
kubectl scale deployment --replicas=
kubectl set image deployment/= =
kubectl rollout undo deployment/
kubectl top nodes / pods
kubectl auth can-i --as=
```

**Must know without looking:**
- `--dry-run=client -o yaml`
- `--restart=Never` vs `--restart=Always`
- `--requests=cpu=,memory=`
- `--limits=cpu=,memory=`
- `--command -- ` (override entrypoint)

---

## Exam Day Checklist

- [ ] Bookmark kubernetes.io/docs
- [ ] Familiar with exam interface (Killercoda practice)
- [ ] Alias `k=kubectl` (exam provides)
- [ ] Know skip-and-return strategy
- [ ] Practice time management: 7 min per task average
- [ ] Stay calm on first question (warm up)

---

## Mock Exam Scores

| Exam | Date | Score | Pass/Fail | Notes |
|------|------|-------|-----------|-------|
| Mock 01 | __/__ | ___% | __ | Focus: Workloads, Node maintenance |
| Mock 02 | __/__ | ___% | __ | Focus: Storage, RBAC, Debug |
| Mock 03 | __/__ | ___% | __ | Focus: Networking, Scheduling |
| Killercoda | __/__ | ___% | __ | Real exam interface |

**Passing**: 67% overall

---

## Resources

- **Official Docs**: kubernetes.io/docs
- **Killercoda**: killercoda.com/kubernetes
- **This Lab**: `/Users/huy/Projects/CKA`
- **Cluster**: `kind-cka-practice` (3 nodes)

---

## Daily Study Routine

```
1. Warm-up (5 min): kubectl get all -A, check nodes
2. Practice scenario (15 min): Pick from scenarios/
3. Speed drill (10 min): Imperative commands
4. Mock exam (20 min): Timed practice
5. Review (10 min): Check solutions, note gaps
```

**Total**: ~60 min/day

---

## Weakness Log

| Topic | Date | Issue | Action | Resolved |
|-------|------|-------|--------|----------|
| NetworkPolicy | __/__ | _____ | _____ | _____ |
| RBAC bindings | __/__ | _____ | _____ | _____ |
| etcd backup | __/__ | _____ | _____ | _____ |
| Scheduling | __/__ | _____ | _____ | _____ |
