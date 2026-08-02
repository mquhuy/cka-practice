# Scenario: Network Policy

## Objective
Create network policies to restrict traffic between namespaces.

## Setup (run first)
```bash
# Create namespaces
kubectl create namespace frontend
kubectl create namespace backend

# Create test pods
kubectl run -n frontend frontend --image=nginx:alpine --restart=Never
kubectl run -n backend backend --image=nginx:alpine --restart=Never
```

## Tasks
1. Verify frontend can reach backend (should succeed initially)
2. Create network policy in backend namespace to deny all ingress
3. Verify frontend can NO LONGER reach backend
4. Update policy to allow from frontend namespace only

## Solution
```bash
# 1. Test connectivity (should work)
kubectl exec -n frontend frontend -- wget -O- --timeout=3 http://backend.backend 2>&1 | head -5

# 2. Deny-all policy
cat > deny-all.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

kubectl apply -f deny-all.yaml

# 3. Verify blocked (should timeout/fail)
kubectl exec -n frontend frontend -- wget -O- --timeout=3 http://backend.backend 2>&1 | head -5

# 4. Allow from frontend
cat > allow-frontend.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
EOF

# Label frontend namespace
kubectl label namespace frontend name=frontend
kubectl apply -f allow-frontend.yaml
```

## Cleanup
```bash
kubectl delete namespace frontend backend
```
