# Kubernetes Horizontal Pod Autoscaler (HPA) 

Let's see how to implement Horizontal Pod Autoscaler (HPA) in Kubernetes.

Install and verify metrics server.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

```bash
kubectl get deployment metrics-server -n kube-system
```

Deploy a sample application.

```yaml
kubectl apply -f app-for-hpa.yaml
```

Expose with a ClusterIP service:

```bash
kubectl expose deployment scaling-app --type=ClusterIP --port=80
```

Create an HPA that targets 50% CPU utilization. Use either the YAML or the command below.

```bash
kubectl apply -f hpa.yaml
```
OR

```bash
kubectl autoscale deployment cpu-app --cpu-percent=50 --min=1 --max=5
```

Verify:

```bash
kubectl get hpa
```

---

Launch a temporary pod:

```bash
kubectl run -i --tty load-generator --image=busybox /bin/sh
```

From the pod:

```sh
while true; do wget -q -O- http://scaling-app.default.svc.cluster.local; done
```

---

On another terminal, monitor HPA:

```bash
kubectl get hpa hpa-app -w
```

Check current pods:

```bash
kubectl get pods -l app=scaling-app
```

Delete once done.

```bash
kubectl delete deployment scaling-app
kubectl delete svc scaling-app
kubectl delete hpa hpa-app
kubectl delete pod load-generator
```

