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
    
# This is just a placeholder test function, you can add more test cases as needed
def test_check_logs():
    pass