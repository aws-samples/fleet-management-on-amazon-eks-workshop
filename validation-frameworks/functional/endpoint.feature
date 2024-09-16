Feature: Endpoints

  Scenario: Check endpoints
    Given a running EKS cluster
    When I check endpoints
    Then endpoint should be private