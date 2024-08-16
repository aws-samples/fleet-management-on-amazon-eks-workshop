## Amazon EKS Fleet Management Workshop

Elevate your Amazon EKS skills with this hands-on workshop designed for experienced builders. Learn to create a unified internal developer platform for Amazon EKS clusters across environments using GitOps principles. Master multi-cluster resource configuration, drift detection, and lifecycle management while ensuring compliance and security.
For a detailed information, please use this [guided workshop](https://studio.us-east-1.prod.workshops.aws/workshops/28c283c1-1d60-43fa-a604-4e983e0e8038) to walk you through all the details including architecture decisions been made while building this workshop.

For any feedback, please open a [Bug](https://github.com/aws-samples/fleet-management-on-amazon-eks-workshop/issues/new?assignees=&labels=&projects=&template=bug_report.md&title=) or [Feature](https://github.com/aws-samples/fleet-management-on-amazon-eks-workshop/issues/new?assignees=&labels=&projects=&template=feature_request.md&title=) issue in this repository.

## Use Cases

1. Deploy EKS clusters (hub, staging, prod)
1. Deploy Namespaces
1. Create DynamoDB
1. Deploy Applications
1. Day 2 Operations


# Module 1: Setup

Run the following command create git repository in CodeCommit and create 3 EKS Clusters (Hub, Staging, Prod)
```shell
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION="us-west-2"
export WORKING_DIR="$HOME/environment" #For local dev; export WORKING_DIR="$PWD/environment"
export WORKSHOP_DIR="$WORKING_DIR/fleet-management-on-amazon-eks-workshop" #For local dev; export WORKSHOP_DIR="$PWD"
export GITOPS_DIR="$WORKING_DIR/gitops-repos"
git clone https://github.com/aws-samples/fleet-management-on-amazon-eks-workshop $WORKSHOP_DIR
cd $WORKSHOP_DIR
./install.sh
```

Access ArgoCD UI on the Hub Cluster
```shell
echo "ArgoCD URL: https://$(kubectl --context hub-cluster get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "ArgoCD Username: admin"
echo "ArgoCD Password: $(kubectl --context hub-cluster get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
```

# Module 2: Platform

## Deploy EKS Addons

To deploy EKS Addons we need to use Infrastructure as Code (IaC) and GitOps to work together.
Enable the variables for the corresponding Addons in the IaC tool.
```shell
sed -i '' s/"balancer_controller = false"/"balancer_controller = true"/           $WORKSHOP_DIR/terraform/spokes/variables.tf
sed -i '' s/"dynamodb                 = false"/"dynamodb                 = true"/ $WORKSHOP_DIR/terraform/spokes/variables.tf
```

Apply the IaC to create the IAM Roles for each Addon, and enable the Helm Chart to be deploy by GitOps
```shell
terraform -chdir=$WORKSHOP_DIR/terraform/spokes workspace select -or-create staging
terraform -chdir=$WORKSHOP_DIR/terraform/spokes apply -var-file="workspaces/staging.tfvars" -auto-approve
terraform -chdir=$WORKSHOP_DIR/terraform/spokes workspace select -or-create prod
terraform -chdir=$WORKSHOP_DIR/terraform/spokes apply -var-file="workspaces/prod.tfvars" -auto-approve
```

Verify AWS Load Balancer Controller is installed on each cluster
```shell
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --context staging-cluster
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --context prod-cluster
```
Expected Result
```
NAME                                            READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-6d64b58dfc-89wxc   1/1     Running   0          3m
aws-load-balancer-controller-6d64b58dfc-pzbtl   1/1     Running   0          3m
```

Verify AWS Controller for Kubernetes (ACK) is installed on each cluster
```shell
kubectl get pods -l app.kubernetes.io/instance=ack-dynamodb -A --context staging-cluster
kubectl get pods -l app.kubernetes.io/instance=ack-dynamodb -A --context prod-cluster
```
Expected Result
```
NAME                                               READY   STATUS    RESTARTS   AGE
ack-dynamodb-aws-controllers-k8s-89685f8c5-p9rwt   1/1     Running   0          3m
```

## Deploy Tenants/Teams

For each team (ie. `backend`, `frontend`), the following will be created
- ArgoCD Project
- Namespaces, Network Policies, LimitRanges, ResourceQuotas

```shell
cp -r $WORKSHOP_DIR/gitops/platform/* $GITOPS_DIR/platform/
git -C $GITOPS_DIR/platform add .
git -C $GITOPS_DIR/platform commit -m "add platform"
git -C $GITOPS_DIR/platform push
```


## Verify Namespaces


```shell
kubectl get ns -l app.kubernetes.io/created-by=eks-workshop \
  -o custom-columns='NAME:.metadata.name,TEAM:.metadata.labels.app\.kubernetes\.io/name,ENVIRONMENT:.metadata.labels.environment' \
  --sort-by '.metadata.labels.environment' --context staging-cluster
kubectl get ns -l app.kubernetes.io/created-by=eks-workshop \
  -o custom-columns='NAME:.metadata.name,TEAM:.metadata.labels.app\.kubernetes\.io/name,ENVIRONMENT:.metadata.labels.environment' \
  --sort-by '.metadata.labels.environment' --context prod-cluster
```
There should be new namespaces on each cluster
```shell
NAME       TEAM       ENVIRONMENT
carts      backend    staging
catalog    backend    staging
checkout   backend    staging
orders     backend    staging
rabbitmq   backend    staging
assets     frontend   staging
ui         frontend   staging
```

# Module 3: Workloads in Stage

Deploy the workloads to staging cluster (default)

```shell
cp -r $WORKSHOP_DIR/gitops/apps/* $GITOPS_DIR/apps/
sed -i '' "s/ACCOUNT_ID/$ACCOUNT_ID/" $GITOPS_DIR/apps/backend/carts/staging/kustomization.yaml
sed -i '' "s/ACCOUNT_ID/$ACCOUNT_ID/" $GITOPS_DIR/apps/backend/carts/prod/kustomization.yaml
git -C $GITOPS_DIR/apps/ add .
git -C $GITOPS_DIR/apps/ commit -m "add workloads"
git -C $GITOPS_DIR/apps/ push
```
> Files are committed for both staging and prod, but prod is inactive. In a later section we will deploy to prod

Verify the Amazon DynamoDB Table in staging
```shell
kubectl -n carts get tables.dynamodb.services.k8s.aws --context staging-cluster
```

The expected output should have the `STATUS` colum with `ACTIVE` and `SYNCED` column with `True`
```shell
NAME    CLASS      STATUS   SYNCED   AGE
items   STANDARD   ACTIVE   True     78s
```

Verify App is running on staging cluster
```shell
kubectl get pods -A -l app.kubernetes.io/created-by=eks-workshop --context staging-cluster
```
There should be pods running in namespaces
```shell
NAMESPACE   NAME                             READY   STATUS    RESTARTS        AGE
assets      assets-7556557b4d-sfndh          1/1     Running   0               3m56s
carts       carts-86c7db99db-5b557           1/1     Running   0               69s
carts       carts-dynamodb-cb4b6f564-wn265   1/1     Running   0               69s
catalog     catalog-6ccfd94978-fcrkl         1/1     Running   0               3m56s
catalog     catalog-mysql-0                  1/1     Running   0               3m56s
checkout    checkout-6845d66fb-b6m82         1/1     Running   0               4m
checkout    checkout-redis-fb67f7944-j2jvr   1/1     Running   0               4m1s
orders      orders-548b6658ff-qjsv7          1/1     Running   0               3m56s
orders      orders-mysql-76dd47c48f-jwt7j    1/1     Running   0               3m56s
ui          ui-59b974ffcc-cbmkw              1/1     Running   0               69s
```

## Access Application UI

Access in
```shell
# TODO we need script to wait for url to be OK/200
# wait-lb http://$(kubectl --context prod-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Staging UI URL: http://$(kubectl --context staging-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```


# Module 4: Day 2 Operations

Platform team promotes the app to prod cluster, by updating the ApplicationSet `workloads.yaml`

```shell
sed -i '' s/"values: \[staging\]"/"values: \[staging,prod\]"/ $GITOPS_DIR/platform/bootstrap/workloads/*appset.yaml
git -C $GITOPS_DIR/platform add .
git -C $GITOPS_DIR/platform commit -m "add workloads"
git -C $GITOPS_DIR/platform push
```

Verify the Amazon DynamoDB Table in prod
```shell
kubectl -n carts get tables.dynamodb.services.k8s.aws --context prod-cluster
```

The expected output should have the `STATUS` colum with `ACTIVE` and `SYNCED` column with `True`
```shell
NAME    CLASS      STATUS   SYNCED   AGE
items   STANDARD   ACTIVE   True     78s
```


Verify App is running on prod cluster
```shell
kubectl get pods -A -l app.kubernetes.io/created-by=eks-workshop --context prod-cluster
```
There should be pods running in namespaces
```shell
NAMESPACE   NAME                             READY   STATUS    RESTARTS        AGE
assets      assets-7556557b4d-sfndh          1/1     Running   0               3m56s
carts       carts-86c7db99db-5b557           1/1     Running   0               69s
carts       carts-dynamodb-cb4b6f564-wn265   1/1     Running   0               69s
catalog     catalog-6ccfd94978-fcrkl         1/1     Running   0               3m56s
catalog     catalog-mysql-0                  1/1     Running   0               3m56s
checkout    checkout-6845d66fb-b6m82         1/1     Running   0               4m
checkout    checkout-redis-fb67f7944-j2jvr   1/1     Running   0               4m1s
orders      orders-548b6658ff-qjsv7          1/1     Running   0               3m56s
orders      orders-mysql-76dd47c48f-jwt7j    1/1     Running   0               3m56s
ui          ui-59b974ffcc-cbmkw              1/1     Running   0               69s
```

## Access Application UI in Prod


Access in
```shell
# TODO we need script to wait for url to be OK/200
# wait-lb http://$(kubectl --context prod-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Production UI URL: http://$(kubectl --context prod-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```


## Update Workload in Production

Make a change in production, like setting the `ui` HPA minReplicas to 3.
Update the patch `$GITOPS_DIR//apps/ui/prod/hpa.yaml`

Push the changes to git
```shell
sed -i '' s/"minReplicas: 2"/"minReplicas: 3"/ $GITOPS_DIR/apps/frontend/ui/prod/hpa.yaml
git -C $GITOPS_DIR/apps add .
git -C $GITOPS_DIR/apps commit -m "set minReplicas to 3 in prod"
git -C $GITOPS_DIR/apps push
```

Verify HPA `MINPODS` is now 3 in prod
```kubectl
kubectl get hpa -n ui --context prod-cluster
```

```shell
NAME   REFERENCE       TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
ui     Deployment/ui   2%/80%    3         10        3          29m
```

Verify there are at least 3 replias in prod cluster
```shell
kubectl get pods -n ui --context prod-cluster
```
Expected output
```shell
NAME                  READY   STATUS    RESTARTS   AGE
ui-59b974ffcc-fktvx   1/1     Running   0          5m
ui-59b974ffcc-hwkqh   1/1     Running   0          41s
ui-59b974ffcc-996z8   1/1     Running   0          3m23s
```

## Clean
Destroy all AWS resources
```shell
./cleanup.sh
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
