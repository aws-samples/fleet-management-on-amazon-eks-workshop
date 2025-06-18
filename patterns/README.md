# Fleet Management on Amazon EKS Workshop Patterns

This repository contains patterns for managing a fleet of Amazon EKS clusters using open-source tools. Currently, it includes one pattern:

## [KRO EKS Cluster Management](./kro-eks-cluster-mgmt)

This pattern demonstrates a comprehensive solution for managing multiple Amazon EKS clusters across different environments and regions using a hub-spoke architecture with open-source tools.

### Key Components

- **Cluster Management**
  - [kro](https://kro.run/) - Kubernetes Resource Orchestrator for defining complex resources
  - [ACK Controllers](https://aws-controllers-k8s.github.io/community/) - AWS Controllers for Kubernetes to manage AWS resources
  - Multi-region and multi-account support

- **GitOps and Continuous Delivery**
  - [Argo CD](https://argoproj.github.io/argo-cd/) - Declarative GitOps continuous delivery tool
  - [Kargo](https://kargo.io/) - Application promotion across environments
  - [Argo Rollouts](https://argoproj.github.io/rollouts/) - Progressive delivery controller

- **Developer Experience**
  - [Backstage](https://backstage.io/) - Developer portal for service catalog and templates
  - [Keycloak](https://www.keycloak.org/) - Identity and access management

### Architecture

The pattern uses a hub-spoke model:
- A management cluster (hub) is created as the central control plane
- Workload clusters (spokes) are provisioned and managed from the hub
- Applications are deployed and promoted across environments (test, pre-prod, prod-eu, prod-us)

### Features

- Automated EKS cluster provisioning with infrastructure as code
- Centralized management of cluster add-ons and configurations
- Progressive delivery with canary deployments
- Continuous promotion workflow across environments
- Developer self-service capabilities

### Getting Started

Follow the detailed walkthrough in the [pattern documentation](./kro-eks-cluster-mgmt/README.md) to:
1. Set up the management cluster
2. Configure GitOps with Argo CD and GitLab
3. Bootstrap management and spoke accounts
4. Create spoke clusters across environments
5. Deploy and promote applications using the continuous delivery pipeline

## Contributing

We welcome contributions to add more patterns for EKS fleet management. Please follow the standard GitHub pull request process to submit your contributions.
