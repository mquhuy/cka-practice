# Task 10: ConfigMap with Volume Mount

Create ConfigMap and mount to pod.

## Requirements

1. Create ConfigMap `app-config` with:
   - `database.url=postgres://localhost:5432`
   - `cache.ttl=60s`
2. Create pod `config-test` mounting ConfigMap as volume at `/etc/config`
3. Verify files exist in pod with correct content

## Verification

```bash
kubectl get configmap app-config -o yaml
kubectl exec config-test -- ls /etc/config
kubectl exec config-test -- cat /etc/config/database.url
kubectl exec config-test -- cat /etc/config/cache.ttl
```

## Hints

- `kubectl create configmap` with `--from-literal`
- For volume mount, use YAML or `--overrides`
- ConfigMap volume needs `name: config`, `configMap.name: app-config`
