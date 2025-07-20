# Kubernetes with containerd 

The following steps are to be performed on all **CONTROL PLANE HOSTS** that are or will be a part of the cluster.

## Prerequisites

You must ensure the following before getting started:
- Ubuntu 20.04+ or Debian 11+ (this guide has been tested on these distributions only)
- At least 2 GB RAM and 2 CPUs per node
- Network connectivity between all nodes
- Unique hostname, MAC address, and product_uuid for each node (recommended)
- Root or sudo privileges
- Swap disabled on all nodes

## Overview

This steps in this guide do the following:
1. Initializing the cluster
2. Setting up networking

---

## Step 4: Initialize the Kubernetes Cluster

### 4.1 Initialize the cluster

Run the `kubeadm init` command to do so.

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock
```

- `--pod-network-cidr` Defines the IP range for pods. We use 192.168.0.0/16 which is the default for Calico CNI
- `--cri-socket` Specifies the container runtime interface socket for containerd

**Important:** Save the `kubeadm join` command output - you'll need it to join worker nodes.

### 4.2 Configure kubectl 

This copies the admin configuration to your user directory, allowing you to run kubectl commands without sudo.

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 4.3 Verify Cluster Status

These commands verify that the cluster is initialized and system pods are running. The node will show as "NotReady" until we install a CNI plugin.

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

---

## Step 5: Install Container Network Interface (CNI)

### 5.1 Install Calico CNI

Kubernetes does not come with a default CNI. This installs the CALICO CNI.

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/calico.yaml
```

### 5.3 Verify Calico Installation

```bash
kubectl get pods -n kube-system
kubectl get nodes
```

After Calico installation, all nodes should show as "Ready" and calico pods should be running in the calico-system namespace.

---
