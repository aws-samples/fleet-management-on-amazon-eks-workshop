from locust import TaskSet, task, constant, HttpUser
import random
import string
import time
from kubernetes import client, config

configuration = config.load_incluster_config()
api_client = client.ApiClient()
custom_objects_api = client.CustomObjectsApi(api_client)
node_limit = 10
core_api = client.CoreV1Api()


def check_and_limit_nodes():
    nodes = core_api.list_node().items
    current_node_count = len(nodes)
    
    if current_node_count == 0 or current_node_count >= node_limit:
        print(f"Node limit reached: {current_node_count}/{node_limit}")
        return False
    print(f"Node limit has not reached: {current_node_count}/{node_limit}")
    return True

def wait_for_node_ready(node_name, timeout=300, check_interval=10):
    start_time = time.time()
    while True:
        try:
            # Get the specific node
            node = core_api.read_node(name=node_name)
            # Check if the node is Ready
            for condition in node.status.conditions:
                if condition.type == "Ready":
                    if condition.status == "True":
                        print(f"Node {node_name} is Ready!")
                        return True
                    else:
                        print(f"Node {node_name} is not Ready. Current status: {condition.status}")
                        break

            # Check if timeout has been reached
            if time.time() - start_time > timeout:
                print(f"Timeout reached. Node {node_name} did not become Ready within {timeout} seconds.")
                #return False
            # Wait before checking again
            time.sleep(check_interval)
        except client.exceptions.ApiException as e:
            print(f"Waiting for node to be created. Exception when calling CoreV1Api->read_node: {e}")
            time.sleep(check_interval)
            #return False


# function to get karpenter nodeclaims in kubernetes cluster 
def create_nodeclaim(node_claim_name):
    #custom_objects_api = client.CustomObjectsApi(api_client)
    node_name = ''
    node_claim = {
        "apiVersion": "karpenter.sh/v1beta1",
        "kind": "NodeClaim",
        "metadata": {
            "name": node_claim_name
        },
        "spec": {
            "requirements": [
                {
                    "key": "karpenter.k8s.aws/instance-category",
                    "operator": "In",
                    "values": ["c"]
                },
                {
                    "key": "karpenter.sh/capacity-type",
                    "operator": "In",
                    "values": ["on-demand"]
                }
            ],
            "nodeClassRef": {
                "name": "compute-optimized"
            }
        }
    }
    #print(node_claim)
    try:
        custom_objects_api.create_namespaced_custom_object(
            group="karpenter.sh",
            version="v1beta1",
            namespace="",
            plural="nodeclaims",
            body=node_claim
        )
        while node_name == '':
            try:
                response = custom_objects_api.get_namespaced_custom_object(
                    group="karpenter.sh",
                    version="v1beta1",
                    namespace="",
                    plural="nodeclaims",
                    name=node_claim_name
                )
                print(f"Response NodeClaim: {response}")
                node_name = response['status']['nodeName']
            except Exception as e:
                print(f"Waiting for node to be created. Exception when calling CustomObjectsApi->get_namespaced_custom_object: {e}")
            time.sleep(5)
        print(f"Created NodeClaim: {node_claim_name}")
    except client.exceptions.ApiException as e:
        print(f"Error creating NodeClaim {node_claim_name}: {e}")
    return node_name


def generate_random_nodeclaim_name():
    alphabet = string.ascii_lowercase + string.digits
    return f"compute-optimized-{''.join(random.choices(alphabet, k=10))}"


def delete_nodeclaim(nodeclaim_name):
    if nodeclaim_name:
        try:
            #custom_objects_api = client.CustomObjectsApi(api_client)
            custom_objects_api.delete_namespaced_custom_object(
                group="karpenter.sh",
                version="v1beta1",
                namespace="",
                plural="nodeclaims",
                name=nodeclaim_name,
                body=client.V1DeleteOptions()
            )
            print(f"Deleted NodeClaim: {nodeclaim_name}")
        except client.exceptions.ApiException as e:
            print(f"Error deleting NodeClaim {nodeclaim_name}: {e}")

class CoreDNSTaskSet(TaskSet):
    wait_time = constant(1)
    
    @task
    def create_query_delete_nodeclaim(self):
        try:
            if check_and_limit_nodes():
                nodeclaim_name = generate_random_nodeclaim_name()
                print(f"Creating NodeClaim: {nodeclaim_name}")
                node_name = create_nodeclaim(nodeclaim_name)
                # Delete NodeClaim
                wait_for_node_ready(node_name)
                if nodeclaim_name:
                    print(f"Deleting NodeClaim: {nodeclaim_name}")
                    delete_nodeclaim(nodeclaim_name)
        except Exception as e:
            print(f"Error: {e}")

class WebsiteUser(HttpUser):
    tasks = [CoreDNSTaskSet]
    host = "http://localhost:8080"
