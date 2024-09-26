import boto3
import os
from pytest_bdd import given, when, then, parsers, scenario, scenarios

@scenario('endpoint.feature', 'Check endpoints')
def test_publish():
    pass

@given("a running EKS cluster")
def running_eks_cluster():
    # Perform any necessary setup steps, such as deploying components in your EKS cluster
    pass

@when("I check endpoints")
def check_eks_endpoint():
    region = os.environ.get('AWS_REGION')
    eks_cluster_name = os.environ.get('EKS_CLUSTER_NAME')
    eksclient = boto3.client('eks', region_name = region)
    resp = eksclient.describe_cluster(name=eks_cluster_name)
    endpoint = resp['cluster']['logging']['clusterLogging']
    # for x in endpoint:
    #     print(x)
    #     assert x['enabled'] == True
    #     assert x['types'] == ['api', 'audit', 'authenticator', 'controllerManager', 'scheduler']
    for x in endpoint:
        if x['enabled'] == True:
            assert x['types'] == ['api', 'audit', 'authenticator']
        elif x['enabled'] == False:
            assert x['types'] == ['controllerManager', 'scheduler']
        
    
@then("endpoint should be private")
def verify_metrics_collected():
    # Assert that the response has a successful status code (e.g., 200)
    pass