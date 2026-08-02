# Scenario: StatefulSet Basics

## Objective
Create a StatefulSet for a database with headless service.

## Tasks
1. Create headless service `redis` for StatefulSet
2. Create StatefulSet `redis` with 3 replicas, image `redis:7`
3. Verify pods have ordinal names (redis-0, redis-1, redis-2)
4. Check persistent volume claims created
5. Scale down to 2 replicas
6. Delete StatefulSet but keep PVCs

## Solution
```bash
# 1. Headless service (ClusterIP=None)
kubectl create service clusterip redis --clusterip="None" --tcp=6379

# 2. StatefulSet - need YAML
cat > redis-sts.yaml <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  serviceName: redis
  replicas: 3
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7
        ports:
        - containerPort: 6379
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF

kubectl apply -f redis-sts.yaml

# 3. Verify pods
kubectl get pods -l app=redis
kubectl get statefulsets

# 4. Check PVCs
kubectl get pvc

# 5. Scale down
kubectl scale statefulset redis --replicas=2

# 6. Delete StatefulSet (keep PVCs)
kubectl delete statefulset redis --cascade=orphan
```

## Cleanup
```bash
kubectl delete statefulset redis
kubectl delete pvc -l app=redis
kubectl delete svc redis
```
