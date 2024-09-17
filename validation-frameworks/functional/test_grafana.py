import requests
from pytest_bdd import given, when, then, parsers, scenario, scenarios
from kubernetes import client, config

service_name = 'grafana'
namespace = 'monitoring'

@scenario('grafana.feature', 'Check Grafana is working')
def test_publish():
    pass

@given("a running EKS cluster")
def running_eks_cluster():
    # Perform any necessary setup steps, such as deploying Prometheus in your EKS cluster
    pass

#### WHEN RUNNING THIS PLEASE PORT FORWARD to 9090 ####
@when("I check grafana")
def check_prometheus_endpoint():
    # Make a GET request to the Prometheus endpoint
    #response = requests.get("http://ae1b1796253fc4857ae892ea21a787ed-1301041881.us-east-1.elb.amazonaws.com")

    # Save the response for later assertions
    #assert response.status_code == 200
    config.load_kube_config()
    v1 = client.CoreV1Api()
    service = v1.read_namespaced_service(name=service_name, namespace=namespace)
    external_ip = service.status.load_balancer.ingress[0].hostname
    url = "http://" + external_ip
    response = requests.get(url)
    #response = requests.get("http://ae1b1796253fc4857ae892ea21a787ed-1301041881.us-east-1.elb.amazonaws.com/d/vkQ0UHxik/coredns")
    print(response.text)
    assert response.status_code == 200
    #assert "Requests (total)" in response.text


@then("grafana should have the dashboards")
def verify_metrics_collected():
    # Assert that the response has a successful status code (e.g., 200)
    pass