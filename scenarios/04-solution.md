# Solution 04: Network Policy

```bash
# Setup
kubectl create namespace frontend
kubectl create namespace backend
kubectl run -n frontend frontend --image=nginx:alpine --restart=Never
kubectl run -n backend backend --image=nginx:alpine --restart=Never --command -- sh -c "nginx && sleep 3600"
kubectl expose pod backend -n backend --port=80

# 1. Test initial connectivity
kubectl exec -n frontend frontend -- wget -O- --timeout=3 http://backend.backend 2>&1 | head -3

# 2. Deny-all policy
cat > deny-all.yaml <<'EOF'
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

# 3. Verify blocked
kubectl exec -n frontend frontend -- wget -O- --timeout=3 http://backend.backend 2>&1 | head -3

# 4. Label and allow frontend
kubectl label namespace frontend name=frontend

cat > allow-frontend.yaml <<'EOF'
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
EOF

kubectl apply -f allow-frontend.yaml

# 5. Verify allowed
kubectl exec -n frontend frontend -- wget -O- --timeout=3 http://backend.backend 2>&1 | head -3
```

## Cleanup

```bash
kubectl delete namespace frontend backend
rm deny-all.yaml allow-frontend.yaml
```
