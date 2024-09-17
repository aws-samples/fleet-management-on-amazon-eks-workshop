import boto3
from pytest_bdd import given, when, then, parsers, scenario, scenarios

@scenario('endpoint.feature', 'Check endpoints')
def test_publish():
    pass

@given("a running EKS cluster")
def running_eks_cluster():
    # Perform any necessary setup steps, such as deploying Prometheus in your EKS cluster
    pass

#### WHEN RUNNING THIS PLEASE PORT FORWARD to 9090 ####
@when("I check endpoints")
def check_prometheus_endpoint():
    eksclient = boto3.client('eks', region_name = 'us-east-1')
    resp = eksclient.describe_cluster(name='blue')
    endpoint = resp['cluster']['logging']['clusterLogging']
    for x in endpoint:
        assert x['enabled'] == True
        assert x['types'] == ['api', 'audit', 'authenticator', 'controllerManager', 'scheduler']

    
@then("endpoint should be private")
def verify_metrics_collected():
    # Assert that the response has a successful status code (e.g., 200)
    pass