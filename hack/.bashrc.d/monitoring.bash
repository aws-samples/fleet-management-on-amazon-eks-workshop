function grafana (){
  kubectl --context fleet-hub-cluster -n grafana-operator port-forward svc/grafana-service 3000:3000
}
