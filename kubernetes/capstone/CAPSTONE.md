## Task 1: Gain access and fix the cluster
Running `kubectl` commands results in an error. And developers complain that pods are not coming up.
- Retrieve the `kubeconfig` and ensure it works without providing the file as an environment variable always.
- Ensure the `kubeconfig` file is also present in the original locations.
- Label nodes with the same name as the Kubernetes node name.
- Ensure pods can be scheduled in the worker node. Run a test pod to verify this and keep a screenshot as proof.

## Task 2: Deploy an application
You are asked to deploy an application to the cluster with the following objectives:
- The application is `stefanprodan/podinfo` and runs on port `9898`.
- The deployment approach should support easy rollouts of new versions.
- The application can be manually scaled when necessary.
- The application requires a minimum of 32 MB of memory and 100m of cpu. Do not let it consume more than 2x.
- The application should be accessible from outside the cluster. Use available means. 

## Task 3: Update a Cronjob
There is a _CronJob_ already running in the cluster. 
- Change the schedule to run every day at 1 AM
- Update the image to use `alpine:3.18`
- The name is confusing and does not clarify what's being backedup. Change it to `masternodebackup`. 

## Task 4: Secure the database deployment
A MySQL database is already deployed on this server. It is exposing the root password in the file. 
- Update the deployment to use an appropriate solution that does not reveal the password in plaintext.
- Ensure that the password cannot be seen/found out from previous versions of the deployment. 

## Task 5: Create shared storage
The developers require certain files to be presented to applications for testing purposes. It has been decided to create a single volume that all of them can use simultaneously. Your objectives:
- Create a PV and PVC that they can use.
- Name the PVC `shared-volume`
- Storage size is `10Gi`
- Use a folder in the host called `/shared`