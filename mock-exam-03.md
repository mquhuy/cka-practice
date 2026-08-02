# CKA Mock Exam Drill #3

## Exam Rules
- **Time limit**: 30 minutes
- **Domains**: Cluster Arch, Advanced Networking, etcd
- **Weighted**: 42% total

---

## Task 1: Backup etcd (Weight: 8%)
**Time: 6 minutes**

**Note**: kind cluster etcd runs in container. For exam practice, simulate backup.

Given etcd at `https://127.0.0.1:2379`:
1. Create snapshot `/tmp/etcd-backup.db`
2. Use etcdctl with certs:
   - CA cert: `/etc/kubernetes/pki/etcd/ca.crt`
   - Cert: `/etc/kubernetes/pki/etcd/server.crt`
   - Key: `/etc/kubernetes/pki/etcd/server.key`
3. Verify snapshot created

<details>
<summary>Solution</summary>

```bash
# For real cluster (exam):
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db

# Verify
ls -lh /tmp/etcd-backup.db
etcdctl --write-out=table snapshot status /tmp/etcd-backup.db

# For kind (practice):
docker exec cka-practice-control-plane sh -c '
  ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db
'
```
</details>

---

## Task 2: Ingress (Weight: 12%)
**Time: 10 minutes**

Create Ingress routing:
1. Deployment `web` with 2 replicas, image `nginx:alpine`
2. Service `web-svc`: ClusterIP, port 80
3. Ingress `web-ing`:
   - Host: `web.example.com`
   - Path: `/` maps to service web on port 80
   - IngressClassName: `nginx` (create if needed)
4. Verify Ingress created (even if controller not present)

<details>
<summary>Solution</summary>

```bash
# 1. Create deployment and service
kubectl create deployment web --image=nginx:alpine --replicas=2
kubectl expose deployment web --port=80 --name=web-svc

# 2. Create Ingress
kubectl create ingress web-ing \
  --class=nginx \
  --rule="web.example.com/*=web-svc:80"

# Or YAML:
cat > web-ing.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ing
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
EOF

kubectl apply -f web-ing.yaml

# Verify
kubectl get ingress web-ing
kubectl describe ingress web-ing
```
</details>

---

## Task 3: NetworkPolicy (Weight: 10%)
**Time: 8 minutes**

Restrict ingress traffic:
1. Namespace `prod` with pod `app` (nginx:alpine)
2. Namespace `dev` with pod `test` (nginx:alpine)
3. Create NetworkPolicy in `prod`:
   - Deny all ingress by default
   - Allow from namespace `dev` only
   - Allow port 80 only
4. Verify dev can reach prod, but other namespaces cannot

<details>
<summary>Solution</summary>

```bash
# 1. Setup
kubectl create namespace prod
kubectl create namespace dev
kubectl run -n prod app --image=nginx:alpine --restart=Never
kubectl run -n dev test --image=busybox --restart=Never -- sleep 3600

# Label dev namespace for policy
kubectl label namespace dev name=dev

# 2. Create NetworkPolicy
cat > prod-policy.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-allow-dev
  namespace: prod
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: dev
    ports:
    - protocol: TCP
      port: 80
EOF

kubectl apply -f prod-policy.yaml

# 3. Test
kubectl exec -n dev test -- wget -O- --timeout=3 http://app.prod 2>&1 | head -3
# Should succeed

kubectl run -n default random --image=busybox --restart=Never -- sleep 3600
kubectl exec -n default random -- wget -O- --timeout=3 http://app.prod 2>&1 | head -3
# Should timeout/fail
```
</details>

---

## Task 4: Scheduling (Weight: 12%)
**Time: 10 minutes**

Control pod placement:
1. Label nodes: `cka-practice-worker` with `env=prod`, `cka-practice-worker2` with `env=dev`
2. Pod `prod-app` with:
   - Node selector: `env=prod`
   - Resource requests: cpu=50m, memory=64Mi
3. Pod with node affinity:
   - Prefer `env=prod` nodes
   - Weight: 100
4. Taint `env=prod` node with `dedicated=prod:NoSchedule`
5. Create pod with toleration for the taint

<details>
<summary>Solution</summary>

```bash
# 1. Label nodes
kubectl label node cka-practice-worker env=prod
kubectl label node cka-practice-worker2 env=dev

# 2. Pod with node selector
kubectl run prod-app --image=nginx:alpine --restart=Never \
  --requests=cpu=50m,memory=64Mi \
  --node-selector=env=prod

# Verify placement
kubectl get pods -o wide

# 3. Pod with affinity
cat > affinity-pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: affinity-app
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: env
            operator: In
            values:
            - prod
  containers:
  - name: nginx
    image: nginx:alpine
EOF

kubectl apply -f affinity-pod.yaml

# 4. Taint node
kubectl taint nodes cka-practice-worker dedicated=prod:NoSchedule

# 5. Pod with toleration
kubectl run toleration-app --image=nginx:alpine --restart=Never \
  --overrides='
{
  "spec": {
    "tolerations": [{
      "key": "dedicated",
      "operator": "Equal",
      "value": "prod",
      "effect": "NoSchedule"
    }],
    "nodeSelector": {"env": "prod"}
  }
}'

# Verify
kubectl get pods -o wide
kubectl describe node cka-practice-worker | grep -A5 Taints
```
</details>

---

## Scoring
```
Task 1: 8% (etcd backup)
Task 2: 12% (Ingress)
Task 3: 10% (NetworkPolicy)
Task 4: 12% (Scheduling)
---
Total: 42%
```

## Timer
```bash
./timer.sh
```

## Cleanup
```bash
kubectl delete namespace prod dev
kubectl delete ingress web-ing
kubectl delete deployment web service web-svc
kubectl delete pod prod-app affinity-app toleration-app
kubectl label node cka-practice-worker env-
kubectl label node cka-practice-worker2 env-
kubectl taint nodes cka-practice-worker dedicated:NoSchedule-
kubectl delete pod random -n default
```
