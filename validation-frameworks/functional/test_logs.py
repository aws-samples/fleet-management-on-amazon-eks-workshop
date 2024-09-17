import pytest
from pytest import  fixture
from pytest_bdd import scenario, scenarios, given, when, then, parsers
from kubernetes import client, config, watch
from kubernetes.client.rest import ApiException

config.load_kube_config()

# Define the BDD scenarios
@scenario('logs.feature', 'Check logs in a namespace')
def test_publish():
    pass

@given("a EKS Cluster")
def eks_cluster():
    pass

@when("I check pods in a namespace")
def check_logs():
    v1 = client.CoreV1Api()
    namespace_list = v1.list_namespace()
    
    for namespace in namespace_list.items:
        pod_list = v1.list_namespaced_pod(namespace.metadata.name)
        ns = namespace.metadata.name
        for pod in pod_list.items:
            podname = pod.metadata.name
            
            log_stream = watch.Watch().stream(v1.read_namespaced_pod_log, name=podname, namespace=ns, follow=True)
            for event in log_stream:
                log_line = event.strip()
                if "error" in log_line:
                    pytest.logs_found("Error")
                    raise Exception("Error in logs")
                    

@then("logs should not contain any errors")
def logs_should_not_contain_errors():
    assert len(pytest.logs_found) == 0
    
# This is just a placeholder test function, you can add more test cases as needed
def test_check_logs():
    pass