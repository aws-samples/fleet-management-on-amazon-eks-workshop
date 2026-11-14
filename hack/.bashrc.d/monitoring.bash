function grafana (){
  kubectl --context ${HUB_CONTEXT:-fleet-hub-cluster} -n grafana-operator port-forward svc/grafana-service 3000:3000
}
