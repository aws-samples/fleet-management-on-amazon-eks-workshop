import pytest
from pytest_bdd import scenario, given, when, then, parsers
from kubernetes import client, config
from kubernetes.client.rest import ApiException

config.load_kube_config()
v1 = client.CoreV1Api()
namespaces = v1.list_namespace().items
#print(namespaces)
#print('I am Here Sairam')
pvc_list9 = v1.list_namespaced_persistent_volume_claim('default')
#print(pvc_list9)

# Define the BDD scenarios
scenario('ebsvol.feature', 'Verify EBS volumes are mounted')
def test_publish():
    pass

@given("a cluster")
def running_eks_cluster():
    pass
    

@when("pvc")
def test_ebs_volumes_mounted():
    namespaces = v1.list_namespace().items
    pvc_list = []
    for namespace in namespaces:
        try:
            pvc_list = v1.list_namespaced_persistent_volume_claim(namespace=namespace.metadata.name)
            for pvc in pvc_list.items:
                assert pvc.status.phase == "Bound"
                
            
        except ApiException as e:
            if e.status == 404:
                print(f"Namespace '{namespace.metadata.name}' not found, skipping.")
                continue
            else:
                raise e
    

@then("stuff")
def sum_matches():
    pass