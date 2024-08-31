# Fleet Bootstrap Deployment Guide

For each fleet member EKS cluster, we will deploy a Helm chart called "Fleet Member Init" to the fleet member.

## Step 0: Initial Setup

- Create a CodeCommit Git repository.
- Create an AWS Secrets Manager key with Git SSH keys that rotate every 90 days.
- Create the Hub cluster.
- Bootstrap the Hub cluster with the `gitops-bridge-addons` Helm chart.

## Step 1: EKS Cluster Creation and Secret Setup

- For each fleet member, an EKS cluster is created using Infrastructure as Code (IaC) tools such as Terraform (TF), AWS Controllers for Kubernetes (ACK), or Cluster API (CAPI).
- The IaC process will create an AWS Secrets Manager key containing the cluster information for the Spoke cluster.
- The Hub cluster will be created with ArgoCD deployed via IaC, which is necessary to bootstrap the External Secrets Operator to prepare for the spoke registration process.

### Hub Cluster Initialization

- The Hub cluster is configured to wait for secrets from the Spoke clusters. Once these secrets are available, the registration process can begin.
- The Fleet control plane on the Hub cluster includes the following applications:
  - **Hub Secret Store**: Manages the external secrets required by the Hub cluster.
  - **Fleet Hub Secrets**: Utilizes the secrets created by the Spoke clusters to register these clusters with the Hub.
  - **Fleet Member Init**: Bootstraps the Spoke clusters and integrates them into the Fleet control plane.

## Step 2: Register Fleet Member and Trigger Secret Creation

- In the Fleet repository, under the `members` directory, create a new folder named after the fleet member (e.g., `fleet_member_name`).
- Inside this folder, add a `values.yaml` file containing:
  - The name of the AWS Secrets Manager key with the Spoke cluster information.
  - The name of the fleet cluster.

### Triggering the ApplicationSet and Secret Creation

- Adding this folder will trigger the ArgoCD generator to:
  - Automatically create a new secret that registers the Spoke cluster with the Hub.
  - Create a new member in the Fleet Member Init, which will deploy ArgoCD and the External Secrets Operator to the Spoke cluster. This will also include the deployment of fleet member manifests that contain the GitOps Bridge Helm chart or any other resources needed by the Spoke clusters, as defined in the `members-manifest` folder.

## Step 3: Fleet Member Init Deployment to Spoke Cluster

- The new member in the Fleet Member Init will push the following to the Spoke cluster:
  - An ArgoCD ApplicationSet that deploys ArgoCD.
  - The External Secrets Operator.
  - GitOps Bridge Helm chart.

  Once deployed, the External Secrets Operator on the Spoke cluster will:
  - Create a Secret Store with the necessary information to connect to the secrets created in Step 0.
  - Create external secrets that contain the information required for deploying addons to the Spoke cluster and the secrets needed to connect to the Git repositories.

  After this, all subsequent applications are deployed by the ArgoCD instance on the Spoke cluster, not the one on the Hub. However, all the information about the repositories it needs to connect to will be sourced from the Hub cluster.
