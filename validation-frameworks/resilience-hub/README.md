## Prerequisites

Command line tools: Install the latest version of [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), aws-iam-authenticator, [kubectl, and eksctl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html).

## Integrating Amazon EKS with AWS Resilience Hub
### Deploy EKS Cluster and Sample Application

**Step 1: Create an EKS Cluster**

After you create fleet-hub-cluster Amazon EKS cluster, you must configure your kubeconfig file using the AWS CLI. This configuration allows you to connect to your cluster using the `kubectl` command line. The following `update-kubeconfig` command will create a kubeconfig file for your cluster. Test and verify your cluster is up, you can reach/access it by running any `kubectl` get command.

```bash
aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
kubectl get nodes
```

**Step 2: Deploy sample application on Amazon EKS Cluster**

The next thing we need to do is deploy our sample application on Amazon EKS Cluster. We have an application deployment manifest ready for consumption.

```bash
cd $VALIDATION_MODULE_HOME/resilience-hub/eks-resilience-hub-integration/sample-app
kubectl apply -f components.yaml
```

Test and verify that `demo-app` application is up and running by running the below command. You should see an similar output to shown below:

![Demo Pods](/diagrams/fleet/images/demo-app-pods.png)

## Allow AWS Resilience Hub access to the EKS cluster

AWS Resilience Hub queries resources inside Amazon EKS cluster by assuming an IAM role in your account. This IAM role is mapped to a Kubernetes group and grants the required permission to assess the Amazon EKS cluster.

The following steps grant AWS Resilience Hub with the required permissions to discover resources inside your Amazon EKS cluster.

**Create an IAM role named AwsResilienceHubAssessmentEKSAccessRole**

This role will be assumed by AWS Resilience Hub when importing and assessing your application. It will be mapped with an Amazon EKS group that enables the AWS Resilience Hub to assess our Amazon EKS cluster.

```bash
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

export POLICY=$(echo -n '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':root"},"Action":"sts:AssumeRole","Condition":{}},{"Effect":"Allow","Principal":{"Service":"resiliencehub.amazonaws.com"},"Action":"sts:AssumeRole"}]}')

aws iam create-role \
--role-name AwsResilienceHubAssessmentEKSAccessRole \
--description="Amazon Resilience Hub read only role (for AWS IAM Authenticator for Kubernetes)." \
--assume-role-policy-document "$POLICY"

aws iam attach-role-policy \
--role-name AwsResilienceHubAssessmentEKSAccessRole \
--policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

**Create a Resilience Hub ClusterRole and RoleBinding/ClusterRoleBinding**

To grant AWS Resilience Hub read access across all namespaces create the required ClusterRole and ClusterRoleBinding by running below command.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: resilience-hub-eks-access-cluster-role
rules:
  - apiGroups:
      - ""
    resources:
      - pods
      - replicationcontrollers
      - nodes
    verbs:
      - get
      - list
  - apiGroups:
      - apps
    resources:
      - deployments
      - replicasets
    verbs:
      - get
      - list
  - apiGroups:
      - policy
    resources:
      - poddisruptionbudgets
    verbs:
      - get
      - list
  - apiGroups:
      - autoscaling.k8s.io
    resources:
      - verticalpodautoscalers
    verbs:
      - get
      - list
  - apiGroups:
      - autoscaling
    resources:
      - horizontalpodautoscalers
    verbs:
      - get
      - list
  - apiGroups:
      - karpenter.sh
    resources:
      - provisioners
    verbs:
      - get
      - list
  - apiGroups:
      - karpenter.k8s.aws
    resources:
      - awsnodetemplates
    verbs:
      - get
      - list

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: resilience-hub-eks-access-cluster-role-binding
subjects:
  - kind: Group
    name: resilience-hub-eks-access-group
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: resilience-hub-eks-access-cluster-role
  apiGroup: rbac.authorization.k8s.io
---  
EOF
```

**Mapping between IAM role and Kubernetes group**

