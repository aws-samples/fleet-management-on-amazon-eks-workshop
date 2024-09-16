## Helm Testing

This section provides an overview of Helm testing, explains the sample test code, gives steps to run the test, and discusses how to analyze the results and the benefits of Helm testing in the context of EKS validation.

Helm tests are an integral part of validating your Kubernetes deployments. They allow you to verify that your Helm charts are functioning correctly after installation. In this section, we'll focus on testing the Karpenter Helm chart, which is a popular autoscaler for Kubernetes.


### Sample Helm Test

Below is a sample Helm test for the Karpenter chart. This test checks if the Karpenter controller pod is ready within a specified timeout period.

```
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "karpenter.fullname" . }}-test-readiness"
  labels:
    {{- include "karpenter.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  serviceAccountName: {{ include "karpenter.serviceAccountName" . }}
  containers:
    - name: test-readiness
      image: {{ .Values.controller.image.repository }}:{{ .Values.controller.image.tag | default .Chart.AppVersion }}
      command:
        - /bin/sh
        - -c
        - |
          kubectl wait --for=condition=ready pod -l app.kubernetes.io/name={{ include "karpenter.name" . }} --timeout=120s || exit 1
          echo "Karpenter controller is ready"
  restartPolicy: Never
```

This test creates a pod that uses the kubectl wait command to check if the Karpenter controller pod is in a ready state within 120 seconds.


### Running Helm Tests

To run the Helm test for Karpenter, follow these steps:
1. Ensure that you have Helm installed and configured to work with your EKS cluster.
2. Karpenter is already installed via helm while provisioning base infrastructure.
3. Navigate to the functional testing directory:
```
cd $VALIDATION_MODULE_HOME/helm/
```
4. Run the Helm test using the following command:
```
helm test karpenter
```

### Analyzing the Results

After running the Helm test, you'll see output indicating whether the test passed or failed. A successful test will look similar to this:

```
NAME: karpenter
LAST DEPLOYED: Mon May 15 10:30:00 2023
NAMESPACE: karpenter
STATUS: deployed
REVISION: 1
TEST SUITE:     karpenter-test-readiness
Last Started:   Mon May 15 10:31:00 2023
Last Completed: Mon May 15 10:31:30 2023
Phase:          Succeeded
```

If the test fails, you'll see error messages that can help you identify and troubleshoot the issue.

### Benefits of Helm Testing
- Validates correct deployment and configuration of your Helm charts
- Ensures critical components are running and ready
- Helps catch issues early in the deployment process
- Provides a standardized way to verify chart functionality across different environments
- Facilitates easier troubleshooting and maintenance of complex Kubernetes applications

By incorporating Helm tests into your EKS validation framework, you can ensure that critical components like Karpenter are correctly deployed and functioning as expected, contributing to the overall reliability and stability of your Kubernetes environment.
