## Helm Testing

This section provides an overview of Helm testing, explains the sample test code, gives steps to run the test, and discusses how to analyze the results and the benefits of Helm testing in the context of EKS validation.

Helm tests are an integral part of validating your Kubernetes deployments. They allow you to verify that your Helm charts are functioning correctly after installation. In this section, we'll focus on testing the Locust Helm chart, which is a popular autoscaler for Kubernetes.


### Sample Helm Test

Below is a sample Helm test for the Locust chart. This test checks if the Locust pods are ready within a specified timeout period.

```
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "locust.fullname" . }}-test-readiness"
  labels:
    {{- include "locust.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  serviceAccountName: {{ include "locust.fullname" . }}-master
  containers:
  - name: test-readiness
    image: bitnami/kubectl
    imagePullPolicy: IfNotPresent
    command:
      - /bin/sh
      - -c
      - |
        kubectl wait --for=condition=ready pod -l app.kubernetes.io/name={{ include "locust.name" . }} --timeout=120s || exit 1
        echo "locust pods are ready"
```

This test creates a pod that uses the kubectl wait command to check if the Locust pods are in a ready state within 120 seconds.


### Running Helm Tests

To run the Helm test for locust, follow these steps:
1. Ensure that you have Helm installed and configured to work with spoke EKS cluster.
```
echo $EKS_CLUSTER_NAME
aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
```
2. Navigate to the functional testing directory:
```
cd $VALIDATION_MODULE_HOME/helm/locust
```
3. Run the Helm test using the following command:
```
helm install -f values.yaml locust-release .
helm test locust-release --logs 
```

### Analyzing the Results

After running the Helm test, you'll see output indicating whether the test passed or failed. A successful test will look similar to this:
```
NAME: locust-release
LAST DEPLOYED: Thu Sep 19 23:14:26 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE:     locust-release-test-resources
Last Started:   Thu Sep 19 23:15:01 2024
Last Completed: Thu Sep 19 23:15:04 2024
Phase:          Succeeded
TEST SUITE:     locust-release-test-readiness
Last Started:   Thu Sep 19 23:14:32 2024
Last Completed: Thu Sep 19 23:15:01 2024
Phase:          Succeeded
```

If the test fails, you'll see error messages that can help you identify and troubleshoot the issue.

### Cleanup
After running the Helm test, you can cleanup the helm release:
```
helm uninstall locust-release
```

### Benefits of Helm Testing
- Validates correct deployment and configuration of your Helm charts
- Ensures critical components are running and ready
- Helps catch issues early in the deployment process
- Provides a standardized way to verify chart functionality across different environments
- Facilitates easier troubleshooting and maintenance of complex Kubernetes applications

By incorporating Helm tests into your EKS validation framework, you can ensure that critical components are correctly deployed and functioning as expected, contributing to the overall reliability and stability of your Kubernetes environment.
