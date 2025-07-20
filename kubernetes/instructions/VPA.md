# Kubernetes Vertical Pod Autoscaler (VPA)

This guide provides a step-by-step walkthrough to set up and observe **Vertical Pod Autoscaler (VPA)** in a Kubernetes cluster. Designed for trainers and learners, it helps demonstrate how VPA recommends or automatically adjusts CPU/memory for pods based on usage.

---

Before stating ensure Metrics Server is installed.

---

## Install VPA Components

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```

Verify pods are up. There should be 3 pods.

```bash
kubectl get pods -n kube-system | grep vpa
```

---

## Deploy an Application

Create a CPU-intensive app 

```yaml
kubectl apply -f 
```

---

## Create a VPA Resource

```bash
kubectl apply -f vpa.yaml
```

---

## Monitor VPA Recommendations

Wait a few minutes, then run:

```bash
kubectl describe vpa autoscale-vpa
```

Look under the `Recommendations` section for suggested CPU/memory changes.

---

## Trigger an Update

To observe changes, delete the pod and let the new one come up with updated resources:

```bash
kubectl delete pod -l app=autoscale-vpa
```

After restart, check the resources assigned:

```bash
kubectl get pod <pod> -o jsonpath='{.spec.containers[*].resources}'
```

---

## Cleanup

```bash
kubectl delete -f vpa.yaml
kubectl delete -f 
```

---

## Notes

- VPA works best with low-churn workloads.
- `updateMode: Off` is ideal for monitoring recommendations without auto-application.
- For production, pair VPA with HPA carefully to avoid conflicts.

---

