# Kubernetes with containerd 

The following steps are to be performed on all **ALL HOSTS (CONTROL PLANE & WORKER)** that are or will be a part of the cluster.

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
1. System preparation
2. Installing _containerd_ container runtime
3. Installing Kubernetes components _kubelet_, _kubeadm_, and _kubectl_

---

## Step 1: System Preparation

### 1.1 Update system packages

```bash
sudo apt update
```

### 1.2 Disable swap on all nodes

Kubernetes requires swap to be disabled because it may interfere with pod scheduling and resource management. The kubelet also fails to start if swap is enabled.
Check and if required disable swap using the following commands:

```bash
# Check current swap status
sudo swapon --show

# Disable swap temporarily
sudo swapoff -a

# Disable swap permanently by commenting out swap entries
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

### 1.3 Configure kernel module 

Configure the Linux kernel to enable networking capabilities like bridge networking
- `overlay` module is required 
- `br_netfilter` module enables bridge networking and is essential for Kubernetes networking
  
```bash
cat <<EOF | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF
```

Add/load the modules with the following command:
```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

Optionally, verify using `lsmod` command:
```bash
lsmod | grep overlay
lsmod | grep br_netfilter
```

### 1.4 Configure Kernel Parameters

These kernel parameters are essential for Kubernetes networking:
- `bridge-nf-call-iptables` Enables iptables to see bridged traffic
- `bridge-nf-call-ip6tables` Enables ip6tables to see bridged traffic
- `ip_forward` Enables IP forwarding, required for pod-to-pod communication

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

Apply sysctl params without reboot
```bash
sudo sysctl --system
```

## Step 2: Install containerd

### 2.1 Install required dependencies
These packages are needed for secure package downloads and repository management.

```bash
sudo apt install curl gnupg2 software-properties-common apt-transport-https ca-certificates -y
```

### 2.2 Add Docker's Official GPG Key

We add Docker's GPG key because containerd is distributed through Docker's repository. This ensures package authenticity.

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### 2.3 Add Docker Repository

This adds the Docker repository to your system's package sources, allowing you to install containerd.

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 2.4 Install containerd
```bash
sudo apt update
sudo apt install -y containerd.io
```

### 2.5 Configure containerd

The systemd cgroup driver is recommended for Kubernetes because it provides better resource management and is more stable than the cgroupfs driver.

```bash
# Generate default configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Configure systemd cgroup driver
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```

### 2.6 Restart and Enable containerd

This ensures containerd starts automatically on boot and verifies it's running properly.

```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd
```

```bash
sudo containerd config dump
```

## Step 3: Install Kubernetes Components

### 3.1 Add Kubernetes Repository

This adds the official Kubernetes repository. We're using v1.32 as it's a stable release. You can change this to a newer version if available.

```bash
# Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### 3.2 Install Kubernetes Components

- `kubelet`: The node agent that runs on each node and manages containers
- `kubeadm`: Tool for bootstrapping Kubernetes clusters
- `kubectl`: Command-line tool for interacting with Kubernetes clusters

```bash
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
```

### 3.3 Hold Kubernetes Packages

This prevents automatic updates of Kubernetes components, which should be upgraded manually to ensure cluster stability.

```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

---

