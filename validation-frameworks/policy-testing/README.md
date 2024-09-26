## Policy Testing

In this section, we'll use Chainsaw to test Kyverno policies in our EKS cluster. Chainsaw is a powerful testing framework for Kubernetes, while Kyverno is a policy engine designed for Kubernetes.

## Introduction to Kyverno and Chainsaw

Kyverno is a policy engine for Kubernetes that allows you to define and enforce policies as resources. It can validate, mutate, and generate Kubernetes resources based on these policies.

Chainsaw is a testing framework that allows you to define and run tests for Kubernetes resources and policies. It's particularly useful for testing Kyverno policies, as it can simulate various scenarios and verify the expected outcomes.

## Setting Up the Test Environment

Before we begin, ensure you have Chainsaw and Kyverno installed in your EKS cluster.
```bash
kubectl get deployments -n kyverno
```
If not, you can install them using the following commands:
```bash
# Install Kyverno
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.12.5/install.yaml

# Install Chainsaw
kubectl apply -f https://github.com/kyverno/chainsaw/releases/download/v0.2.9/install.yaml
```

## The Test Case: Mutating Deployments on Secret Update

Our test case involves a Kyverno policy that mutates a Deployment when a specific ConfigMap is updated. This is a common pattern used to trigger a rolling update of a Deployment when its configuration (stored in a ConfigMap) changes.

### Test Components

**ClusterRole** (`clusterrole.yaml`): Defines the permissions needed for Kyverno to mutate the specific Deployment.
**ClusterPolicy** (`policy.yaml`): The Kyverno policy that watches for updates to a specific ConfigMap and triggers a mutation on the Deployment.
**Policy Assert** (`policy-assert.yaml`): Used to verify that the policy is correctly created and ready.
**Test Definition** (`chainsaw-test.yaml`): The Chainsaw test definition that orchestrates the application of resources and assertions.

### Step-by-Step Explanation

1. **Apply the ClusterRole**:
   The test first applies the ClusterRole, which gives Kyverno the necessary permissions to mutate the "busybox" Deployment.

2. **Apply and Assert the Policy**:
   The test then applies the Kyverno policy and immediately asserts that it's created successfully and in a "Ready" state.

### Running the Test

To run the test, use the following command:

```bash
cd $VALIDATION_MODULE_HOME/policy-testing/rbac-policy-mutation
chainsaw test --test-file chainsaw-test.yaml
```

This command will execute the steps defined in `chainsaw-test.yaml`, applying the ClusterRole and Policy, and then asserting that the Policy is correctly created.

### Expected Outcome

If the test passes, you should see output indicating that both steps were successful. This means:

1. The ClusterRole was successfully applied.
2. The Kyverno policy was successfully created and is in a "Ready" state.

### Interpreting the Results

A successful test run indicates that:

1. The necessary RBAC permissions are in place for Kyverno to perform its operations.
2. The policy for mutating Deployments based on Secret updates is correctly defined and active.

### Next Steps

After confirming that the policy is correctly in place, you could extend the test to:

1. Create or update the "busybox-config" configmap.
2. Verify that the "busybox" Deployment is indeed mutated as expected.
3. Test edge cases, such as updates to other Secrets or Deployments, to ensure the policy only affects the intended resources.

By using Chainsaw to test your Kyverno policies, you can ensure that your cluster's policy enforcement is working as expected, providing an additional layer of security and consistency to your EKS environment.
