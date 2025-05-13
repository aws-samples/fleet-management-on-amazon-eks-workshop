import pytest
from pytest import fixture
from pytest_bdd import scenario, scenarios, given, when, then, parsers
from kubernetes import client, config, watch
from kubernetes.client.rest import ApiException
import os
import subprocess
import json

def get_aws_token():
    try:
        # Get cluster name
        cluster_name = os.getenv('EKS_CLUSTER_NAME')
        if not cluster_name:
            raise ValueError("EKS_CLUSTER_NAME environment variable is not set")
        
        # Get token using AWS CLI
        cmd = f"aws eks get-token --cluster-name {cluster_name}"
        result = subprocess.run(cmd.split(), capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception(f"Failed to get AWS token: {result.stderr}")
        
        token_data = json.loads(result.stdout)
        return token_data['status']['token']
    except Exception as e:
        print(f"Error getting AWS token: {e}")
        raise

@scenario('logs.feature', 'Check logs in a namespace')
def test_publish():
    pass

@pytest.fixture(scope='module')
def found_logs():
    return []

@given("a EKS Cluster")
def eks_cluster():
    try:
        # Load the basic kubeconfig
        config.load_kube_config()
        
        # Get configuration and update it with AWS token
        configuration = client.Configuration.get_default_copy()
        token = get_aws_token()
        configuration.api_key = {'authorization': f'Bearer {token}'}
        
        # Set the new configuration as default
        client.Configuration.set_default(configuration)
        
        # Verify connection
        v1 = client.CoreV1Api()
        v1.list_namespace()
        
    except Exception as e:
        print(f"Error setting up EKS connection: {e}")
        raise

@when("I check pods in a namespace")
def check_logs(found_logs):
    v1 = client.CoreV1Api()
    try:
        namespace_list = ["ui", "orders"]
        
        for namespace in namespace_list:
            ns = namespace
            pod_list = v1.list_namespaced_pod(ns)
            for pod in pod_list.items:
                podname = pod.metadata.name
                print(f"Checking pod: {podname}")
                log_stream = v1.read_namespaced_pod_log(
                    name=podname, 
                    namespace=ns, 
                    follow=False
                )
                if isinstance(log_stream, str):
                    if "error" in log_stream.lower():
                        found_logs.append("Error in " + podname)
                else:
                    for event in log_stream:
                        log_line = event.strip()
                        if "error" in log_line.lower():
                            found_logs.append("Error")
    except ApiException as e:
        print(f"Kubernetes API error: {e}")
        raise

@then("logs should not contain any errors")
def logs_should_not_contain_errors(found_logs):
    assert len(found_logs) == 0

def test_check_logs():
    pass
