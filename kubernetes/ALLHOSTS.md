# ALL HOSTS

## Enabled bridged traffic 
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

## sysctl params required by setup, params persist across reboots
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

## Apply sysctl params without reboot
```bash
sudo sysctl --system
```

## Disable swap on all nodes
```bash
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
```

## Disable firewall (not recommened in production)
```bash
sudo ufw disable
```

## Required dependencies
```bash
sudo apt install curl gnupg2 software-properties-common apt-transport-https ca-certificates -y
```

## Install containerd from Docker
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

```bash
sudo apt update && sudo apt install containerd.io -y
```

## Configure containerd to use systemd as cgroup driver
```bash
sudo vi /etc/containerd/config.toml
```

Find the `[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]` section and change `systemdcgroup` to `true`.

```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
```

```bash
sudo containerd config dump
```

## Install kubelet, kubectl, and kubeadm

Set the Kubernetes version to install
```bash
KUBERNETES_VERSION="v1.32"
```

Add Kubernetes repository
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```bash
sudo apt-get update -y
```

Install kubelet, kubectl, and kubeadm.
```bash
sudo apt-get install kubelet kubectl kubeadm -y
```

Prevent accidental automatic updates
```bash
sudo apt-mark hold kubelet kubeadm kubectl
```
