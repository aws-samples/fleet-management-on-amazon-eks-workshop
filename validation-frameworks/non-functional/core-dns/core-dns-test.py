from locust import TaskSet, task, constant, HttpUser, events
import random
import string
from kubernetes import client, config
import socket
import time

config.load_incluster_config()
k8s_api = client.CoreV1Api()
namespace_name = "coredns-services"
number_of_services = 10

def generate_random_service_names(count):
    alphabet = string.ascii_lowercase + string.digits
    return [f"coredns-svc-{''.join(random.choices(alphabet, k=10))}" for _ in range(count)]

def generate_and_create_services(namespace_name, number_of_services):
    existing_services = k8s_api.list_namespaced_service(namespace_name)
    service_names = []

    if existing_services.items:
        print(f"There are already {len(existing_services.items)} services created")
        service_names = [svc.metadata.name for svc in existing_services.items]
    else:
        service_names = generate_random_service_names(number_of_services)

        for svc_name in service_names:
            k8s_api.create_namespaced_service(
                namespace_name,
                client.V1Service(
                    metadata=client.V1ObjectMeta(name=svc_name),
                    spec=client.V1ServiceSpec(ports=[client.V1ServicePort(port=8080, protocol="TCP")])
                )
            )

    file_contents = "\n".join([f"{svc_name}.{namespace_name}.svc.cluster.local A" for svc_name in service_names])
    return file_contents, service_names

def delete_services(service_names, namespace_name):
    if service_names:
        for svc_name in service_names:
            try:
                k8s_api.delete_namespaced_service(name=svc_name, namespace=namespace_name)
                print(f"Deleted service: {svc_name}")
            except client.exceptions.ApiException as e:
                print(f"Error deleting service {svc_name}: {e}")

def query_coredns(service_names, namespace_name):
    results = []
    if service_names:
        for svc_name in service_names:
            try:
                # Check if the service exists
                k8s_api.read_namespaced_service(name=svc_name, namespace=namespace_name)
                
                # If we reach here, the service exists. Now try to resolve it.
                start_time = time.time()
                resolved_addr = socket.gethostbyname(f"{svc_name}.{namespace_name}.svc.cluster.local")
                end_time = time.time()
                response_time = (end_time - start_time) * 1000  # Convert to milliseconds
                results.append((True, response_time))
                print(f"{svc_name}.{namespace_name}.svc.cluster.local resolved to address: {resolved_addr}")
            
            except client.exceptions.ApiException as api_e:
                if api_e.status == 404:
                    print(f"Service {svc_name} not found in namespace {namespace_name}")
                else:
                    print(f"API error when checking service {svc_name}: {api_e}")
            
            except socket.gaierror as e:
                print(f"Error resolving service {svc_name}: {e}")
            
            except Exception as e:
                print(f"Unexpected error with service {svc_name}: {e}")
    return results

class CoreDNSTaskSet(TaskSet):
    wait_time = constant(1)
    service_names = []
    
    @task
    def create_query_delete_services(self):
        try:
            # Create namespace if it doesn't exist
            try:
                k8s_api.create_namespace(client.V1Namespace(metadata=client.V1ObjectMeta(name=namespace_name)))
            except client.exceptions.ApiException as e:
                if e.status == 409:
                    print("Namespace already exists")
                else:
                    raise e

            # Generate and create services
            internal_domain_contents, self.service_names = generate_and_create_services(namespace_name, number_of_services)
            print(internal_domain_contents)
            
            # Query CoreDNS and capture results
            results = query_coredns(self.service_names, namespace_name)
            
            # Report results to Locust
            for success, response_time in results:
                if success:
                    self.user.environment.events.request.fire(
                        request_type="DNS",
                        name="query",
                        response_time=response_time,
                        response_length=0,
                        exception=None,
                        context={}
                    )
                else:
                    self.user.environment.events.request.fire(
                        request_type="DNS",
                        name="query",
                        response_time=0,
                        response_length=0,
                        exception=Exception("DNS resolution failed"),
                        context={}
                    )
            
            delete_services(self.service_names, namespace_name)
        except Exception as e:
            print(f"Error: {e}")

class WebsiteUser(HttpUser):
    tasks = [CoreDNSTaskSet]
    host = "http://localhost:8080"

@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    print("A new test is starting")

@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    print("A test is ending")