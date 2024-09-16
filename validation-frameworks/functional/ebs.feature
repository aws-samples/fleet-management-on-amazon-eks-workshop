Feature: EBS CSI Driver

  Scenario: Create a pod and verify successful mounting of an EBS volume
    Given a running EKS cluster
    And a pod with an EBS volume attached
    Then the pod with name "<pod_name>" in namespace "<pod_namespace>" should successfully mount the EBS volume
    Examples:
    | pod_name             | pod_namespace |
    | fsx-csi-node-kmtcb   | kube-system   |
    | 
  Scenario: Provision an EBS volume dynamically and verify successful attachment.
     Given a running EKS cluster
     When I request a dynamic provision of an EBS volume
     Then a new EBS volume should be provisioned and successfully attached to the pod
     
  Scenario: lustre check
     Given a running EKS cluster
     When I check
     Then stuff
     
  Scenario: lustre check1
     Given a running EKS cluster
     When I check1
     Then stuff1