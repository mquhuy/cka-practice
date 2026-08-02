# Solution 06: RBAC

```bash
# 1. Create namespace
kubectl create namespace development

# 2. Create Role
kubectl create role pod-reader \
  --namespace=development \
  --verb=get,list,watch \
  --resource=pods

# 3. Create RoleBinding
kubectl create rolebinding jane-pod-read \
  --namespace=development \
  --role=pod-reader \
  --user=jane

# 4. Verify access
kubectl auth can-i get pods -n development --as=jane  # yes
kubectl auth can-i list pods -n development --as=jane # yes
kubectl auth can-i delete pods -n development --as=jane # no
kubectl auth can-i create pods -n development --as=jane # no
```

## Cleanup

```bash
kubectl delete namespace development
```
