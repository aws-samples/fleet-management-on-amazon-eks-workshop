import pytest
from pytest_bdd import scenarios, given, then, parsers
from kubernetes import client, config
from kubernetes.client.rest import ApiException


# Define the BDD scenarios
scenarios('ebs.feature')

@pytest.fixture(scope="session")
def kube_config():
    # Load the Kubernetes configuration
    config.load_kube_config()
    yield

@pytest.fixture(scope="session")
def v1_core_api():
    # Create an instance of the Kubernetes CoreV1Api
    api = client.CoreV1Api()
    return api

@pytest.fixture(scope="session")
def eks_cluster(v1_core_api):
    # Set up your EKS cluster here
    cluster = v1_core_api.list_node()
    yield cluster
    # Clean up the EKS cluster resources if needed

@pytest.fixture(scope="session")
def ebs_volume(v1_core_api):
    # Set up your EBS volume here
    volume = v1_core_api.list_persistent_volume()
    yield volume
    # Clean up the EBS volume resources if needed

@pytest.fixture(scope="session")
def pod(v1_core_api, ebs_volume):
    # Set up the pod with the attached EBS volume here
    pod = client.V1Pod()
    # Attach the EBS volume to the pod using appropriate API calls
    yield pod
    # Clean up the pod resources if needed

@given(parsers.parse('a running EKS cluster'))
def running_eks_cluster(kube_config, eks_cluster):
    return eks_cluster

@given(parsers.parse('a pod with an EBS volume attached'))
def pod_with_ebs_volume(kube_config, pod):
    return pod

@then(parsers.parse('the pod with name "{pod_name}" in namespace "{pod_namespace}" should successfully mount the EBS volume'))
def verify_ebs_volume_mounting(pod_name, pod_namespace, v1_core_api):
    try:
        # Retrieve the pod's status from the API
        pod_status = v1_core_api.read_namespaced_pod_status(name=pod_name, namespace=pod_namespace, async_req=True)
        
        # Check if the pod is in the "Running" phase
        #assert pod_status.status.phase == "Running"

        # Retrieve the volume mount status from the pod's container status
        container_status = pod_status.status.container_statuses[0]
        volume_mount_status = container_status.volume_mounts[0]
        
        # Check if the volume mount is successful
        assert volume_mount_status.mounted
        
    except ApiException as e:
        # Handle any exceptions that occurred during API calls
        print(f"Exception when calling CoreV1Api: {e}")
        assert False