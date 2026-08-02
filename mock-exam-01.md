# CKA Mock Exam Drill #1

## Exam Rules (simulated)
- **Time limit**: 20 minutes (2-3 tasks)
- **Weighted**: Cluster, Workloads, Networking
- **Docs allowed**: kubernetes.io/docs
- **Imperative commands OK**: `kubectl run`, `expose`, `scale`
- **Context**: `kind-cka-practice` (pre-configured)

---

## Task 1: Multi-Container Pod (Weight: 4%)
**Time: 5 minutes**

Create a pod named `sidecar` in namespace `default` with:
- Container 1: `main`, image `nginx:alpine`, name label `app=sidecar`
- Container 2: `logger`, image `busybox`, command `sleep 3600`
- Both containers share volume `/data` (emptyDir)

Verify pod runs with both containers ready.

<details>
<summary>Solution</summary>

```bash
kubectl run sidecar --image=nginx:alpine --restart=Never --labels=app=sidecar --dry-run=client -o yaml > sidecar.yaml
# Edit sidecar.yaml to add second container and volume
```

Or full YAML:
```bash
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
kubectl get pod sidecar
```
</details>

---

## Task 2: Deployment Update (Weight: 8%)
**Time: 6 minutes**

Given existing deployment `web` (3 replicas, nginx:1.26):
1. Update image to `nginx:1.28`
2. Wait for rollout to complete
3. Verify all pods running new image
4. Rollback to previous version

<details>
<summary>Solution</summary>

```bash
# Create web deployment first (if not exists)
kubectl create deployment web --image=nginx:1.26 --replicas=3

# Update image
kubectl set image deployment/web nginx=nginx:1.28

# Wait for rollout
kubectl rollout status deployment/web

# Verify image version
kubectl get pods -l app=web -o jsonpath='{.items[*].spec.containers[0].image}'

# Rollback
kubectl rollout undo deployment/web
kubectl rollout status deployment/web
```
</details>

---

## Task 3: Node Maintenance (Weight: 5%)
**Time: 5 minutes**

Worker node `cka-practice-worker` needs maintenance:
1. Cordon the node (mark unschedulable)
2. Drain all pods (respect DaemonSets)
3. Verify pods moved to other nodes
4. Mark node schedulable again

<details>
<summary>Solution</summary>

```bash
# Cordon
kubectl cordon cka-practice-worker
kubectl get nodes

# Drain (ignore daemonsets if any)
kubectl drain cka-practice-worker --ignore-daemonsets --force

# Verify pods moved
kubectl get pods -o wide

# Make schedulable
kubectl uncordon cka-practice-worker
kubectl get nodes
```
</details>

---

## Task 4: Service with Endpoint (Weight: 6%)
**Time: 6 minutes**

Create ClusterIP service `api`:
- Port 80, targetPort 8080
- Selector: `tier=backend`
- Manually create endpoint pointing to `10.244.1.5:8080`
- Verify service has endpoint

<details>
<summary>Solution</summary>

```bash
# Create service (no pods exist yet)
kubectl create service clusterip api --tcp=80:8080 --dry-run=client -o yaml | \
  sed 's/selector: null/selector:\n    tier: backend/' | kubectl apply -f -

# Or manual YAML
cat > api-svc.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    tier: backend
EOF

kubectl apply -f api-svc.yaml

# Create endpoint manually
cat > api-ep.yaml <<'EOF'
apiVersion: v1
kind: Endpoints
metadata:
  name: api
subsets:
  - addresses:
    - ip: 10.244.1.5
    ports:
    - port: 8080
EOF

kubectl apply -f api-ep.yaml

# Verify
kubectl get svc api
kubectl get endpoints api
```
</details>

---

## Scoring
```
Task 1: 4% (Multi-container pod with shared volume)
Task 2: 8% (Deployment update + rollback)
Task 3: 5% (Node drain/uncordon)
Task 4: 6% (Service + manual endpoint)
---
Total: 23% (Full exam = 100%)
```

## Timer
```bash
# Start timer
export START=$(date +%s)

# Check elapsed
echo "$(( ($(date +%s) - START) / 60 )) minutes"
```

## Cleanup
```bash
kubectl delete pod sidecar
kubectl delete deployment web
kubectl delete svc api
kubectl delete endpoints api
```

## Notes
- Real exam: 2 hours, 15-20 tasks, 67% to pass
- Focus on completing tasks, not perfection
- Skip if stuck, return later
- Use `--help` for command syntax
