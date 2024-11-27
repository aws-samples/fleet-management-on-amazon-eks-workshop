function deploy_prod (){
  # Deploy the production cluster

  # Create the production cluster
  mkdir $GITOPS_DIR/fleet/members/fleet-spoke-prod
  cp $WORKSHOP_DIR/gitops/solutions/module-platform/fleet/members/fleet-spoke-prod/values.yaml $GITOPS_DIR/fleet/members/fleet-spoke-prod/values.yaml
  git -C $GITOPS_DIR/fleet status
  git -C $GITOPS_DIR/fleet add .
  git -C $GITOPS_DIR/fleet commit -m "add production cluster fleet member"
  git -C $GITOPS_DIR/fleet push

  # Deploy the production addons
  mkdir $GITOPS_DIR/addons/clusters/fleet-spoke-prod
  cp -r $WORKSHOP_DIR/gitops/solutions/module-platform/addons/clusters/fleet-spoke-prod/* $GITOPS_DIR/addons/clusters/fleet-spoke-prod/
  git -C $GITOPS_DIR/addons status
  git -C $GITOPS_DIR/addons add .
  git -C $GITOPS_DIR/addons commit -m "add addons for production cluster"
  git -C $GITOPS_DIR/addons push

  # Deploy the production namespaces
  cp -r $WORKSHOP_DIR/gitops/solutions/module-platform/platform/teams/* $GITOPS_DIR/platform/teams/
  git -C $GITOPS_DIR/platform status
  git -C $GITOPS_DIR/platform add .
  git -C $GITOPS_DIR/platform commit -m "add production namespaces for teams"
  git -C $GITOPS_DIR/platform push

  # Deploy the production apps
  cp -r $WORKSHOP_DIR/gitops/solutions/module-platform/apps/* $GITOPS_DIR/apps/
  git -C $GITOPS_DIR/apps status
  git -C $GITOPS_DIR/apps add .
  git -C $GITOPS_DIR/apps commit -m "add production kustomize files for apps"
  git -C $GITOPS_DIR/apps push
}

function app_url_staging (){
  wait-for-lb $(kubectl --context fleet-staging-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
}
function app_url_prod (){
  wait-for-lb $(kubectl --context fleet-prod-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
}

function apps_fix_kyverno_insights(){
  apps_fix_kyverno_insights_staging
  apps_fix_kyverno_insights_prod
}

function kyverno_policy_reporter_ui_staging_on(){
  nohup kubectl --context fleet-staging-cluster port-forward -n kyverno svc/policy-reporter-ui 8085:8080 > /dev/null 2>&1 &
  echo $IDE_URL/proxy/8085/#/
}

function kyverno_policy_reporter_ui_prod_on(){
  nohup kubectl --context fleet-prod-cluster port-forward -n kyverno svc/policy-reporter-ui 8086:8080 > /dev/null 2>&1 &
  echo $IDE_URL/proxy/8086/#/
}

function kyverno_policy_reporter_ui_off(){
  pkill -f "kubectl.*port-forward.*policy-reporter-ui"
}

function apps_fix_kyverno_insights_staging (){
  # Fix Kyverno Insights

  #staging
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/backend/catalog/staging/kustomization.yaml $GITOPS_DIR/apps/backend/catalog/staging/kustomization.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/backend/catalog/staging/deployment.yaml $GITOPS_DIR/apps/backend/catalog/staging/deployment.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/assets/staging/kustomization.yaml $GITOPS_DIR/apps/frontend/assets/staging/kustomization.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/assets/staging/deployment.yaml $GITOPS_DIR/apps/frontend/assets/staging/deployment.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/ui/staging/kustomization.yaml $GITOPS_DIR/apps/frontend/ui/staging/kustomization.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/ui/staging/deployment.yaml $GITOPS_DIR/apps/frontend/ui/staging/deployment.yaml

  git -C $GITOPS_DIR/apps status
  git -C $GITOPS_DIR/apps diff | cat
  git -C $GITOPS_DIR/apps add .
  git -C $GITOPS_DIR/apps commit -m "Fix Kyverno in catalog for Staging"
  git -C $GITOPS_DIR/apps push

}

function apps_fix_kyverno_prod_staging (){
  # Fix Kyverno Insights

  #staging
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/backend/catalog/prod/kustomization.yaml $GITOPS_DIR/apps/backend/catalog/prod/kustomization.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/backend/catalog/prod/deployment.yaml $GITOPS_DIR/apps/backend/catalog/prod/deployment.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/assets/prod/kustomization.yaml $GITOPS_DIR/apps/frontend/assets/prod/kustomization.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/assets/prod/deployment.yaml $GITOPS_DIR/apps/frontend/assets/prod/deployment.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/ui/prod/kustomization.yaml $GITOPS_DIR/apps/frontend/ui/prod/kustomization.yaml
  cp $WORKSHOP_DIR/gitops/solutions/module-kyverno/apps/frontend/ui/prod/deployment.yaml $GITOPS_DIR/apps/frontend/ui/prod/deployment.yaml

  git -C $GITOPS_DIR/apps status
  git -C $GITOPS_DIR/apps diff | cat
  git -C $GITOPS_DIR/apps add .
  git -C $GITOPS_DIR/apps commit -m "Fix Kyverno in catalog for Prod"
  git -C $GITOPS_DIR/apps push

}

function apps_default_kyverno_insights (){
  # restore default deployment

  # Create the production cluster
  mkdir $GITOPS_DIR/fleet/members/fleet-spoke-prod
  cp $WORKSHOP_DIR/gitops/apps/backend/catalog/base/deployment.yaml $GITOPS_DIR/apps/backend/catalog/base/deployment.yaml
  cp $WORKSHOP_DIR/gitops/apps/frontend/ui/base/deployment.yaml $GITOPS_DIR/apps/frontend/ui/base/deployment.yaml
  cp $WORKSHOP_DIR/gitops/apps/frontend/assets/base/deployment.yaml $GITOPS_DIR/apps/frontend/assets/base/deployment.yaml
  git -C $GITOPS_DIR/apps status
  git -C $GITOPS_DIR/apps diff | cat
  git -C $GITOPS_DIR/apps add .
  git -C $GITOPS_DIR/apps commit -m "Revert Fix Kyverno in catalog"
  git -C $GITOPS_DIR/apps push

}

function custom_domain() {
  (
    set -e
    set -x

    # Check if both parameters are provided
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Both environment and domain parameters are required"
        echo "Usage: custom_domain <environment> <domain-name>"
        echo "Environment must be either 'staging' or 'prod'"
        return 1
    fi

    local ENVIRONMENT="$1"
    local DOMAIN_NAME="$2"

    # Validate environment parameter
    if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "prod" ]]; then
        echo "Error: Environment must be either 'staging' or 'prod'"
        return 1
    fi

    # Check if the hosted zone exists in Route53
    if ! aws route53 list-hosted-zones-by-name --dns-name "$DOMAIN_NAME." --max-items 1 | grep -q "\"Name\": \"$DOMAIN_NAME.\""; then
        echo "Error: No Route53 hosted zone found for domain: $DOMAIN_NAME"
        echo "Please ensure the domain exists as a public hosted zone in Route53"
        return 1
    fi

    echo "Updating EKS Spoke cluster to use domain $DOMAIN_NAME... this can take couple of minutes..."
    cp "$WORKSHOP_DIR/gitops/solutions/module-custom-domain/terraform/spokes/custom_domain.tf" "$WORKSHOP_DIR/terraform/spokes/custom_domain.tf"
    export TF_VAR_hosted_zone_name="$DOMAIN_NAME"
    $WORKSHOP_DIR/terraform/spokes/deploy.sh "$ENVIRONMENT"
   
    echo "EKS Spoke cluster successfully deployed..."

    echo "Configuring External-DNS addons"

    echo "Adding domain name for frontend"
    cp "$WORKSHOP_DIR/gitops/solutions/module-custom-domain/gitops/platform/bootstrap/workloads/web-store-frontend-appset.yaml" "$GITOPS_DIR/platform/bootstrap/workloads/web-store-frontend-appset.yaml"
    if [[ -n "$(git -C "$GITOPS_DIR/platform" status --porcelain)" ]]; then
        git -C "$GITOPS_DIR/platform" status
        git -C "$GITOPS_DIR/platform" diff | cat
        git -C "$GITOPS_DIR/platform" add .
        git -C "$GITOPS_DIR/platform" commit -m "Adding domain name for frontend"
        git -C "$GITOPS_DIR/platform" push
    else
        echo "No changes to commit in platform repository"
    fi

    echo "Adding ingress kustomization"
    cp "$WORKSHOP_DIR/gitops/solutions/module-custom-domain/gitops/apps/frontend/ui/$ENVIRONMENT/ingress.yaml" "$GITOPS_DIR/apps/frontend/ui/$ENVIRONMENT/ingress.yaml"
    cp "$WORKSHOP_DIR/gitops/solutions/module-custom-domain/gitops/apps/frontend/ui/$ENVIRONMENT/kustomization.yaml" "$GITOPS_DIR/apps/frontend/ui/$ENVIRONMENT/kustomization.yaml"
    if [[ -n "$(git -C "$GITOPS_DIR/apps" status --porcelain)" ]]; then
        git -C "$GITOPS_DIR/apps" status
        git -C "$GITOPS_DIR/apps" diff | cat
        git -C "$GITOPS_DIR/apps" add .
        git -C "$GITOPS_DIR/apps" commit -m "Adding ingress & kustomization"
        git -C "$GITOPS_DIR/apps" push
    else
        echo "No changes to commit in apps repository"
    fi

    echo "Activating External DNS addon patch in ingress"
    cp "$WORKSHOP_DIR/gitops/solutions/module-custom-domain/gitops/addons/clusters/fleet-spoke-$ENVIRONMENT/addons/gitops-bridge/values.yaml" \
       "$GITOPS_DIR/addons/clusters/fleet-spoke-$ENVIRONMENT/addons/gitops-bridge/values.yaml"
    if [[ -n "$(git -C "$GITOPS_DIR/addons" status --porcelain)" ]]; then
        git -C "$GITOPS_DIR/addons" status
        git -C "$GITOPS_DIR/addons" diff | cat
        git -C "$GITOPS_DIR/addons" add .
        git -C "$GITOPS_DIR/addons" commit -m "Activating External DNS addon patch in ingress"
        git -C "$GITOPS_DIR/addons" push
    else
        echo "No changes to commit in addons repository"
    fi
  )
}
