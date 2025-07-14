# Important `kubeadm` Commands 

---

## Cluster Initialization

### `kubeadm init`
Initializes the control plane node.
```bash
kubeadm init --pod-network-cidr=192.168.0.0/16
```
- Use `--pod-network-cidr` for CNIs like Calico or to specify a custom _POD_ network. 
- Use `--help` to view other flags

### `kubeadm config print init-defaults`
Displays default init configuration as a YAML.
```bash
kubeadm config print init-defaults
```

### `kubeadm config images list`
Lists images required by kubeadm.
```bash
kubeadm config images list
```

### `kubeadm config images pull`
Pre-pulls the required images.
```bash
kubeadm config images pull
```

---

## Adding Nodes

### `kubeadm join`
Typically used by worker nodes to join the cluster.
```bash
kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

### `kubeadm token create`
Generates a new join token.
```bash
kubeadm token create --print-join-command
```

### `kubeadm token list`
Lists all active join tokens.
```bash
kubeadm token list
```

---

## Cluster Reset and Rebuild

### `kubeadm reset`
Removes all Kubernetes cluster components from the node.
```bash
kubeadm reset
```

---

## Upgrades

### `kubeadm upgrade plan`
Checks for available Kubernetes upgrades.
```bash
kubeadm upgrade plan
```

### `kubeadm upgrade apply`
Upgrades the control plane components to a new version.
```bash
kubeadm upgrade apply v1.30.1
```

---

## Certificates

### `kubeadm certs check-expiration`
Renews all control-plane certificates.
```bash
kubeadm certs check-expiration
```

### `kubeadm certs renew all`
Renews all control-plane certificates.
```bash
kubeadm certs renew all
```

---

## General

### `kubeadm version`
Displays installed kubeadm version.
```bash
kubeadm version
```

---

**Note**: Always match `kubeadm`, `kubelet`, and `kubectl` versions to your Kubernetes control plane version.


