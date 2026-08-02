# Task 01: Deployment Basics

Create and manage a deployment.

## Requirements

1. Create deployment `web` with image `nginx:1.27`, 3 replicas
2. Expose as NodePort service `web-svc` on port 30080
3. Scale to 5 replicas
4. Update image to `nginx:1.28`
5. Wait for rollout completion
6. Rollback to previous version

## Verification

```bash
kubectl get deployment web
kubectl get pods -l app=web
kubectl get svc web-svc
kubectl rollout history deployment/web
```

## Hints

- Use `kubectl create deployment` for step 1
- Use `kubectl expose` with `--type=NodePort` for step 2
- Use `kubectl scale` for step 3
- Use `kubectl set image` for step 4
- Use `kubectl rollout status` for step 5
- Use `kubectl rollout undo` for step 6
