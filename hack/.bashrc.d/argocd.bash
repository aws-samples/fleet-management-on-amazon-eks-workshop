function argocd_credentials (){
	export ARGOCD_SERVER=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' --context $1)
	export ARGOCD_PWD=$(kubectl get secrets argocd-initial-admin-secret -n argocd --template='{{index .data.password | base64decode}}' --context $1)
	echo "ArgoCD Username: admin"
	echo "ArgoCD Password: $ARGOCD_PWD"
	echo "ArgoCD URL: https://$ARGOCD_SERVER"
	argocd login $ARGOCD_SERVER --username admin --password $ARGOCD_PWD --insecure --name $1
}

function argocd_hub_credentials (){
	argocd_credentials fleet-hub-cluster
}
function argocd_staging_credentials (){
	argocd_credentials fleet-staging-cluster
}
function argocd_prod_credentials (){
	argocd_credentials fleet-prod-cluster
}
