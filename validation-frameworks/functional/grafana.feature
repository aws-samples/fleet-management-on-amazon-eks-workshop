Feature: Grafana

  Scenario: Check Grafana is working
    Given a running EKS cluster
    When I check grafana
    Then grafana should have the dashboards