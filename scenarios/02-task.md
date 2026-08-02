# Task 02: Multi-Container Pod

Create a pod with two containers sharing a volume.

## Requirements

1. Create pod `sidecar` with labels `app=sidecar`
2. Container 1: `main` using `nginx:alpine`
3. Container 2: `logger` using `busybox` with command `sleep 3600`
4. Both containers mount `emptyDir` volume at `/data`
5. Verify both containers are Running

## Verification

```bash
kubectl get pod sidecar
kubectl describe pod sidecar
kubectl exec sidecar -c main -- ls /data
kubectl exec sidecar -c logger -- ls /data
```

## Hints

- Use dry-run to generate YAML: `kubectl run --dry-run=client -o yaml`
- Edit YAML to add second container and volume
- Or create full YAML from scratch
