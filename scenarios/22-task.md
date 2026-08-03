# Scenario 22: Advanced NetworkPolicy

**Time:** 7 minutes | **Difficulty:** Hard

---

## Context

NetworkPolicy controls traffic flow. Default is allow-all. Implementing deny-all or specific restrictions is common exam task.

---

## Prerequisites

```bash
# Create namespaces
kubectl create namespace frontend
kubectl create namespace backend

# Create test pods
kubectl run web -n frontend --image=nginx --restart=Never
kubectl run api -n backend --image=nginx --restart=Nothing
kubectl run client --image=busybox --restart=Never -- sleep 3600
```

---

## Tasks

### 1. Create deny-all policy in backend
Create NetworkPolicy `deny-all` in `backend` namespace:
- **Deny all ingress** traffic
- **Deny all egress** traffic
- Applies to all pods in namespace

### 2. Allow specific ingress
Add policy `allow-frontend`:
- Allow ingress from `frontend` namespace
- Only to port 80
- Still blocks other ingress

### 3. Allow DNS egress
Add policy `allow-dns`:
- Allow UDP port 53 to CoreDNS
- Pods need DNS for service discovery
- CoreDNS in `kube-system` namespace

### 4. Verify policies work
Test connectivity:
- From `frontend` pod to `backend` pod (should work)
- From `client` pod to `backend` pod (should fail)

---

## Hints

<details>
<summary>Deny all policy</summary>

```yaml
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
```
</details>

<details>
<summary>Allow from namespace</summary>

```yaml
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
```
</details>

<details>
<summary>Allow DNS egress</summary>

```yaml
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
```
</details>

---

## Verification

```bash
# Check policies
kubectl get netpol -n backend
kubectl describe netpol -n backend

# Test from frontend pod (should work)
kubectl exec web -n frontend -- wget -O- http://api.backend --timeout=2

# Test from client pod (should fail/hang)
kubectl exec client -- wget -O- http://api.backend --timeout=2
```
