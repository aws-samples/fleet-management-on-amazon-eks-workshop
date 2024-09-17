from locust import TaskSet, task, constant, HttpUser
import random
import string
from kubernetes import client, config

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
    return file_contents,service_names

def delete_services(service_names, namespace_name):
    if service_names:
        for svc_name in service_names:
            try:
                k8s_api.delete_namespaced_service(name=svc_name, namespace=namespace_name)
                print(f"Deleted service: {svc_name}")
            except client.exceptions.ApiException as e:
                print(f"Error deleting service {svc_name}: {e}")

def query_coredns(service_names, namespace_name):
    import socket
    if service_names:
        for svc_name in service_names:
            try:
                resolved_addr = socket.gethostbyname(f"{svc_name}.{namespace_name}.svc.cluster.local")
                print(f"{svc_name}.{namespace_name}.svc.cluster.local resolved to address: {resolved_addr}")
            except client.exceptions.ApiException as e:
                print(f"Error resolving service {svc_name}: {e}")

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
            query_coredns(self.service_names, namespace_name)
            delete_services(self.service_names, namespace_name)
        except Exception as e:
            print(f"Error: {e}")

class WebsiteUser(HttpUser):
    tasks = [CoreDNSTaskSet]
    host = "http://localhost:8080"
