# Kubernetes Upgrade using Kubeadm (Ubuntu/Debian)

This guide outlines the step-by-step process for upgrading your Kubernetes cluster using `kubeadm` on Ubuntu/Debian. 
Refer to the official docs for changes/updates: 
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

## Select a version to upgrade to

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```bash
sudo apt update

sudo apt-cache madison kubeadm
```

## Upgrade Control Plane Node(s)

Upgraed **one control plane node at a time**.

### Drain the Control Plane Node (Optional but Recommended)

This ensures no new Pods are scheduled and existing Pods are evicted gracefully.

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Upgrade `kubeadm`

Update the `kubeadm` package to the desired version.

```bash
sudo apt-mark unhold kubeadm

sudo apt-get update

sudo apt-get install -y kubeadm=<desired-version>

sudo apt-mark hold kubeadm
```

Verify `kubeadm` was upgraded:
```bash
kubeadm version
```

### Plan the Upgrade

This command checks if your cluster can be upgraded and shows the necessary changes.

```bash
sudo kubeadm upgrade plan
```

### Apply the Upgrade

Execute the upgrade command.

```bash
sudo kubeadm upgrade apply <desired-version>
```

### Upgrade `kubelet` and `kubectl`

```bash
sudo apt-mark unhold kubelet kubectl

sudo apt-get update

sudo apt-get install -y kubelet=<desired-version> kubectl=<desired-version>

sudo apt-mark hold kubelet kubectl

```

Restart kubelet
```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### Uncordon the Control Plane Node

Once the control plane node is upgraded and `kubelet` is restarted, make it schedulable again using the following command:

```bash
kubectl uncordon <node-name>
```

## Upgrade Worker Nodes

Perform these steps on **each worker node**. You can upgrade worker nodes in parallel too.

### Drain the Worker Node

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Upgrade `kubeadm`

Update the `kubeadm` package on the worker node.

```bash
sudo apt-mark unhold kubeadm

sudo apt-get update

sudo apt-get install -y kubeadm=<desired-version>

sudo apt-mark hold kubeadm
```

Verify kubeadm was upgraded:
```bash
kubeadm version
```

### Upgrade node

```bash
sudo kubeadm upgrade node
```

### Upgrade `kubelet` and `kubectl`

```bash
sudo apt-mark unhold kubelet kubectl

sudo apt-get update

sudo apt-get install -y kubelet=<desired-version> kubectl=<desired-version>

sudo apt-mark hold kubelet kubectl
```

Restart kubelet
```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### Uncordon the Worker Node

Once the worker node is upgraded and `kubelet` is restarted, make it schedulable again.

```bash
kubectl uncordon <node-name>
```

### Post upgrade checks on Master/Control Plane

Ensure all nodes are `Ready` and running the new Kubernetes version.

```bash
kubectl get nodes -o wide
```

### Check Pods

Ensure all system Pods (in `kube-system` namespace) are `Running`.

```bash
kubectl get pods -A
```

### Check Cluster Version

```bash
kubectl version --short
```