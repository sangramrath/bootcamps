
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
kubectl apply -f pod.yaml
```

## Deployments

To create a deployment _Deployment_ using the provided YAML file run:
```bash
kubectl apply -f deployment.yaml
```

To scale a _Deployment_ through the YAML, edit the YAML file and replace `replicas` value with the desired number.
Then use `kubectl apply` command to apply the changes to the deployment.
```bash
kubectl apply -f deployment.yaml
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

##