Then create a mapping between the IAM role `AwsResilienceHubAssessmentEKSAccessRole`, with the Kubernetes group `resilience-hub-eks-access-group`, granting the IAM roles permissions to access resources inside the Amazon EKS cluster.

```bash
eksctl create iamidentitymapping \
 --cluster $EKS_CLUSTER_NAME \
 --region=$REGION \
 --arn arn:aws:iam::"$ACCOUNT_ID":role/AwsResilienceHubAssessmentEKSAccessRole \
 --group resilience-hub-eks-access-group \
 --username AwsResilienceHubAssessmentEKSAccessRole
 ```

## Running the Resiliency assessment

Follow the below steps to run Resiliency assessment of `demo-app` application running on Amazon EKS as deployed above.

1. Create a new Resiliency policy based on Foundational Core Service

    * [Launch AWS Resilience Hub](https://us-east-1.console.aws.amazon.com/resiliencehub/home?region=us-east-1) → Policies (under Resilience management)

    * Click on `Create resiliency policy`
        - Choose Select a policy based on a suggested policy
        - Policy name: `demo-app-foundational-core-policy`
        - Under Suggested resiliency policies, choose `Foundational Core Service` and then Click Create

2. Add Amazon EKS Cluster and Demo Application to AWS Resilience Hub

    * [Launch AWS Resilience Hub](https://us-east-1.console.aws.amazon.com/resiliencehub/home?region=us-east-1) → Click Add Application

    * Enter the following 
        - Application Name: `demo-app`
        - Description: `Demo Application Hosted on EKS`
        - How is this application managed? `Select EKS Only`
        - Add EKS clusters
            Select EKS Clusters: select the corresponding cluster
        - Under Add namespace, enter `demo-app`, check the box to use the namespaces and click Save
    
    * Set RPO and RTO
        - Select the option: Choose an existing resilience policy and select `demo-app-foundational-core-policy` from options
    * Setup Permissions
        - Select the option: Use an IAM role and select `AwsResilienceHubAssessmentEKSAccessRole`
    * Setup scheduled assessment and drift notification
        - You can either setup automatic daily assessments or turn off the option
    * Click on Add Application once this is all done

3. Running the Assessment

    * Under Applications on the AWS Resilience Hub, click your application `demo-app`
    * Click on `Publish` option under Workflow to publish the  application and its resources
    * Once it's Published, you can create and run resiliency assessment in couple of ways. You can either
         - Click Assessments tab and then Run new resiliency assessment
         - Click Assess resiliency under Workflow
    * Provide a name to the report (`for eg. demo-app-res-assess`)  and then click `Run`
    * The Resiliency assessment will list the assessment with status `“Pending”`. You can refresh the assessment and the status will change to `“In Progress”`. It will take a few minutes to finish the assessment to `“Success”`


## Reviewing the Resiliency assessment

The Resiliency assessment provides an overview of the assessment report. AWS Resilience Hub lists each disruption type and the associated application component. It also lists your actual RTO and RPO policies and determines whether the application component can achieve the policy goals.

To review your assessment, follow the below steps:

* After the assessment status changes to `“Success”`. Click on report `demo-app-res-assess`
* Next to the assessment name, you will see either the `“Policy met”` or `“Policy breached”`. If you followed the above instructions it will be `“Policy breached”`. Click on the report `demo-app-res-assess assessment`.
* The report is broken primarily in 3 sections/tabs. The **Results, Resiliency recommendations and Operational** recommendations. 
* The `Results tab` lists the summary of the RTO and RPO, Estimated against the Targeted. The results also provides detailed descriptions of each disruption type (application, infrastructure, Availability Zone, and Region). AWS Resilience Hub will display breaches across Infrastructure, Availability Zone and Region.
* Say, you want to understand more on Infrastructure breaches. Toggle the `Infrastructure tab`. Click on the Estimated RTO for the top `AppComponent`.  A pop up text explains in detail the reason for the `AppComponent` breach. Feel free to explore the other AppComponent’s in the list.

## Reviewing the Resiliency recommendations

* Now that we have looked at the breaches, lets look at the `Resiliency recommendations` to fix the policy breaches. Resiliency recommendations evaluate application components and recommend optimization changes by RTO and RPO, costs, and minimal changes.
* Click on `Resiliency recommendations` tab
* Under `AppComponents`, select the top component. You will see the benefits for fixing the `AppComponent`. For this selection you will see `“Optimize for Cost, minimal changes and Best Region RTO/RPO”` as the benefits.


## Cleanup

When you’re done testing, delete the resources you created so that you’re no longer billed for them. To clean everything, follow these steps:

* Remove the application from AWS Resilience Hub :
    - Go to AWS Resilience Hub Console → Click Applications → select `demo-app` → Click `“Actions”` → `Delete`

* Remove Sample Application, AWS Resilience Hub ClusterRole and ClusterRoleBindings from Amazon EKS Cluster by running below commands in your terminal
```bash
    cd $VALIDATION_MODULE_HOME/resilience-hub/eks-resilience-hub-integration/sample-app
    kubectl delete -f components.yaml
    kubectl delete clusterrolebinding name resilience-hub-eks-access-cluster-role-binding
    kubectl delete clusterrole name resilience-hub-eks-access-cluster-role
```

## Simulate Kubernetes Workload AZ Failure with AWS Fault Injection Simulator and Remediate Using Karpenter


In highly distributed systems, it is crucial to ensure that applications function correctly even during infrastructure failures. One common infrastructure failure scenario is when an entire Availability Zone (AZ) becomes unavailable. Kubernetes helps manage and deploy applications across multiple nodes and AZs, though it can be difficult to test how your applications will behave during an AZ failure. This is where fault injection simulators come in. The AWS Fault Injection Simulator (AWS FIS) service can intentionally inject faults or failures into a system to test its resilience. This test uses AWS FIS to disrupt network connectivity, and simulate AZ failure in a controlled manner. We will use Karpenter as the autoscaler. Karpenter automatically adjusts the size of a cluster based on the resource requirements of the running workloads and schedules the pods in other AZs if a particular AZ got impacted.


**Step 1: Verify Karpenter installation and check Node Class**

When you initially created the Amazon EKS cluster, Karpenter was also installed on it. By default, it creates a node class that enables the configuration of AWS-specific settings. Karpenter uses this node class when launching nodes, and a subnet is automatically chosen that matches the desired zone. If multiple subnets exist for a zone, the one with the most available IP addresses will be used. The installed EC2 Node Class will have all three subnets configured to it.

```bash
  kubectl get ec2nodeclass compute-optimized -o jsonpath='{.status.subnets}'
```

**Step 2: Deploy sample application on Amazon EKS Cluster**

The next step is to deploy our sample application on the Amazon EKS cluster. We have an application deployment manifest prepared that will create a deployment with a single pod.

```bash
  cd $VALIDATION_MODULE_HOME/resilience-hub/fis-karpenter
  kubectl apply -f fis-deployment.yaml
```

**Step 3: Create an IAM Role for AWS FIS and attach required policies**
```bash
  aws iam create-role --role-name eks-fis-simulation --assume-role-policy-document file://fis-trust-policy.json

  aws iam attach-role-policy --role-name eks-fis-simulation --policy-arn  arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorNetworkAccess
  aws iam attach-role-policy --role-name eks-fis-simulation --policy-arn  arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
  aws iam attach-role-policy --role-name eks-fis-simulation --policy-arn  arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEKSAccess
  aws iam attach-role-policy --role-name eks-fis-simulation --policy-arn  arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access
  aws iam attach-role-policy --role-name eks-fis-simulation --policy-arn  arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorSSMAccess
```

**Step 4: Create an FIS experiment**
Verify the new pod, and note the Availability Zone (AZ) of the node on which it is running.

```bash
  kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}' -n fis-demo | awk '{print $2}' | xargs -I{} kubectl get node {} -o=jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}'
```

Go to the [AWS FIS console](https://us-west-2.console.aws.amazon.com/fis/home?region=us-west-2#ExperimentTemplates), and create a new Experiment Template targeting the current AWS account based on the Availability Zone (AZ) information you received. For example, if the AZ information is us-west-2a, create the Experiment Template for that specific AZ.

```
Description: az-disrupt-connectivity-us-west-2a
Name: az-disrupt-connectivity-us-west-2a
Create a new action: aws:network:disrupt-connectivity
```
![AZ Disrupt- Action](/diagrams/fleet/images/az-disrupt-action.png)
```
Select target with the Subnet belonging to us-west-2a.
```
![AZ Disrupt- Target](/diagrams/fleet/images/az-disrupt-target.png)

```
Ensure to select the IAM role created in the previous step, and then create the Experiment Template.
```

**Step 5: Start the FIS experiment**
Now we are set to start the FIS (Fault Injection Simulator) experiment, which will simulate an outage on the us-west-2a Availability Zone. Open the Experiment Template you just created and click on `Start Experiment`. The AWS Fault Injection Simulator will disrupt connectivity on the us-west-2a AZ, and here's where Karpenter will step in to create a new pod in another AZ that's not impacted by the outage automatically. 

This process may take 4-5 minutes to appear in the Karpenter logs, but you should be able to see a new pod created on a new instance based out of a different AZ (us-west-2c in this case).

**Karpenter logs:**
```
{"level":"INFO","time":"2024-08-22T19:45:16.417Z","logger":"controller","message":"found provisionable pod(s)","commit":"490ef94","controller":"provisioner","Pods":"fis-demo/fis-app-7d694976c8-s6xmv, kube-system/aws-load-balancer-controller-994567f7b-ztdnz","duration":"51.54347ms"}
{"level":"INFO","time":"2024-08-22T19:45:16.417Z","logger":"controller","message":"computed new nodeclaim(s) to fit pod(s)","commit":"490ef94","controller":"provisioner","nodeclaims":1,"pods":2}
{"level":"INFO","time":"2024-08-22T19:45:16.430Z","logger":"controller","message":"created nodeclaim","commit":"490ef94","controller":"provisioner","NodePool":{"name":"compute-optimized"},"NodeClaim":{"name":"compute-optimized-4sxxx"},"requests":{"cpu":"310m","memory":"440Mi","pods":"7"},"instance-types":"c1.medium, c1.xlarge, c3.2xlarge, c3.4xlarge, c3.large and 55 other(s)"}
{"level":"INFO","time":"2024-08-22T19:45:19.047Z","logger":"controller","message":"launched nodeclaim","commit":"490ef94","controller":"nodeclaim.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"NodeClaim","NodeClaim":{"name":"compute-optimized-4sxxx"},"namespace":"","name":"compute-optimized-4sxxx","reconcileID":"f27daac5-827a-419a-a8d8-2acaa84c1c42","provider-id":"aws:///us-west-2c/i-024524212c0795d0a","instance-type":"c7a.medium","zone":"us-west-2c","capacity-type":"on-demand","allocatable":{"cpu":"940m","ephemeral-storage":"89Gi","memory":"1451Mi","pods":"8","vpc.amazonaws.com/pod-eni":"4"}}
{"level":"INFO","time":"2024-08-22T19:45:49.398Z","logger":"controller","message":"registered nodeclaim","commit":"490ef94","controller":"nodeclaim.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"NodeClaim","NodeClaim":{"name":"compute-optimized-4sxxx"},"namespace":"","name":"compute-optimized-4sxxx","reconcileID":"31b9307b-bed0-43da-a2ae-8c9550ed8a07","provider-id":"aws:///us-west-2c/i-024524212c0795d0a","Node":{"name":"ip-10-1-4-91.us-west-2.compute.internal"}}
{"level":"INFO","time":"2024-08-22T19:46:02.004Z","logger":"controller","message":"initialized nodeclaim","commit":"490ef94","controller":"nodeclaim.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"NodeClaim","NodeClaim":{"name":"compute-optimized-4sxxx"},"namespace":"","name":"compute-optimized-4sxxx","reconcileID":"b2ea7ed6-0986-4e63-856f-99ad187edd1f","provider-id":"aws:///us-west-2c/i-024524212c0795d0a","Node":{"name":"ip-10-1-4-91.us-west-2.compute.internal"},"allocatable":{"cpu":"940m","ephemeral-storage":"95551679124","hugepages-1Gi":"0","hugepages-2Mi":"0","memory":"1478156Ki","pods":"8"}}
{"level":"INFO","time":"2024-08-22T20:11:45.888Z","logger":"controller","message":"disrupting via emptiness delete, terminating 1 nodes (0 pods) ip-10-1-43-26.us-west-2.compute.internal/c7a.medium/on-demand","commit":"490ef94","controller":"disruption","command-id":"1d3fd8c1-260c-42ab-9804-e623462e8017"}
{"level":"INFO","time":"2024-08-22T20:11:46.854Z","logger":"controller","message":"command succeeded","commit":"490ef94","controller":"disruption.queue","command-id":"1d3fd8c1-260c-42ab-9804-e623462e8017"}
{"level":"INFO","time":"2024-08-22T20:11:46.879Z","logger":"controller","message":"tainted node","commit":"490ef94","controller":"node.termination","controllerGroup":"","controllerKind":"Node","Node":{"name":"ip-10-1-43-26.us-west-2.compute.internal"},"namespace":"","name":"ip-10-1-43-26.us-west-2.compute.internal","reconcileID":"acbf36d5-2d89-4ac5-aff1-6753821edafd"}
{"level":"INFO","time":"2024-08-22T20:11:47.264Z","logger":"controller","message":"deleted node","commit":"490ef94","controller":"node.termination","controllerGroup":"","controllerKind":"Node","Node":{"name":"ip-10-1-43-26.us-west-2.compute.internal"},"namespace":"","name":"ip-10-1-43-26.us-west-2.compute.internal","reconcileID":"acbf36d5-2d89-4ac5-aff1-6753821edafd"}
{"level":"INFO","time":"2024-08-22T20:11:47.583Z","logger":"controller","message":"deleted nodeclaim","commit":"490ef94","controller":"nodeclaim.termination","controllerGroup":"karpenter.sh","controllerKind":"NodeClaim","NodeClaim":{"name":"compute-optimized-w588l"},"namespace":"","name":"compute-optimized-w588l","reconcileID":"6d0a5f10-4783-4e53-85dc-8fb0ac7f1ce4","Node":{"name":"ip-10-1-43-26.us-west-2.compute.internal"},"provider-id":"aws:///us-west-2a/i-0f6d0e6050bc72879"}

```

**Check out the new pod, node and AZ information:**

Based on the logs, the new pod would have been created on a node from a different Availability Zone (AZ), such as us-west-2c.

```bash
  kubectl get pods -n fis-demo -o wide

  kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}' -n fis-demo | awk '{print $2}' | xargs -I{} kubectl get node {} -o=jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}'
```

## Cleanup

When you’re done testing, delete the resources you created so that you’re no longer billed for them. To clean everything, follow these steps:

* Delete the sample Application, IAM role
```bash
    cd $VALIDATION_MODULE_HOME/resilience-hub/fis-karpenter
    kubectl delete -f -f fis-deployment.yaml
```

* Delete IAM resources
```bash
    aws iam delete-role --role-name eks-fis-simulation
```
* Delete FIS resources- Go to the [AWS FIS console](https://us-west-2.console.aws.amazon.com/fis/home?region=us-west-2#ExperimentTemplates), and delete the created Experiment templates.

