Feature: Check if EBS volumes are mounted in the Kubernetes cluster

Scenario: Verify EBS volumes are mounted
  Given a cluster
  When pvc
  Then stuff