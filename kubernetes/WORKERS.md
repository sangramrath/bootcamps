# Kubernetes with containerd 

The following steps are to be performed on all **WORKER HOSTS** that are or will be a part of the cluster.

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
1. Initializing worker node(s)

---

## Step 5: Initialize one or more worker nodes

NOTE: Use the kubeadm join command printed on your terminal. The below is just an example.
```bash
kubeadm join 192.168.0.18:6443 --token 3116rg.xxxxxxxxxx
```
