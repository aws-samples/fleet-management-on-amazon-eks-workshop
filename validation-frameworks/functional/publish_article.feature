Feature: Count
  Sum of nodes

  Scenario: Cluster must have more than 1 nodes
  Given A cluster
  When I make the sum
  Then The sum is greater than 1