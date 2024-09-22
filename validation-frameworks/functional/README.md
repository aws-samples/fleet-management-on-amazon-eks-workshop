## Functional Testing with Pytest BDD

Pytest BDD is a powerful framework that combines the simplicity of pytest with the expressive power of the Gherkin language. This allows us to write human-readable test scenarios that directly map to our business requirements.

### Key Concepts

1. **Gherkin Scenarios**: Written in plain language, describing the expected behavior of the system.
2. **Step Definitions**: Python code that implements the steps described in the Gherkin scenarios.
3. **Fixtures**: Reusable test data or objects that can be used across multiple tests.

### Sample Gherkin Scenario

Here's an example of a Gherkin scenario for testing EKS cluster creation:

```
Feature: Check Logs for Errors
    Scenario Outline: Check logs in a namespace
        Given a EKS Cluster
        When I check pods in a namespace
        Then logs should not contain any errors
```

### Implementing Step Definitions

The corresponding Python step definitions might look like this:

```
@scenario('logs.feature', 'Check logs in a namespace')
def test_publish():
    pass

@pytest.fixture(scope='module')
def found_logs():
    return []

@given("a EKS Cluster")
def eks_cluster():
    pass

@when("I check pods in a namespace")
def check_logs():
    v1 = client.CoreV1Api()
    #namespace_list = v1.list_namespace()
    namespace_list = ["amazon-cloudwatch"]
    
    #for namespace in namespace_list.items:
    for namespace in namespace_list:
        #pod_list = v1.list_namespaced_pod(namespace.metadata.name)
        #ns = namespace.metadata.name
        ns = namespace
        pod_list = v1.list_namespaced_pod(ns)
        for pod in pod_list.items:
            podname = pod.metadata.name
            print(podname)
            log_stream = v1.read_namespaced_pod_log(name=podname, namespace=ns, follow=False)
            for event in log_stream:
                log_line = event.strip()
                if "error" in log_line:
                    found_logs.append("Error")                    

@then("logs should not contain any errors")
def logs_should_not_contain_errors(found_logs):
    assert len(found_logs) == 0
    
def test_check_logs():
    pass
```

### Running Functional Tests

Follow these steps to run the functional tests:
1. Fetch kubeconfig for fleet-hub-cluster. Update the region in the below command accordingly
```
aws eks --region us-east-1 update-kubeconfig --name fleet-hub-cluster
```
2. Navigate to the functional testing directory:
```
cd $VALIDATION_MODULE_HOME/functional/
```
3. Install required packages:
```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
4. Run the pytest command:
```
pytest -s
```

### Analyzing the Results

- Review passing and failing scenarios
- Investigate any failures to understand which business requirements are not being met
- Use the generated reports to communicate test results with stakeholders

### Benefits of Functional Testing

- Validates that the EKS cluster meets business requirements
- Improves communication between technical and non-technical stakeholders
- Serves as living documentation of the system's behavior
- Facilitates test-driven development (TDD) and continuous integration

By implementing comprehensive functional tests, you ensure that your EKS cluster meets all specified business requirements and behaves as expected in various scenarios.
