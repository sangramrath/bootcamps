# NGINX Ingress Controller with Cert-Manager in AKS

This guide provides a step-by-step process to deploy the NGINX Ingress Controller and Cert-Manager into an existing Azure Kubernetes Service (AKS) cluster.

**Prerequisites:**

  * An existing AKS cluster.
  * `kubectl`.
  * Azure CLI (`az`).

-----

## Connect to the AKS Cluster

Set subscription (in case of multiple), get Kubernetes (AKS) credentials and verify connectivity.

```bash
az account set --subscription "Your Azure Subscription Name or ID"

az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
```

```bash
kubectl cluster-info

kubectl get nodes
```

-----

## Deploy NGINX Ingress Controller

This process uses a manifest file instead of _Helm_ as it has not been covered.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.0/deploy/static/provider/cloud/deploy.yaml
```

This manifest will create all required resources such as:

  * A `Namespace` named `ingress-nginx` (if not already created)
  * `ServiceAccount`
  * `ClusterRole`, `ClusterRoleBinding`
  * `Role`, `RoleBinding`
  * `ConfigMap`
  * `Deployment` for the controller
  * A `Service` of type `LoadBalancer` to expose the controller publicly on AKS.

### Verify Ingress Controller Deployment

Check the controller deployment status, its service and retrieve the External IP allocated to the ingress controller. The service type created is _LoadBalancer_ type. 

```bash
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

kubectl get svc -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

Wait until the `EXTERNAL-IP` field for the `ingress-nginx-controller` service shows an IP address. This might take a few minutes as Azure provisions the Load Balancer. Once you see it, make a note of it.

Next, you should point a domain or subdomain of your choice to this IP address. 
For example, `bootcamps.od10.in` was pointed to this IP in the demonstration. 

**IMPORTANT**
Run the following command for the demo to work:
```bash
kubectl delete validatingwebhookconfiguration ingress-nginx-admission
```

-----

### Deploy a Sample Application with a _Deployment_ and a _Service_

The service type will be _ClusterIP_ since we will use ingress for this deployment.

```bash
kubectl apply -f aks/01-deployment.yaml

kubectl apply -f aks/02-service-ClusterIP-deployment.yaml
```

Verify the deployment and services

```bash
kubectl get pods

kubectl get svc
```
-----

### Configure ingress for this deployment

**IMPORTANT**

Open the `aks/03-ingress.yaml` file and as discussed update the domain to an actual domain. And ensure the `backend.service.name` matches the one used in the _Service_ created earlier.

  * **Replace `somedomain.com`** with your actual domain/sub-domain name.
  * Ensure `kcnaprep-d-mk` and its port (80) are correct based on the `aks/02-service-ClusterIP-deployment.yaml` file.

Apply the ingress manifest:
```bash
kubectl apply -f aks/03-ingress.yaml
```

Verify the ingress was created:
```bash
kubectl get ingress
```

Wait until you see the ingress controller service IP (Load Balancer IP) in the `ADDRESS` column.

-----

### Verify application accessibility

Use the browser to point to the domain configured and verify that the application loads. In this case its the NGINX welcome screen.

-----

## Setup TLS/SSL using Cert-Manager 

Cert-Manager automates the issuance and renewal of TLS certificates. 

### Install cert-manager using manifests

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml
```

```bash
kubectl create namespace cert-manager
```

Verify Cert-Manager Deployment

```bash
kubectl get pods -n cert-manager
```

Wait until all Cert-Manager pods (`cert-manager`, `cert-manager-cainjector`, `cert-manager-webhook`) are in a `Running` and `Ready` state (e.g., `1/1 Running`). This might take a couple of minutes for the webhook to become healthy.

-----

### Create a Lets Encrypt ClusterIssuer

A `ClusterIssuer` tells Cert-Manager how to obtain certificates from an external CA (like Let's Encrypt). A `ClusterIssuer` can be used by Ingress resources in any namespace.

Apply the manifest

```bash
kubectl apply -f aks/04-cluster-issuer.yaml
```

Verify ClusterIssuer Status

```bash
kubectl get clusterissuer 
kubectl describe clusterissuer letsencrypt-prod
```

Look for `Status.Conditions` and ensure it's `True` and `Ready`.

-----

### Update the ingress to include TLS

Use `05-ingress-tls.yaml`. Review the changes.

Apply the ingress manifest:
```bash
kubectl apply -f aks/05-ingress-tls.yaml
```

Verify the ingress was updated. You should see port `443` added.
```bash
kubectl get ingress
```

### Check Certificate and CertificateRequest Status (Optional)

```bash
kubectl get certificate

kubectl describe certificate kcnaprep-d-mk 
```

Look for the `Ready` status to be `True`. This means the certificate has been successfully issued and stored in the `kcnaprep-d-mk` Kubernetes Secret.

You can also check the `CertificateRequest` and `Order` resources for more detailed status and events if troubleshooting:

```bash
kubectl get certificaterequest

kubectl get orders

kubectl get challenges
```

### Verify application accessibility using TLS

Use the browser to point to the domain configured and verify that the application loads with **HTTPS**.

-----