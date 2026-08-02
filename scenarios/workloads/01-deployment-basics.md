# Scenario: Deployment Basics

## Objective
Create a deployment with 3 replicas of nginx, expose it, verify connectivity.

## Tasks
1. Create deployment `web` with image `nginx:1.27` and 3 replicas
2. Verify all pods are Running
3. Expose as NodePort service on port 30080
4. Scale to 5 replicas
5. Update image to `nginx:1.28`
6. Verify rollout succeeded
7. Rollback to previous version

## Solution (hide initially)
```bash
# 1. Create deployment
kubectl create deployment web --image=nginx:1.27 --replicas=3

# 2. Verify
kubectl get pods -l app=web
kubectl describe deployment web

# 3. Expose
kubectl expose deployment web --port=80 --type=NodePort --name=web-svc

# 4. Scale
kubectl scale deployment web --replicas=5

# 5. Update image
kubectl set image deployment/web nginx=nginx:1.28

# 6. Verify rollout
kubectl rollout status deployment/web

# 7. Rollback
kubectl rollout undo deployment/web
```

## Cleanup
```bash
kubectl delete deployment web
kubectl delete service web-svc
```
