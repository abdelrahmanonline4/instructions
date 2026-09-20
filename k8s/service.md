# Kubernetes Services — ClusterIP and NodePort Command Cheat Sheet

## 1. List Services

```bash
kubectl get svc
kubectl get service
kubectl get svc -A
kubectl get svc -o wide
kubectl get svc <service-name>
```

## 2. Create a ClusterIP Service

Create a ClusterIP Service from an existing Deployment:

```bash
kubectl expose deployment nginx \
  --name=nginx-svc \
  --type=ClusterIP \
  --port=80 \
  --target-port=80
```

ClusterIP is the default Service type, so this also works:

```bash
kubectl expose deployment nginx \
  --name=nginx-svc \
  --port=80 \
  --target-port=80
```

Check the Service:

```bash
kubectl get svc nginx-svc
```

## 3. Create a ClusterIP Service with YAML

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

Apply:

```bash
kubectl apply -f service.yaml
```

Delete:

```bash
kubectl delete -f service.yaml
```

## 4. Create a NodePort Service

Create a NodePort Service from an existing Deployment:

```bash
kubectl expose deployment nginx \
  --name=nginx-nodeport \
  --type=NodePort \
  --port=80 \
  --target-port=80
```

Check it:

```bash
kubectl get svc nginx-nodeport
```

Example:

```text
NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)
nginx-nodeport   NodePort   10.96.50.100    <none>        80:30080/TCP
```

Port mapping:

```text
Service Port = 80
NodePort      = 30080
```

## 5. Create a NodePort Service with a Specific NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

Apply:

```bash
kubectl apply -f service.yaml
```

The default NodePort range is normally:

```text
30000-32767
```

## 6. Get Node IP Addresses

```bash
kubectl get nodes -o wide
```

Test a NodePort:

```bash
curl http://<NODE-IP>:30080
```

Example:

```bash
curl http://172.31.18.240:30080
```

## 7. Describe a Service

```bash
kubectl describe svc nginx-nodeport
```

Important fields:

```text
Type
Port
TargetPort
NodePort
Endpoints
Selector
```

## 8. Check Service Endpoints

```bash
kubectl get endpoints nginx-svc
```

Modern approach:

```bash
kubectl get endpointslice
```

Get EndpointSlices for a specific Service:

```bash
kubectl get endpointslice \
  -l kubernetes.io/service-name=nginx-svc
```

## 9. Check Service Selectors

```bash
kubectl describe svc nginx-svc
```

Check Pod labels:

```bash
kubectl get pods --show-labels
```

Find Pods matching a selector:

```bash
kubectl get pods -l app=nginx
```

## 10. Edit a Service

```bash
kubectl edit svc nginx-svc
```

Common fields:

```text
port
targetPort
nodePort
selector
type
```

## 11. Delete a Service

```bash
kubectl delete svc nginx-svc
```

Or:

```bash
kubectl delete service nginx-svc
```

Deleting a Service does not delete the Deployment or its Pods.

## 12. Get the Service YAML

```bash
kubectl get svc nginx-svc -o yaml
```

Wide output:

```bash
kubectl get svc nginx-svc -o wide
```

## 13. Get Only the ClusterIP

```bash
kubectl get svc nginx-svc \
  -o jsonpath='{.spec.clusterIP}'
```

## 14. Get Only the NodePort

```bash
kubectl get svc nginx-nodeport \
  -o jsonpath='{.spec.ports[0].nodePort}'
```

## 15. Test a ClusterIP Service

Create a temporary test Pod:

```bash
kubectl run test \
  --image=curlimages/curl \
  -it --rm -- sh
```

Inside the Pod:

```bash
curl http://nginx-svc
```

Test using the ClusterIP:

```bash
curl http://10.96.216.255
```

## 16. Test Kubernetes DNS

Inside a Pod:

```bash
nslookup nginx-svc
```

Use the full DNS name:

```bash
nslookup nginx-svc.default.svc.cluster.local
```

DNS format:

```text
<service>.<namespace>.svc.cluster.local
```

## 17. Service Troubleshooting Commands

Start with:

```bash
kubectl get svc
```

Then:

```bash
kubectl describe svc <service-name>
```

Check endpoints:

```bash
kubectl get endpoints <service-name>
```

Check EndpointSlices:

```bash
kubectl get endpointslice
```

Check Pods and labels:

```bash
kubectl get pods --show-labels
```

Check Pods matching the Service selector:

```bash
kubectl get pods -l <selector>
```

Inspect the complete Service definition:

```bash
kubectl get svc <service-name> -o yaml
```

Test from inside a Pod:

```bash
curl http://<service-name>:<port>
```

## 18. Port Mapping

Example:

```yaml
ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

The mapping is:

```text
NodePort      = 30080
Service Port  = 80
Container     = 8080
```

Traffic flow:

```text
NodeIP:30080
      |
      v
Service:80
      |
      v
Pod:8080
```

## 19. Service Traffic Flow

### ClusterIP

```text
Pod
 |
 v
Service:80
 |
 v
ClusterIP
 |
 v
Endpoints
 |
 v
Backend Pods
```

### NodePort

```text
External Client
      |
      v
NodeIP:30080
      |
      v
Service:80
      |
      v
Backend Pod:80
```

## 20. Key CKA Notes

Remember:

```text
ClusterIP
  -> Internal cluster access

NodePort
  -> NodeIP:NodePort
  -> Exposes the Service through each Node

port
  -> Service port

targetPort
  -> Backend Pod/container port

nodePort
  -> Port exposed on the Node
```

Example:

```yaml
ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

Traffic:

```text
NodeIP:30080
      |
      v
Service:80
      |
      v
Pod:8080
```
