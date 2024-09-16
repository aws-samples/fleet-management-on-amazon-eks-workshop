from pytest_bdd import scenario, scenarios, given, when, then
from pytest import fixture
from utils import platform_util
from kubernetes import client, config

config.load_kube_config()
v1 = client.CoreV1Api()
x = v1.list_node()
count = 0
for y in x.items:
    count = count + 1


#scenarios('./publish_article.feature')
@scenario('publish_article.feature', 'Cluster must have more than 1 nodes')
def test_publish():
    pass



@fixture
@given("A cluster")
def number():
    x = count
    return x


@fixture
def result():
    return {}

@when("I make the sum")
def when_sum(result, number):
    x = number
    helper = platform_util()
    x,y,z = helper.read_config("Account1")
    print(x,y,z)
    result['result'] = x


@then("The sum is greater than 1")
def sum_matches(result):
    assert result['result'] >= 1