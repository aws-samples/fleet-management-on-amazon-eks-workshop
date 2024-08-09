For each fleet member EKS cluster we are going to deploy 1 helm chart "Fleet Bootstrap" to the fleet member

Step 0
Create codecommit git
Create AWS Secret Manager Key with git ssh keys that rotate every 90 days
Create hub cluster
Bootstrap hub cluster with gitops-bridge addons helm chart

Step 1
For each fleet member an EKS cluster is created using IaC like TF, ACK, or CAPI
The IaC is going to create an AWS Secret Manager Key contains the cluster information.

Step 2
Add a new file (fleet_member_name.yaml) under the directory "fleet", this file contains the name of the AWS Secret key with cluster info.
This file will trigger the argocd generator to create a new argocd app that will deploy Helm Chart "Fleet Registration"
The helm chart "Fleet Registration" will deploy a external secret
In the Hub cluster using external secret, it pulls the AWS Secret Manager Key created in Step 1, and registers the cluster as an argocd cluster fleet member

Step 3
When the new argocd secret for the fleet cluster is created an application set using cluster generator will deploy to the fleet cluster the helm chart "Fleet Bootstrap"

Content of "Fleet Bootstrap" Helm Chart:
- argocd app that deploys argocd helm chart
- argocd app that deploys external-secret helm chart
- resources:
  - externasecret to pull from AWS Secret Manager to create a argocd local secret that contains the metedata from IaC (ie annotations, account id, region,etc)
  - externalsecret to pull from AWS Secret Manager git ssh keys, and creates a argocd git-credentials to connect to git
  - bootstrap addons appset that deploys argocd app that deploys the gitops-bridge-addon chart and the values pass to this chart are going the addons enabled from the fleet argocd secret that indicates the addons that were enable in IaC when the cluster was created
     - we are going to force the deployment of kyverno addon, and the policies.
  - specific kyverno policy that deals with fleet bootstraping or management. Only allow addons to be deleted by the service account of argocd. something for the kube-fleet namespace to generate resources