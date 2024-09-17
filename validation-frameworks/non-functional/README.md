## Introduction to Locust

Locust is an open-source load testing tool that allows you to write your tests in Python. It's scalable and can simulate millions of users, making it perfect for testing the performance of your Kubernetes services.

## Load Test on Core-DNS
CoreDNS is a flexible, extensible DNS server that can serve as the Kubernetes cluster DNS. When you launch an Amazon EKS cluster with at least one node, two replicas of the CoreDNS image are deployed by default, regardless of the number of nodes deployed in your cluster. The CoreDNS Pods provide name resolution for all Pods in the cluster. 

Applications use name resolution to connect to pods and services in the cluster as well as connecting to services outside the cluster. As the number of requests for name resolution (queries) from pods increase, the CoreDNS pods can get overwhelmed and slow down, and reject requests that the pods can’t handle.

Our load test will help us understand how CoreDNS performs under various levels of stress.

#### Script to test Core DNS
The sample script is provided can be used for load testing the CoreDNS service in a Kubernetes cluster. It uses the Kubernetes API to create a specified number of services, query their DNS addresses, and then delete the services. The Locust load testing tool can be used to simulate multiple users executing these tasks concurrently, allowing for performance testing and validation of the CoreDNS service.

Let's break down the key components of the script:

- Below function checks if any services already exist in the specified namespace. If not, it generates random service names and creates Kubernetes services with those names in the specified namespace. It returns the contents of an internal domain file and the list of service names.
```
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
```

- Below function takes a list of service names and the namespace name, and attempts to resolve the DNS address of each service using the socket.gethostbyname function.
```
def query_coredns(service_names, namespace_name):
    import socket
    if service_names:
        for svc_name in service_names:
            try:
                resolved_addr = socket.gethostbyname(f"{svc_name}.{namespace_name}.svc.cluster.local")
                print(f"{svc_name}.{namespace_name}.svc.cluster.local resolved to address: {resolved_addr}")
            except client.exceptions.ApiException as e:
                print(f"Error resolving service {svc_name}: {e}")
```

- Below function takes a list of service names and the namespace name, and attempts to delete theses service from the cluster.
```
def delete_services(service_names, namespace_name):
    if service_names:
        for svc_name in service_names:
            try:
                k8s_api.delete_namespaced_service(name=svc_name, namespace=namespace_name)
                print(f"Deleted service: {svc_name}")
            except client.exceptions.ApiException as e:
                print(f"Error deleting service {svc_name}: {e}")
```

- Finally, The CoreDNSTaskSet class defines a task set for the Locust load testing tool. This is the main Locust task set that orchestrates the creation, querying, and deletion of services
```
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
```

#### Step to run the Core DNS test
Follow these steps to run the Core-DNS load test:
1. Navigate to non-functional testing framework directory
```
cd $VALIDATION_MODULE_HOME/non-functional
```
2. Add the Delivery Hero Helm repository:
```
helm repo add deliveryhero "https://charts.deliveryhero.io/"
helm repo update deliveryhero
helm repo list | egrep "NAME|deliveryhero"
```
3. Create a ConfigMap with the test script:
```
kubectl create configmap eks-loadtest-locustfile --from-file $VALIDATION_MODULE_HOME/non-functional/core-dns/core-dns-test.py
```
4. Apply the necessary RBAC roles:
```
kubectl apply -f $VALIDATION_MODULE_HOME/non-functional/core-dns/locust-cluster-role.yaml
```
5. Deploy Locust in the EKS Cluster:
```
helm upgrade --install eks-loadtest-locust deliveryhero/locust \
    --set loadtest.name=eks-loadtest \
    --set loadtest.locust_locustfile_configmap=eks-loadtest-locustfile \
    --set loadtest.locust_locustfile=core-dns-test.py \
    --set worker.hpa.enabled=true \
    --set worker.hpa.minReplicas=2 \
    --set "loadtest.pip_packages[0]=kubernetes"
```
6. Port-forward the Locust service:
```
kubectl --namespace default port-forward service/eks-loadtest-locust 8089:8089
```
7. Access the Locust web interface. Open a web browser and go to `http://localhost:8089`.
8. In the Locust web interface, set the number of users to simulate and the spawn rate, then start the test.
9. Start with 10 concurrent requests.
10. Then ramp up to 20 concurrent requests.
11. Use Amazon CloudWatch Container Insights to monitor the performance of CoreDNS during the test.

#### Analyzing the Results

After running the load test, analyze the results in both the Locust web interface and CloudWatch Container Insights. Look for metrics such as:

- Response times
- Number of successful/failed requests
- CPU and memory usage of CoreDNS pods
- Any error messages or timeouts

This analysis will help you understand how CoreDNS performs under load and identify any potential bottlenecks or areas for optimization in your EKS cluster.

#### Cleanup

At the end of the test delete any dangling services that are created as part of the test
```
kubectl get svc -n coredns-services | awk '{print $1}' | xargs kubectl delete svc -n coredns-services
```

Also delete the Locust pods deployed via Helm
```
helm delete eks-loadtest-locust
```