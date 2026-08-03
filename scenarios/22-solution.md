# Scenario 22: Solution

## Solution

### 1. Create deny-all policy

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
```

### 2. Allow specific ingress

First label the namespace:
```bash
kubectl label namespace frontend name=frontend
```

Create allow policy:
```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    ports:
    - protocol: TCP
      port: 80
EOF
```

### 3. Allow DNS egress

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
    ports:
    - protocol: TCP
      port: 53
EOF
```

### 4. Verify policies

```bash
# List policies
kubectl get netpol -n backend

# Describe specific policy
kubectl describe netpol allow-frontend -n backend

# Test from frontend (should succeed)
kubectl exec web -n frontend -- wget -O- http://api.backend --timeout=2

# Test from client (should fail/timeout)
kubectl exec client -- wget -O- http://api.backend --timeout=2

# Check if pod can do DNS (critical!)
kubectl exec api -n backend -- nslookup kubernetes.default
```

---

## Key Concepts

**NetworkPolicy is whitelist-based:**
- Default: allow all traffic (if no policy)
- Empty ingress/egress array = deny all
- Must explicitly allow what you want

**Selectors:**
- `podSelector`: Which pods policy applies to
- `namespaceSelector`: Match by namespace labels
- `podSelector` + `namespaceSelector`: Both must match

**Policy Types:**
- `Ingress`: Incoming traffic
- `Egress`: Outgoing traffic
- Both can be specified

**DNS is critical:**
- Pods need UDP/TCP 53 to kube-system for DNS
- Without DNS egress, pods can't resolve services
- Always allow DNS when implementing deny-all

---

## Common Patterns

**Deny all, allow specific:**
```yaml
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
  # No rules = deny all
```

**Allow from specific namespace:**
```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        env: production
```

**Allow to specific pods:**
```yaml
egress:
- to:
  - podSelector:
      matchLabels:
        app: database
```

**Allow ports only:**
```yaml
ingress:
- ports:
  - protocol: TCP
    port: 443
```

---

## Exam Tips

**Remember to label namespaces:**
```bash
kubectl label namespace frontend name=frontend
```

**DNS must be allowed:**
```yaml
- to:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: kube-system
  ports:
  - protocol: UDP
    port: 53
```

**Check existing policies first:**
```bash
kubectl get netpol -A
```

**Test with wget/curl:**
```bash
kubectl exec <pod> -- wget -O- http://<service> --timeout=2
```
