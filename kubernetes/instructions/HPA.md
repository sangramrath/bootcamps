# Kubernetes Horizontal Pod Autoscaler (HPA) 

Let's see how to implement Horizontal Pod Autoscaler (HPA) in Kubernetes.

Install and verify metrics server.

```bash
kubectl apply -f 23-metrics-server-components.yaml
```

Watch until the metrics server pod is running and shows 1/1
```bash
watch 'kubectl get pods -n kube-system -o wide'
```

Verify metrics server is working using the following commands:
```bash
kubectl get apiservices -l k8s-app=metrics-server 
```

The output of the above command should be _True_.

```bash
kubectl top node

kubectl top pods
```

Deploy a sample application.

```yaml
kubectl apply -f 24-app-for-hpa.yaml
```

Expose with a ClusterIP service and gather the Service IP:

```bash
kubectl expose deployment autoscale-hpa --type=ClusterIP --port=80

kubectl get svc
```

Create an HPA that targets 50% CPU utilization. Use either the YAML or the command below.

```bash
kubectl apply -f 25-hpa.yaml
```
OR

```bash
kubectl autoscale deployment autoscale-hpa --cpu-percent=10 --min=1 --max=3
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
while true; do wget -q -O- http://<SERVICE-IP>; done
```

---

On another terminal, monitor HPA:

```bash
kubectl get hpa autoscale-hpa -w
```

Check current pods:

```bash
kubectl get pods -l app=autoscale-hpa
```

Delete once done.

```bash
kubectl delete deployment autoscale-hpa
kubectl delete svc autoscale-hpa
kubectl delete hpa autoscale-hpa
kubectl delete pod load-generator
```

