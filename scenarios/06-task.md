# Task 06: RBAC - Role and RoleBinding

Create limited access for user `jane`.

## Requirements

1. Create namespace `development`
2. Create Role `pod-reader` in development namespace:
   - Can: get, list, watch pods
   - Cannot: create, update, delete
3. Create RoleBinding `jane-pod-read`:
   - Binds Role to user `jane`
4. Verify access: `jane` CAN get pods
5. Verify access: `jane` CANNOT delete pods

## Verification

```bash
kubectl auth can-i get pods -n development --as=jane
kubectl auth can-i delete pods -n development --as=jane
kubectl describe role pod-reader -n development
```

## Hints

- `kubectl create role` with `--verb` and `--resource`
- `kubectl create rolebinding` with `--role` and `--user`
- Use `kubectl auth can-i --as=` to test
