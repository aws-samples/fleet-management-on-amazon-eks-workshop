function argocd_credentials (){
    pkill -9 -f "kubectl --context $1 port-forward svc/argocd-server -n argocd $2:80"
    kubectl --context $1 port-forward svc/argocd-server -n argocd $2:80 >/dev/null 2>&1 &
	export ARGOCD_PWD=$(kubectl get secrets argocd-initial-admin-secret -n argocd --template='{{index .data.password | base64decode}}' --context $1)
    argocd login "localhost:$2" --plaintext --username admin --password $ARGOCD_PWD --name $1
	echo "ArgoCD Username: admin"
	echo "ArgoCD Password: $ARGOCD_PWD"
	echo "ArgoCD URL: $IDE_URL/proxy/$2"
}


function argocd_hub_credentials (){
	argocd_credentials fleet-hub-cluster 8081
}
function argocd_staging_credentials (){
	argocd_credentials fleet-staging-cluster 8082
}
function argocd_prod_credentials (){
	argocd_credentials fleet-prod-cluster 8083
}

