# Task 08: Ingress

Create Ingress for routing.

## Requirements

1. Create deployment `web` with 2 replicas, image `nginx:alpine`
2. Create ClusterIP service `web-svc`, port 80
3. Create Ingress `web-ing`:
   - Host: `web.example.com`
   - Path: `/` routes to service web on port 80
   - IngressClassName: `nginx`
4. Verify Ingress created

## Verification

```bash
kubectl get ingress web-ing
kubectl describe ingress web-ing
kubectl get svc,pods -l app=web
```

## Hints

- `kubectl create ingress` with `--rule`
- Rule format: `host/path=service:port`
- Or use YAML with `ingressClassName`
