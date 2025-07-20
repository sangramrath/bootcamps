
## Node operations

Label a node as worker node
```bash
kubectl label node <NodeName> node-role.kubernetes.io/worker=worker
```

To view detailed information on a resource/object use the `-o wide` flag. For example:
```bash
kubectl get nodes -o wide

kubectl get pods -o wide
```

## Clone the sample files

NOTE: `git` must be available/installed on the system
```bash
git clone

cd 2170/solution/CH09
```

## Installing and running `kube-bench`
For the purposes of this demonstration, `kube-bench` was installed on the control plane node.

```bash
mkdir kube-bench
curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.6.2/kube-bench_0.6.2_linux_amd64.tar.gz -o kube-bench_0.6.2_linux_amd64.tar.gz

tar -xvf kube-bench_0.6.2_linux_amd64.tar.gz
```

Run `kube-bench` on all nodes of the cluster.
```bash
./kube-bench --config-dir cfg/ --config cfg/config.yaml
```

## Pods

To create a static pod using a YAML file, use the `kubectl apply` command:
```bash
kubectl apply -f 00-pod.yaml
```

## Deployments

To create a deployment _Deployment_ using the provided YAML file run:
```bash
kubectl apply -f 01-deployment.yaml
```

To scale a _Deployment_ through the YAML, edit the YAML file and replace `replicas` value with the desired number.
Then use `kubectl apply` command to apply the changes to the deployment.
```bash
kubectl apply -f 01-deployment.yaml
```

You can also scale a _Deployment_ using the `kubectl` command.
```bash
kubectl scale --replicas=3 deployment.apps/kcnaprep
```

Verify deployment or check the number of pods using the following commands:
```bash
kubectl get deployment kcnaprep
```

```bash
kubectl get pods -l app=kcnaprep
```

Working with deployment rollouts
```bash
kubectl rollout history deployment/kcnaprep-d

kubectl rollout undo deployment/kcnaprep-d

kubectl rollout undo deployment/kcnaprep-d --to-revision=2
```

To record rollouts
```bash
kubectl apply -f 01-deployment.yaml --record=true
```



## Services

NOTE: Labels are a must for exposing _Pods_ or _Services_.

First, delete the Pod. Next, either edit the `pod.yaml` to add _labels_ (follow the instructor) or run the following file that includes the changes:
```bash
kubectl apply -f 02-pod-labels.yaml
```

To expose the Pod created using a service run:
```bash
kubectl apply -f 03-service-ClusterIP-pod.yaml
```

(Optional) You can also expose a Pod/Deployment using the kubectl command:
```bash
kubectl expose pod kcnaprep --target-port=3000 --port=80 --name=kcnaprep
```

Verify
```bash
kubectl get svc

kubectl get endpoints
```

Now, let's expose the deployment created earlier using a NodePort.
```bash
kubectl apply -f 05-service-NodePort-deployment.yaml
```

## Ingress

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.0/deploy/static/provider/cloud/deploy.yaml
```

Watch until the pods are ready:
```bash
watch 'kubectl get pods --namespace=ingress-nginx'
```

## PV and PVC

### Static
```bash
kubectl apply -f 07-pv-static.yaml
```

```bash
kubectl apply -f 08-deployment-with-pvc.yaml
```

Run `kubectl get pods -o wide` and identify the node where the _Pods_ are running. Connect to one of them and looks for `/data/log` folder where files will be persisted. 

To verify that persistence works, you can create some files from the node or from the Pod and cross verify. To connect to a Pod use the `kubectl exec` command below:
```bash
kubectl exec <podname> -it -- sh
```

### Dynamic
Install Rancher local path provisioner.
```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml
```

```bash
kubectl apply -f 09-storageclass.yaml
```

NOTE: The following YAML also covers _StatefulSet_ creation.
```bash
kubectl apply -f 10-statefulset-dynamic-pvc.yaml
```

## DaemonSet

```bash
kubectl apply -f 11-daemonset.yaml
```

## General YAML of Resources / Dry Run

To generate a YAML of a deployment:
```bash
kubectl create deployment fromcli --image=nginx --dry-run=client -o yaml > nginx-d.yaml
```

To dry run an existing YAML:
```bash
kubectl apply -f 01-deployment.yaml --dry-run=client -o yaml
```

## ConfigMaps

Create a _ConfigMap_ from the provided YAML file:
```bash
kubectl apply -f 12-configmap.yaml
```

```bash
kubectl apply -f 13-deployment-with-cm.yaml
```

Verify pods with `kubectl get` command.

```bash
kubectl exec -it <PODNAME> -- psql -h localhost -U pguser --password -p 5432 pgdb 
```

## Secrets

Move the password from _ConfigMap_ to _Secret_
```bash
kubectl apply -f 14-secret.yaml
```

Update the deployment
```bash
kubectl apply -f 15-deployment-with-secret.yaml
```

## CronJob

```bash
kubectl apply -f 16-job.yaml
```

```bash
kubectl apply -f 17-cronjob.yaml
```

Notice that the cronjob runs in worker node.


## Taints and Tolerations

Objective: run the cronjob in master node.

Start by tainting the master node for backup. We do not want all workloads to run on master only the ones that tolerate this taint.
```bash
kubectl taint nodes <master-node-name> node-role.kubernetes.io/masterbackup=true:NoSchedule
```

Apply the modified cronjob.yaml with tolerations.
```bash
kubectl apply -f 18-taints-tolerations.yaml
```

Notice that the cronjob pod is still getting created in worker node.
Apply NodeSelect to specify the node.
```bash
kubectl apply -f 19-nodeselector.yaml
```

The pods are now in _pending_ status. This is because there is a NoSchedule taint in Master. Add a toleration for it as well.
```bash
kubectl apply -f 20-taints-tolerations-master.yaml
```

## Readiness, Liveliness, and Startup probes

```bash
kubectl apply -f 21-readiness-liveness-startup.yaml
```


## Resource Requests and Limits

Apply the YAML
```bash
kubectl apply -f 22-resource-requests-limits.yaml
```

Run the following pod to generate load
```bash
kubectl run stress-curl \
  --image=curlimages/curl \
  --restart=Never \
  --command -- /bin/sh -c \
  "while true; do curl http://<NODE_IP>:30001; done"
```


