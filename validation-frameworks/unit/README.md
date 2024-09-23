## Unit Testing

The Terraform test framework allows us to write and run tests for our infrastructure code. These tests help ensure that our modules are functioning correctly and adhering to our defined standards.

#### Step to run the unit test
Follow these steps to run the Terraform tests:
1. This sample test uses the fleet-spoke-staging as source. Therefore, make sure the staging spoke cluster is deployed.
2. Now, navigate to unit testing framework directory
```
export VALIDATION_MODULE_HOME=~/environment/fleet-management-on-amazon-eks-workshop/validation-frameworks
export EKS_CLUSTER_NAME="fleet-spoke-staging"
cd $VALIDATION_MODULE_HOME/unit/tests
```
3. Initialise Terraform:
```
terraform workspace select -or-create staging
terraform init
```
4. Run Terraform tests:
```
terraform test -var="name=$EKS_CLUSTER_NAME" 
```

#### Analyzing the Results

After running the unit test, analyze the results:

- Check for passing and failing tests
- Review any error messages or warnings
- Verify that all modules are functioning as expected
- Ensure compliance with best practices and organizational standards

```
terraform test
tests/eks.tftest.hcl... in progress
  run "create_eks_cluster"... pass
tests/eks.tftest.hcl... tearing down
tests/eks.tftest.hcl... pass

Success! 1 passed, 0 failed.
```

#### Benefits of Unit Testing

- Ensures individual modules work correctly
- Catches issues early in the development process
- Facilitates easier maintenance and refactoring
- Provides documentation for module usage and expected behavior
- Increases confidence in the overall infrastructure code quality

By implementing thorough unit tests, you can validate that your EKS-related Terraform modules are robust, reliable, and adhere to your organization's standards.
