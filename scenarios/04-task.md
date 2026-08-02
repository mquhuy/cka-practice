# Task 04: Network Policy

Restrict traffic between namespaces.

## Setup (run first)

```bash
kubectl create namespace frontend
kubectl create namespace backend
kubectl run -n frontend frontend --image=nginx:alpine --restart=Never
kubectl run -n backend backend --image=nginx:alpine --restart=Never --command -- sh -c "nginx && sleep 3600"
kubectl expose pod backend -n backend --port=80
```

## Requirements

1. Verify frontend can reach backend (should work initially)
2. Create NetworkPolicy `deny-all` in backend namespace to deny all ingress
3. Verify frontend can NO LONGER reach backend
4. Update policy to allow from frontend only
5. Verify frontend CAN reach backend again

## Verification

```bash
# Test connectivity
kubectl exec -n frontend frontend -- wget -O- --timeout=3 http://backend.backend 2>&1 | head -3

# Check policies
kubectl get networkpolicies -A
```

## Hints

- Label frontend namespace for selector
- NetworkPolicy needs podSelector (empty = all pods)
- Use namespaceSelector in ingress rules
