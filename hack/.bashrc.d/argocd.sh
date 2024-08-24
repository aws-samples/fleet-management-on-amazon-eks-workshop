function argocd_hub_credentials (){
	echo "ArgoCD Username: admin"
	echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template='{{index .data.password | base64decode}}' --context fleet-hub-cluster)"
	echo "ArgoCD URL: https://$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --context fleet-hub-cluster)"
}
function argocd_staging_credentials (){
	echo "ArgoCD Username: admin"
	echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template='{{index .data.password | base64decode}}' --context fleet-staging-cluster)"
	echo "ArgoCD URL: https://$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --context fleet-staging-cluster)"
}
function argocd_prod_credentials (){
	echo "ArgoCD Username: admin"
	echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template='{{index .data.password | base64decode}}' --context fleet-prod-cluster)"
	echo "ArgoCD URL: https://$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --context fleet-prod-cluster)"
}
