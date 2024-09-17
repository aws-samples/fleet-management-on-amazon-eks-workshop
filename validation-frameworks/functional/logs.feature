Feature: Check Logs for Errors
    Scenario Outline: Check logs in a namespace
        Given a EKS Cluster
        When I check pods in a namespace
        Then logs should not contain any errors

