# Amazon EKS multi cluster management using kro & ACK and continuous promotion to multiple environments using Argo CD, Kargo and Argo Rollouts

## Overview of a solution

This solution demonstrates:
- How to manage a fleet of [Amazon Elastic Kubernetes Service (Amazon EKS)](https://aws.amazon.com/eks/) clusters using [kro](https://kro.run/), [ACK](https://aws-controllers-k8s.github.io/community/), and [Argo CD]() across multiple regions and accounts by creating Amazon EKS clusters, and bootstraps them with the required add-ons.
- How to create continuous application promotion process to multiple environments (test, pre-prod, prod-eu, prod-us) using Argo CD, [Kargo](https://kargo.io/) and [Argo Rollouts](https://argoproj.github.io/rollouts/).

A hub-spoke model is used in this example; a management cluster (hub) is created as part of the initial setup and the controllers needed for provisioning and
bootstrapping workload clusters (spokes) are installed on top.

![EKS cluster management using kro & ACK](docs/eks-cluster-mgmt-central.drawio.png)

## Prerequisites

1. AWS account for the management cluster, and optional AWS accounts for spoke clusters (you can reuse management account for spoke too).

2. Deploy VSCode IDE: open cloud shell (or other terminal configured with your account) and execute the following to create the working IDE

```sh
curl https://raw.githubusercontent.com/aws-samples/java-on-aws/main/infrastructure/cfn/ide-stack.yaml > ide-stack.yaml
CFN_S3=cfn-$(uuidgen | tr -d - | tr '[:upper:]' '[:lower:]')
aws s3 mb s3://$CFN_S3
aws cloudformation deploy --stack-name ide-stack \
    --template-file ./ide-stack.yaml \
    --s3-bucket $CFN_S3 \
    --capabilities CAPABILITY_NAMED_IAM
aws cloudformation describe-stacks --stack-name ide-stack --query "Stacks[0].Outputs[?OutputKey=='IdeUrl'].OutputValue" --output text
aws cloudformation describe-stacks --stack-name ide-stack --query "Stacks[0].Outputs[?OutputKey=='IdePassword'].OutputValue" --output text
```

3. Login to VSCode IDE using `IdeUrl` and `IdePassword` from the outputs above.

## Walkthrough Creating the environments

1. Switch to `zsh`

```sh
zsh
```

### Configuring workspace

1. Set variables

```sh
cat << EOF > ~/environment/.envrc
export PATTERN_REPO_URL="https://github.com/aws-samples/fleet-management-on-amazon-eks-workshop.git"
# export PATTERN_REPO_BRANCH="riv24"
export WORKSPACE_PATH="$HOME/environment" # the directory where repos will be cloned e.g. ~/environment
export PATTERN_REPO_NAME="pattern_repo"
export PATTERN_FULL_PATH="$HOME/environment/pattern_repo/patterns/kro-eks-cluster-mgmt"
export WORKING_REPO="eks-cluster-mgmt" # Contains terraform and gitops configurations
export TF_VAR_FILE="terraform.tfvars" # the name of terraform configuration file to use
export MGMT_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account) # Or update to the AWS account to use for your management cluster
export GIT_USERNAME=user1
EOF
#load env
direnv allow
```

2. Clone `pattern` repository:

```sh
git clone $PATTERN_REPO_URL $WORKSPACE_PATH/$PATTERN_REPO_NAME
# git -C $WORKSPACE_PATH/$PATTERN_REPO_NAME checkout $PATTERN_REPO_BRANCH
```

### Creating the Management cluster

```sh
$PATTERN_FULL_PATH/scripts/0-initial-setup.sh
```

Review the terraform changes and accept to deploy.

> Wait until the deployment is successful. It should take around 15-20 minutes.

### ArgoCD and GitLab configuration

We are using GitLab in our cluster, as source for our GitOps workflow, and are using Argo CD as GitOps tool.

```sh
$PATTERN_FULL_PATH/scripts/1-argocd-gitlab-setup.sh
direnv allow
```

This script configures ArgoCD and GitLab for the EKS cluster management environment. It:
1. Updates the kubeconfig to connect to the hub cluster
2. Retrieves and displays the ArgoCD URL and credentials
3. Sets up GitLab repository and SSH keys
4. Configures Git remote for the working repository
5. Creates a secret in ArgoCD for Git repository access
6. Logs in to ArgoCD CLI and lists applications

> Wait until Argo CD Load Balancer will be provisioned and UI will be available. It should take about 3-5 minutes.
> Wait until all Argo CD applications will be deployed successfully.

Check all Argo CD applications are Synced

```sh
kubectl get applications -n argocd
```

```sh
NAME                            SYNC STATUS   HEALTH STATUS
ack-ec2-hub-cluster             Synced        Healthy
ack-eks-hub-cluster             Synced        Healthy
...
multi-acct-hub-cluster          Synced        Healthy
```

### Bootstrapping Management/Spoke accounts

In order for the management cluster to execute actions in the spoke AWS accounts, we need to create IAM roles in the spoke accounts:

- `eks-cluster-mgmt-ec2`
- `eks-cluster-mgmt-eks`
- `eks-cluster-mgmt-iam`

```sh
$PATTERN_FULL_PATH/scripts/2-bootstrap-accounts.sh
```

This script bootstraps the management and spoke AWS accounts for EKS
cluster management. It:
1. Creates ACK workload roles with the current user added
2. Monitors ResourceGraphDefinitions until they are all in Active state
3. Restarts the KRO deployment if needed to activate resources


> Optional. If you want to use additional AWS accounts to host EKS spoke clusters, Repeat the following step for each of your Spoke accounts you want to use with the solution.
If you want to add spoke accounts, you need to connect to your AWS spoke account. For example, by switching the profile.
   ```sh
   # export AWS_PROFILE=spoke_account1 # use your own profile or be sure to be connected to the appropriate account
   #cd $WORKSPACE_PATH/$WORKING_REPO/scripts
   #./create_ack_workload_roles.sh
   ```

After the script execution, the Resource Graph Definitions (RGD) should properly reconciled and active

```sh
kubectl get resourcegraphdefinitions.kro.run
```

Output expected:

```sh
NAME                        APIVERSION   KIND                STATE    AGE
ekscluster.kro.run          v1alpha1     EksCluster          Active   13m
eksclusterwithvpc.kro.run   v1alpha1     EksclusterWithVpc   Active   12m
vpc.kro.run                 v1alpha1     Vpc                 Active   13m
```

### Creating Spoke clusters with kro and ACK

ACK controllers can work cross AWS accounts, but that need to isolate resources into specific namespaces. We are doing this with this solution, where each ACK resources will be isolated into specific namespaces.

If you want to do deploy your EKS clusters in multiple AWS accounts, you need to update this configuration.
If you just want to only use one account, you still need to specify the AWS account to use for each namespaces.

We use management account ID to deploy `test`, `pre-prod`, `prod-eu` and `prod-us` clusters:

This is automated by this script: 

```sh
$PATTERN_FULL_PATH/scripts/3-create-spoke-clusters.sh
```

This script creates the spoke EKS clusters in different regions. It:
1. Configures spoke cluster accounts in ArgoCD for ACK controller
2. Updates cluster definitions with management account ID and Git URLs
3. Enables and configures the fleet spoke clusters
4. Syncs the clusters application in ArgoCD
5. Creates the EKS clusters using KRO

> You can check the files : `$WORKSPACE_PATH/$WORKING_REPO/addons/tenants/tenant1/default/addons/multi-acct/values.yaml` and `$WORKSPACE_PATH/$WORKING_REPO/fleet/kro-values/tenants/tenant1/kro-clusters/values.yaml` if you want to make some changes to the created spoke workloads.

> After some times (15-20mn), the clusters should have been created in the spoke/management account(s):

```sh
kubectl get EksClusterwithvpcs -A
```

```sh
NAMESPACE   NAME                STATE    SYNCED   AGE
argocd      cluster-pre-prod   IN_PROGRESS   False    110s
argocd      cluster-prod-eu    IN_PROGRESS   False    110s
argocd      cluster-prod-us    IN_PROGRESS   False    110s
argocd      cluster-test       IN_PROGRESS   False    110s
```

```sh
NAMESPACE   NAME                STATE    SYNCED   AGE
argocd      cluster-pre-prod   ACTIVE   True     31m
argocd      cluster-test       ACTIVE   True     51m
```

> If You see STATE=ERROR, that's may be normal as it will take some times for all dependencies to be OK, but you may want to see the logs of kro and ACK controllers in case you may have some configuration errors.

You can also list resources created by kro to validate their status:

```sh
kubectl get vpcs.kro.run -A
kubectl get vpcs.ec2.services.k8s.aws -A -o yaml # check there is not error
kubectl get vpcs -A
```

> If you see errors, you may need to double check the multi-cluster accounts settings, and if IAM roles in both management and spoke AWS accounts are properly configured.

When VPC are ok, then check for EKS resources:

```sh
kubectl get eksclusters.kro.run -A
kubectl get clusters.eks.services.k8s.aws -A -o yaml # Check there are no errors
kubectl get eksclusters -A
kubectl get eksclusterwithvpc -A
```

Check that all ArgoCD Applications have been deployed to spoke clusters:

```sh
kubectl get applications -n argocd
```

```sh
NAME                                 SYNC STATUS   HEALTH STATUS
ack-ec2-hub-cluster                  Synced        Healthy
ack-eks-hub-cluster                  Synced        Healthy
ack-iam-hub-cluster                  Synced        Healthy
argo-rollouts-cluster-pre-prod       Synced        Healthy
argo-rollouts-cluster-prod-eu        Synced        Healthy
argo-rollouts-cluster-prod-us        Synced        Healthy
argo-rollouts-cluster-test           Synced        Healthy
...
metrics-server-cluster-pre-prod      Synced        Healthy
metrics-server-cluster-prod-eu       Synced        Healthy
metrics-server-cluster-prod-us       Synced        Healthy
metrics-server-cluster-test          Synced        Healthy
metrics-server-hub-cluster           Synced        Healthy
multi-acct-hub-cluster               Synced        Healthy
```

### Deploy Argo Rollouts Demo Application

```sh
$PATTERN_FULL_PATH/scripts/4-deploy-argo-rollouts-demo.sh
```

This script deploys the Argo Rollouts demo application to the EKS clusters. It performs the following steps:
1. Creates an Amazon ECR repository for container images
2. Clones the application source repository and builds an initial image
3. Creates a Git repository for the application deployment configuration
4. Updates configuration files with account-specific information
5. Configures ArgoCD and Kargo for the application deployment
6. Sets up access for Kargo to the Git repository

```sh
$PATTERN_FULL_PATH/scripts/6-tools-urls.sh
```

### Configure EKS Cluster Access to all spoke clusters

```sh
$PATTERN_FULL_PATH/scripts/5-cluster-access.sh
```

This script configures access to the EKS clusters created in the previous steps. It:
1. Creates access entries for the ide-user role in each EKS cluster
2. Associates the AmazonEKSClusterAdminPolicy with the ide-user role
3. Updates the kubeconfig file to enable kubectl access

After that, you can use kubectl to connect to any of the EKS clusters.

> use kubectx or k9s to check all clusters

This script also create an html file that will be use as a dashboard for our demo application progressive rollout, the dashboard is available at:

```bash
code $WORKSPACE_PATH/dashboard.html
```

> Download the dashboard, and open it in your browser

## Walkthrough Promoting Application

Kargo is configured to watch for our rollouts-demo-kargo application, and to promote it from tests to production environment.

In order to see this in action, we can create a new version of the application:

### Creating a container image for demo application.

4. Build a new container images and observe deployment, continuous promotion from `test` to `prep-prod` and rollouts:

```sh
$PATTERN_FULL_PATH/scripts/build-rollouts-demo.sh orange
```

### Promote the application to pre-prod

1. Login to Gitlab as `user1` and merge Pull request in `rollouts-demo-deploy` project for promotion to `pre-prod`.

### Promote the application to prod clusters

1. Login to Kargo UI and `Promote` active Freight to `prod-eu` and `prod-us`.

2. Wait until `rollouts-demo-prod-eu` and `rollouts-demo-prod-us` are fully operational and test Urls.

3. Build a new container image and test complete continuous promotion process:

```sh
$PATTERN_FULL_PATH/scripts/build-rollouts-demo.sh green
```

![Kargo continuous promotion](docs/kargo-promotion.png)

When you play with creating other color builds and promoting them to different environments, you can execute following script, to have a dachboard, with all 4 clusters application deployment:

```bash
$PATTERN_FULL_PATH/scripts/multi-cluster-dashboard-generator.sh
```

> Note: If you use more than one accounts for spoke, the script won't work as is as it don't know the aws account mapping for clusters. You'll need to manually connect to each accounts and update the kube config file like
> aws eks update-kubeconfig --name "cluster-test" --region "eu-central-1" --alias "cluster-test" --profile <YOUR APPROPRIATE PROFILE>
> aws eks update-kubeconfig --name "cluster-pre-prod" --region "us-west-2" --alias "cluster-pre-prod" --profile <YOUR APPROPRIATE PROFILE>
> aws eks update-kubeconfig --name "cluster-prod-us" --region "us-west-2" --alias "cluster-prod-us" --profile <YOUR APPROPRIATE PROFILE>
> aws eks update-kubeconfig --name "cluster-prod-eu" --region "eu-west-1" --alias "cluster-prod-eu" --profile <YOUR APPROPRIATE PROFILE>
>
> In this case you can use the script with manual flag meaning you have manually configure kubectl to work with all 4 clusters
> ```bash
>$PATTERN_FULL_PATH/scripts/multi-cluster-dashboard-generator.sh --manual
>```

then download the generated Dashboard html, and open it in your browser

![Promotion dashboard](docs/argo-rollout-promotion-dashboard.png)

## Other tools

We have deployed other tools in our environment, you can get the list of them by running the following script

```sh
$PATTERN_FULL_PATH/scripts/6-tools-urls.sh
```

- *Keycloack* is used for authentication.
- *Gitlab* is the source of code for our application and deployment manifests
- *Argo CD* is used to managed application deployments into different environments.
- *Kargo* is used on top of ArgoCD for managing application promotion between environments
- *Backstage* is used to manage templates and allow developers to easilly add new applications into the environments.
- *Argo Workflow*, can be used to automate some CI pipelines

You can access all of thoses services.

## Conclusion

The solution provides a capability to create EKS clusters with kro RGD, deployed to AWS using ACK controllers, and then automatically registered to Argo CD. Argo CD installs addons and workloads automatically. Kargo integrates with Argo CD and Argo Rollouts and enables continuous promotion of workloads to various environment using Stages and Promotion Tasks.

## Cleanup

As our spoke workloads have been bootstrapped by Argo CD and kro/ACK, we need to clean them in specific order.

### Clean up workloads.

1. Disable `workloads` Argo CD application:

```sh
mv $WORKSPACE_PATH/$WORKING_REPO/fleet/bootstrap/workloads.yaml $WORKSPACE_PATH/$WORKING_REPO/fleet/bootstrap/excluded/
```

2. Add, Commit and Push:

```sh
cd $WORKSPACE_PATH/$WORKING_REPO/
git status
git add .
git commit -m "Disable Cluster-workloads Argo CD application"
git push
```

3. Login to Argo CD UI and Sync `bootstrap` Argo CD application with `Prune` option checked. Wait until `cluster-workloads` will be deleted.

4. Delete the demo application project namespace:

```sh
kubectl delete ns rollouts-demo-kargo
```

### Clean up spoke clusters

1. Disable workload clusters in the configuration:

```sh
code $WORKSPACE_PATH/$WORKING_REPO/fleet/kro-values/tenants/tenant1/kro-clusters/values.yaml
```

2. Add, Commit and Push

```sh
cd $WORKSPACE_PATH/$WORKING_REPO/
git status
git add .
git commit -m "Comment out workload clusters"
git push
```

3. Login to Argo CD UI and Sync `clusters` Argo CD application with `Prune` option checked.

4. Wait until all `clusters` and `VPCs` will be deleted:

```sh
kubectl get eksclusterwithvpc -A
kubectl get vpcs -A
```

```sh
NAMESPACE   NAME               STATE      SYNCED   AGE
argocd      cluster-pre-prod   DELETING   False    4h34m
argocd      cluster-prod-eu    DELETING   False    114m
argocd      cluster-prod-us    DELETING   False    114m
argocd      cluster-test       DELETING   False    4h54m
```

5. Once you have successfully de-registered all spoke EKS clusters, you can remove the Hub cluster created with Terraform and created roles:

```sh
cd $WORKSPACE_PATH/$WORKING_REPO/terraform/hub
./destroy.sh
```

You may need to delete remaining Load Balancers, Hub cluster and hub VPC manually if Terraform will not be able to clean it up.

```sh
cd $WORKSPACE_PATH/$WORKING_REPO/scripts/
./delete_ack_workload_roles.sh eks-cluster-mgmt-iam eks-cluster-mgmt-ec2 eks-cluster-mgmt-eks
```

6. Delete ECR repository:

```sh
aws ecr delete-repository --repository-name rollouts-demo --force
```

7. Delete `ide-stack` in AWS CloudFormation.

8. Clean up all the remained resources manually.

Open questions:

- Autogenerated names for addons in the cluster can follow another pattern:
instead of ack-efs-cluster-test -> cluster-test-ack-efs = $cluster_name-$addon_name/workload_name
It will group addons from the same cluster together in Argo CD UI.

- KRO resources are not active after deployment of the Hub cluster with addons and require restart twice. Why?

```sh
kubectl get resourcegraphdefinitions.kro.run
kubectl rollout restart deployment -n kro-system kro
kubectl get resourcegraphdefinitions.kro.run
kubectl rollout restart deployment -n kro-system kro
kubectl get resourcegraphdefinitions.kro.run
```
