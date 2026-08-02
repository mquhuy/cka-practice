# Solution 01: Deployment Basics

```bash
# 1. Create deployment
kubectl create deployment web --image=nginx:1.27 --replicas=3

# 2. Expose as NodePort
kubectl expose deployment web --port=80 --type=NodePort --name=web-svc

# 3. Scale to 5 replicas
kubectl scale deployment web --replicas=5

# 4. Update image
kubectl set image deployment/web nginx=nginx:1.28

# 5. Wait for rollout
kubectl rollout status deployment/web

# 6. Rollback
kubectl rollout undo deployment/web
```

## Cleanup

```bash
kubectl delete deployment web
kubectl delete service web-svc
```
