function deploy_fleet_dashboard (){
    echo "Deploying EKS Fleet Dashboard... this can take couple of minutes..."
    terraform -chdir=$WORKSHOP_DIR/terraform/fleet-dashboard init >/dev/null
    terraform -chdir=$WORKSHOP_DIR/terraform/fleet-dashboard apply -auto-approve >/dev/null
    echo "EKS Fleet Dashboard successfully deployed..."
}
