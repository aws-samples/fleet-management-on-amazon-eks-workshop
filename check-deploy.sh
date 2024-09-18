#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
ASK_DELETE=${ASK_DELETE:-false}

aws_debug() {
    set -x
    aws "$@"
    set +x
}

# Check if the user is authenticated with AWS
aws_debug sts get-caller-identity > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: You are not authenticated with AWS. Please configure your AWS credentials and try again."
    exit 1
fi

echo "List of clusters to check"
clusters=("fleet-hub-cluster" "fleet-spoke-prod" "fleet-spoke-staging")

echo "Checking if EKS clusters exist..."
all_clusters=$(aws_debug eks list-clusters --output text --query 'clusters[*]')
clusters_to_delete=()
for cluster in "${clusters[@]}"; do
    if echo "$all_clusters" | grep -q "$cluster"; then
        echo -e "${GREEN}EKS cluster '$cluster' exists.${NC}"
        clusters_to_delete+=("$cluster")
    else
        echo -e "${RED}EKS cluster '$cluster' does not exist.${NC}"
    fi
done

echo ""

if [[ "$ASK_DELETE" == "true" && "${#clusters_to_delete[@]}" -gt 0 ]]; then
    # Prompt user to delete EKS clusters
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing EKS clusters? (y/n) " choice
    else
        choice="y"
    fi
    case "$choice" in
        y|Y )
            for cluster in "${clusters[@]}"; do
                if echo "$all_clusters" | grep -q "$cluster"; then
                    echo "Deleting managed node groups for EKS cluster '$cluster'..."
                    node_groups=$(aws_debug eks list-nodegroups --cluster-name "$cluster" --query 'nodegroups[*]' --output text)
                    for node_group in $node_groups; do
                        aws_debug eks delete-nodegroup --cluster-name "$cluster" --nodegroup-name "$node_group"
                        echo "Waiting for managed node group '$node_group' to be deleted..."
                        aws_debug eks wait nodegroup-deleted --cluster-name "$cluster" --nodegroup-name "$node_group"
                    done

                    echo "Deleting EKS cluster '$cluster'..."
                    aws_debug eks delete-cluster --name "$cluster"
                    echo "Waiting for EKS cluster '$cluster' to be deleted..."
                    aws_debug eks wait cluster-deleted --name "$cluster"
                else
                    echo -e "${RED}EKS cluster '$cluster' does not exist.${NC}"
                fi
            done
            ;;
        n|N ) echo "Skipping EKS cluster deletion.";;
        * ) echo "Invalid choice. Skipping EKS cluster deletion.";;
    esac
fi

echo ""

# Check if CodeCommit repositories exist
echo "Checking if CodeCommit repositories exist..."
repo_names=("fleet-gitops-apps" "fleet-gitops-platform" "fleet-gitops-addons" "eks-fleet-workshop-gitops-platform" "eks-fleet-workshop-gitops-fleet" "eks-fleet-workshop-gitops-apps" "eks-fleet-workshop-gitops-addons")
repos_to_delete=()

for repo_name in "${repo_names[@]}"; do
    repo_exists=$(aws_debug codecommit get-repository --repository-name "$repo_name" 2>/dev/null)

    if [ -z "$repo_exists" ]; then
        echo -e "${RED}CodeCommit repository '$repo_name' does not exist.${NC}"
    else
        echo -e "${GREEN}CodeCommit repository '$repo_name' exists.${NC}"
        repos_to_delete+=("$repo_name")
    fi
done

# Prompt user to delete CodeCommit repositories
if [[ "$ASK_DELETE" == "true" && "${#repos_to_delete[@]}" -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing CodeCommit repositories? (y/n) " choice
    else
        choice="y"
    fi        
    case "$choice" in
        y|Y )
            for repo_name in "${repos_to_delete[@]}"; do
                echo "Deleting CodeCommit repository '$repo_name'..."
                aws_debug codecommit delete-repository --repository-name "$repo_name"
            done
            ;;
        n|N ) echo "Skipping CodeCommit repository deletion.";;
        * ) echo "Invalid choice. Skipping CodeCommit repository deletion.";;
    esac
fi


echo ""

# Check if IAM roles exist
echo "Checking if IAM roles exist..."
role_names=("fleet-hub-cluster-argocd-hub" "fleet-hub-cluster-eso" "fleet-spoke-prod-argocd-spoke" "fleet-spoke-staging-argocd-spoke" "carts-staging-role" "carts-prod-role")
roles_to_delete=()

for role_name in "${role_names[@]}"; do
    role_exists=$(aws_debug iam get-role --role-name "$role_name" 2>/dev/null)

    if [ -z "$role_exists" ]; then
        echo -e "${RED}IAM role '$role_name' does not exist.${NC}"
    else
        echo -e "${GREEN}IAM role '$role_name' exists.${NC}"
        roles_to_delete+=("$role_name")
    fi
done

echo ""

# Ask if you want to delete the existing IAM roles only if there are roles to delete
if [[ "$ASK_DELETE" == "true" && ${#roles_to_delete[@]} -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing IAM roles? (y/n) " choice
    else
        choice="y"
    fi
    if [ "$choice" == "y" ]; then
        for role_name in "${roles_to_delete[@]}"; do
            echo "Detaching policies from IAM role '$role_name'..."
            policies=$(aws_debug iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[*].PolicyArn' --output text)
            for policy in $policies; do
                aws_debug iam detach-role-policy --role-name "$role_name" --policy-arn "$policy"
            done

            echo "Deleting IAM role '$role_name'..."
            aws_debug iam delete-role --role-name "$role_name"
        done
        echo "IAM roles have been deleted."
    else
        echo "IAM roles will not be deleted."
    fi
else
    echo "No IAM roles found to delete."
fi



echo ""

# Check if IAM users exist
echo "Checking if IAM users exist..."
user_names=("fleet-gitops-bridge-gitops")
users_to_delete=()

for user_name in "${user_names[@]}"; do
    user_exists=$(aws_debug iam get-user --user-name "$user_name" 2>/dev/null)

    if [ -z "$user_exists" ]; then
        echo -e "${RED}IAM user '$user_name' does not exist.${NC}"
    else
        echo -e "${GREEN}IAM user '$user_name' exists.${NC}"
        users_to_delete+=("$user_name")
    fi
done

echo ""

# Ask if you want to delete the existing IAM users only if there are users to delete
if [[ "$ASK_DELETE" == "true" && ${#users_to_delete[@]} -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing IAM users? (y/n) " choice
    else
        choice="y"
    fi
    if [ "$choice" == "y" ]; then
        for user_name in "${users_to_delete[@]}"; do
            echo "Removing associated resources from IAM user '$user_name'..."

            # Remove access keys
            access_keys=$(aws_debug iam list-access-keys --user-name "$user_name" --query 'AccessKeyMetadata[*].AccessKeyId' --output text)
            for access_key in $access_keys; do
                aws_debug iam delete-access-key --user-name "$user_name" --access-key-id "$access_key"
            done

            # Remove signing certificates
            signing_certificates=$(aws_debug iam list-signing-certificates --user-name "$user_name" --query 'Certificates[*].CertificateId' --output text)
            for certificate in $signing_certificates; do
                aws_debug iam delete-signing-certificate --user-name "$user_name" --certificate-id "$certificate"
            done

            # Remove MFA devices
            mfa_devices=$(aws_debug iam list-mfa-devices --user-name "$user_name" --query 'MFADevices[*].SerialNumber' --output text)
            for device in $mfa_devices; do
                aws_debug iam deactivate-mfa-device --user-name "$user_name" --serial-number "$device"
            done

            # Remove inline policies
            inline_policies=$(aws_debug iam list-user-policies --user-name "$user_name" --query 'PolicyNames[*]' --output text)
            for policy in $inline_policies; do
                aws_debug iam delete-user-policy --user-name "$user_name" --policy-name "$policy"
            done

            # Remove SSH public key for CodeCommit
            ssh_public_key_id=$(aws_debug iam list-ssh-public-keys --user-name "$user_name" --query 'SSHPublicKeys[*].SSHPublicKeyId' --output text)
            if [ -n "$ssh_public_key_id" ]; then
                aws_debug iam delete-ssh-public-key --user-name "$user_name" --ssh-public-key-id "$ssh_public_key_id"
            fi

            echo "Detaching policies from IAM user '$user_name'..."
            policies=$(aws_debug iam list-attached-user-policies --user-name "$user_name" --query 'AttachedPolicies[*].PolicyArn' --output text)
            for policy in $policies; do
                aws_debug iam detach-user-policy --user-name "$user_name" --policy-arn "$policy"
            done

            echo "Deleting IAM user '$user_name'..."
            aws_debug iam delete-user --user-name "$user_name"
        done
        echo "IAM users have been deleted."
    else
        echo "IAM users will not be deleted."
    fi
else
    echo "No IAM users found to delete."
fi

echo ""


echo "Checking if IAM policies exist..."
policy_names=("fleet-gitops-bridge-gitops" "fleet-hub-cluster-eso" "fleet-hub-cluster-pod-identity-aws-assume" "fleet-hub-cluster-argocd-hub")
policies_to_delete=()

for policy_name in "${policy_names[@]}"; do
    policy_exists=$(aws_debug iam get-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${policy_name}" 2>/dev/null)

    if [ -z "$policy_exists" ]; then
        echo -e "${RED}IAM policy '$policy_name' does not exist.${NC}"
    else
        echo -e "${GREEN}IAM policy '$policy_name' exists.${NC}"
        policies_to_delete+=("$policy_name")
    fi
done

echo ""

# Ask if you want to delete the existing IAM policies only if there are policies to delete
if [[ "$ASK_DELETE" == "true" && ${#policies_to_delete[@]} -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing IAM policies? (y/n) " choice
    else
        choice="y"
    fi
    if [ "$choice" == "y" ]; then
        for policy_name in "${policies_to_delete[@]}"; do
            echo "Deleting IAM policy '$policy_name'..."

            # Detach the policy from all entities
            entities=$(aws_debug iam list-entities-for-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${policy_name}" --query '[PolicyGroups[*].GroupName, PolicyUsers[*].UserName, PolicyRoles[*].RoleName][]' --output text)

            for entity in $entities; do
                #if [[ $entity == *"/" ]]; then
                #    entity_type="role"
                #    entity_name=$(echo "$entity" | cut -d'/' -f2)
                #else
                #    entity_type="user"
                #    entity_name="$entity"
                #fi
                entity_type="role"
                entity_name="$entity"
                aws_debug iam detach-"$entity_type"-policy --"$entity_type"-name "$entity_name" --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${policy_name}" || echo "Warning: Unable to detach policy from $entity_type '$entity_name'. Skipping..."
                set +x
            done

            # Delete all non-default versions of the policy
            versions=$(aws_debug iam list-policy-versions --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${policy_name}" --query 'Versions[?!IsDefaultVersion].VersionId' --output text)

            for version in $versions; do
                aws_debug iam delete-policy-version --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${policy_name}" --version-id "$version" || true
            done

            # Delete the policy
            aws_debug iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${policy_name}" || true
        done

        echo "IAM policies have been deleted."
    else
        echo "IAM policies will not be deleted."
    fi
else
    echo "No IAM policies found to delete."
fi


echo ""

# Check if KMS key aliases exist
echo "Checking if KMS key aliases exist..."
alias_names=("alias/eks/fleet-spoke-prod" "alias/eks/fleet-spoke-staging" "alias/eks/fleet-hub-cluster")
aliases_to_delete=()

for alias_name in "${alias_names[@]}"; do
    alias_exists=$(aws_debug kms list-aliases --query "Aliases[?AliasName=='$alias_name']" --output text 2>/dev/null)

    if [ -z "$alias_exists" ]; then
        echo -e "${RED}KMS key alias '$alias_name' does not exist.${NC}"
    else
        echo -e "${GREEN}KMS key alias '$alias_name' exists.${NC}"
        aliases_to_delete+=("$alias_name")
    fi
done

# Ask if you want to delete the existing KMS key aliases only if there are aliases to delete
if [[ "$ASK_DELETE" == "true" && ${#aliases_to_delete[@]} -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing KMS key aliases? (y/n) " choice
    else
        choice="y"
    fi
    if [ "$choice" == "y" ]; then
        for alias_name in "${aliases_to_delete[@]}"; do
            echo "Deleting KMS key alias '$alias_name'..."

            # Get the key ID associated with the alias
            key_id=$(aws_debug kms list-aliases --query "Aliases[?AliasName=='$alias_name'].TargetKeyId" --output text)

            # Delete the alias
            aws_debug kms delete-alias --alias-name "$alias_name"

            # Schedule the key for deletion
            aws_debug kms schedule-key-deletion --key-id "$key_id" --pending-window-in-days 7
        done
        echo "KMS key aliases have been deleted."
    else
        echo "KMS key aliases will not be deleted."
    fi
else
    echo "No KMS key aliases found to delete."
fi

echo ""

# Check if Secrets Manager secrets exist
echo "Checking if Secrets Manager secrets exist..."
secret_names=("fleet-hub-cluster/fleet-spoke-prod" "fleet-hub-cluster/fleet-spoke-staging" "ssh-private-key-fleet-workshop")
# Check if Secrets Manager secrets exist
echo "Checking if Secrets Manager secrets exist..."
existing_secrets=()
for secret_name in "${secret_names[@]}"; do
    secret_exists=$(aws_debug secretsmanager describe-secret --secret-id "$secret_name" 2>/dev/null)

    if [ -z "$secret_exists" ]; then
        echo -e "${RED}Secrets Manager secret '$secret_name' does not exist.${NC}"
    else
        echo -e "${GREEN}Secrets Manager secret '$secret_name' exists.${NC}"
        existing_secrets+=("$secret_name")
    fi
done

echo ""
# Prompt user to delete existing Secrets Manager secrets
if [[ "$ASK_DELETE" == "true" && "${#existing_secrets[@]}" -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing Secrets Manager secrets? (y/n) " choice
    else
        choice="y"
    fi    
    case "$choice" in
        y|Y )
            for secret_name in "${existing_secrets[@]}"; do
                echo "Deleting Secrets Manager secret '$secret_name'..."
                aws_debug secretsmanager delete-secret --secret-id "$secret_name" --force-delete-without-recovery
            done
            ;;
        n|N ) echo "Skipping Secrets Manager secret deletion.";;
        * ) echo "Invalid choice. Skipping Secrets Manager secret deletion.";;
    esac
else
    echo "No Secrets Manager secrets exist."
fi

echo ""

# List of parameter names to check
parameter_names=("/fleet-hub/argocd-hub-role" "/fleet-hub/ssh-secrets-fleet-workshop" "GiteaExternalUrl")

# Check if SSM parameters exist
echo "Checking if SSM parameters exist..."
existing_parameters=()
for parameter_name in "${parameter_names[@]}"; do
    parameter_exists=$(aws_debug ssm get-parameter --name "$parameter_name" 2>/dev/null)

    if [ -z "$parameter_exists" ]; then
        echo -e "${RED}SSM parameter '$parameter_name' does not exist.${NC}"
    else
        echo -e "${GREEN}SSM parameter '$parameter_name' exists.${NC}"
        existing_parameters+=("$parameter_name")
    fi
done

echo ""
# Prompt user to delete existing SSM parameters
if [[ "$ASK_DELETE" == "true" && "${#existing_parameters[@]}" -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing SSM parameters? (y/n) " choice
    else
        choice="y"
    fi    
    case "$choice" in
        y|Y )
            for parameter_name in "${existing_parameters[@]}"; do
                echo "Deleting SSM parameter '$parameter_name'..."
                aws_debug ssm delete-parameter --name "$parameter_name"
            done
            ;;
        n|N ) echo "Skipping SSM parameter deletion.";;
        * ) echo "Invalid choice. Skipping SSM parameter deletion.";;
    esac
else
    echo "No SSM parameters exist."
fi

echo ""

# Check if CloudWatch log groups exist
echo "Checking if CloudWatch log groups exist..."
log_group_names=("/aws/eks/fleet-spoke-prod/cluster" "/aws/eks/fleet-spoke-staging/cluster" "/aws/eks/fleet-hub-cluster/cluster")
log_groups_to_delete=()

for log_group_name in "${log_group_names[@]}"; do
    log_group_exists=$(aws_debug logs describe-log-groups --log-group-name-prefix "$log_group_name" --query "logGroups[?logGroupName=='$log_group_name']" --output text 2>/dev/null)

    if [ -z "$log_group_exists" ]; then
        echo -e "${RED}CloudWatch log group '$log_group_name' does not exist.${NC}"
    else
        echo -e "${GREEN}CloudWatch log group '$log_group_name' exists.${NC}"
        log_groups_to_delete+=("$log_group_name")
    fi
done

# Ask if you want to delete the existing CloudWatch log groups only if there are log groups to delete
if [[ "$ASK_DELETE" == "true" &&  ${#log_groups_to_delete[@]} -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing CloudWatch log groups? (y/n) " choice
    else
        choice="y"
    fi
    if [ "$choice" == "y" ]; then
        for log_group_name in "${log_groups_to_delete[@]}"; do
            echo "Deleting CloudWatch log group '$log_group_name'..."

            # Delete the log group
            aws_debug logs delete-log-group --log-group-name "$log_group_name"
        done
        echo "CloudWatch log groups have been deleted."
    else
        echo "CloudWatch log groups will not be deleted."
    fi
else
    echo "No CloudWatch log groups found to delete."
fi

echo ""

# Check if VPC endpoints exist
echo "Checking if VPC endpoints exist..."
vpc_endpoint_names=("com.amazonaws.eu-west-1.guardduty-data" "com.amazonaws.eu-west-1.ssm" "com.amazonaws.eu-west-1.ec2messages" "com.amazonaws.eu-west-1.ssmmessages" "com.amazonaws.eu-west-1.s3")
vpc_names=("fleet-spoke-prod" "fleet-spoke-staging" "fleet-hub-cluster")

for vpc_name in "${vpc_names[@]}"; do
    vpc_id=$(aws_debug ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" --query "Vpcs[*].VpcId" --output text)
    vpc_endpoint_ids=()
    for endpoint_name in "${vpc_endpoint_names[@]}"; do
        endpoint_exists=$(aws_debug ec2 describe-vpc-endpoints --filters "Name=service-name,Values=$endpoint_name" "Name=vpc-id,Values=$vpc_id" --query "VpcEndpoints[*].VpcEndpointId" --output text 2>/dev/null)

        if [ -z "$endpoint_exists" ]; then
            echo -e "${RED}VPC endpoint '$endpoint_name' does not exist in VPC '$vpc_name'.${NC}"
        else
            echo -e "${GREEN}VPC endpoint '$endpoint_name' exists in VPC '$vpc_name'.${NC}"
            vpc_endpoint_ids+=("$endpoint_exists")
        fi
    done

    # Prompt user to delete VPC endpoints for this VPC
    if [[ "$ASK_DELETE" == "true" && ${#vpc_endpoint_ids[@]} -gt 0 ]]; then
        if [ "$ACCEPT_DELETE" != "true" ]; then
            read -p "Do you want to delete the existing VPC endpoints in VPC '$vpc_name'? (y/n) " choice
        else
            choice="y"
        fi        
        case "$choice" in
            y|Y )
                for vpc_endpoint_id in "${vpc_endpoint_ids[@]}"; do
                    vpc_endpoint_network_interface=$(aws_debug ec2 describe-network-interfaces --filters "Name=vpc-endpoint-id,Values=$vpc_endpoint_id" --query "NetworkInterfaces[*].VpcId" --output text)
                    echo "Deleting VPC endpoint $vpc_endpoint_id from VPC $vpc_endpoint_network_interface..."
                    aws_debug ec2 delete-vpc-endpoints --vpc-endpoint-ids "$vpc_endpoint_id"
                done
                ;;
            n|N ) echo "Skipping VPC endpoint deletion for VPC '$vpc_name'.";;
            * ) echo "Invalid choice. Skipping VPC endpoint deletion for VPC '$vpc_name'.";;
        esac
    fi
done

echo ""

# List of tags to check
echo "Checks tags"
tags=("fleet-spoke-staging" "fleet-spoke-prod" "fleet-hub-cluster")

# Check if resources with specified tags exist
echo "Checking if resources with specified tags exist..."
for tag in "${tags[@]}"; do
    echo "Checking tag: $tag"
    resources=$(aws_debug resourcegroupstaggingapi get-resources --tag-filters "Key=Blueprint,Values=$tag" --query "ResourceTagMappingList[*].ResourceARN" --output text)
    if [ -n "$resources" ]; then
        echo -e "${GREEN}Resources with tag '$tag' exist:${NC}"
        echo "$resources"
    else
        echo -e "${RED}No resources found with tag '$tag'.${NC}"
    fi
done

# Prompt user to delete resources if ASK_DELETE=true
if [ "$ASK_DELETE" = true ]; then
    for tag in "${tags[@]}"; do
        resources=$(aws_debug resourcegroupstaggingapi get-resources --tag-filters "Key=Blueprint,Values=$tag" --query "ResourceTagMappingList[*].ResourceARN" --output text)
        if [ -n "$resources" ]; then
            if [ "$ACCEPT_DELETE" != "true" ]; then        
                read -p "Do you want to delete resources with tag '$tag'? (y/n) " choice
            else
                choice="y"
            fi
            case "$choice" in
                y|Y)
                    for arn in $resources; do
                        # Extract the service name from the ARN
                        service=$(echo "$arn" | cut -d':' -f3)
                        echo "service = $service"
                        echo "Deleting resource with tag $tag, service $service -> $arn..."                        
                        #read -p "" tmp
                        case "$service" in
                            "kms")
                                # Delete KMS key
                                aws_debug kms disable-key --key-id "$arn" || true
                                aws_debug kms schedule-key-deletion --key-id "$arn" --pending-window-in-days 7 || true
                                ;;
                            "eks")
                                # Delete EKS access entry
                                cluster_name=$(echo "$arn" | cut -d'/' -f3)
                                role_name=$(echo "$arn" | cut -d'/' -f5)
                                access_entry_id=$(echo "$arn" | cut -d'/' -f6)
                                set -x
                                aws_debug eks delete-access-entry --cluster-name "$cluster_name" --principal-arn "$access_entry_id"
                                set +x
                                ;;
                            "ec2")
                                resource_type=$(echo "$arn" | cut -d':' -f6 | cut -d'/' -f1)
                                
                                case "$resource_type" in
                                    "volume")
                                        # Delete EBS volume
                                        volume_id=$(echo "$arn" | cut -d'/' -f2)
                                        volume_state=$(aws_debug ec2 describe-volumes --volume-ids "$volume_id" --query 'Volumes[*].State' --output text)
                                        if [ "$volume_state" = "available" ]; then
                                            aws_debug ec2 delete-volume --volume-id "$volume_id"
                                        else
                                            echo "Volume $volume_id is not in the available state. Skipping deletion."
                                        fi
                                        ;;                                
                                    "instance")
                                        # Terminate EC2 instance
                                        instance_id=$(echo "$arn" | cut -d'/' -f2)
                                        instance_state=$(aws_debug ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[*].Instances[*].State.Name' --output text)
                                        if [ "$instance_state" = "running" ]; then
                                            echo "terminating instance"
                                            aws_debug ec2 terminate-instances --instance-ids "$instance_id" || true
                                        else
                                            echo "Instance $instance_id does not exist or is not running, skipping."
                                            continue                                        
                                        fi                                        
                                        
                                        ;;                                
                                    "launch-template")
                                        # Delete EC2 launch template
                                        launch_template_id=$(echo "$arn" | cut -d'/' -f2)
                                        aws_debug ec2 delete-launch-template --launch-template-id "$launch_template_id" || true
                                        ;;
                                    "elastic-ip")
                                        # Release Elastic IP
                                        allocation_id=$(echo "$arn" | cut -d'/' -f2)
                                        aws_debug ec2 release-address --allocation-id "$allocation_id" || true
                                        ;;
                                    *)
                                        echo "unknown resource_type=$resource_type"
                                        ;;
                                esac
                                ;;
                        esac
                    done

                    ;;
                n|N)
                    echo "Skipping resource deletion for tag '$tag'."
                    ;;
                *)
                    echo "Invalid choice. Skipping resource deletion for tag '$tag'."
                    ;;
            esac
        fi
    done
fi

echo ""

# Define the VPC names to check
vpc_names=("fleet-spoke-prod" "fleet-spoke-staging" "fleet-hub-cluster")

# Check if any VPCs exist
vpcs_to_delete=()
for vpc_name in "${vpc_names[@]}"; do
    vpc_id=$(aws_debug ec2 describe-vpcs --region "$AWS_REGION" --filters "Name=tag:Name,Values=$vpc_name" --query 'Vpcs[*].VpcId' --output text)

    if [ -z "$vpc_id" ]; then
        echo -e "${RED}VPC with name '$vpc_name' does not exist in the $AWS_REGION region.${NC}"
    else
        echo -e "${GREEN}VPC with name '$vpc_name' exists in the $AWS_REGION region (VPC ID: $vpc_id).${NC}"
        vpcs_to_delete+=("$vpc_id")
    fi
done

# Ask if you want to delete the existing VPCs only if there are VPCs to delete
if [[ "$ASK_DELETE" == "true" && ${#vpcs_to_delete[@]} -gt 0 ]]; then
    if [ "$ACCEPT_DELETE" != "true" ]; then
        read -p "Do you want to delete the existing VPCs? (y/n) " choice
    else
        choice="y"
    fi
    case "$choice" in
        y|Y)
            # Iterate over each VPC ID and delete the VPC
            for vpc_id in "${vpcs_to_delete[@]}"; do
                echo "Deleting VPC $vpc_id..."

                 aws-delete-vpc -vpc-id=$vpc_id

            done
            echo "VPCs have been deleted."
            ;;
        n|N)
            echo "VPCs will not be deleted."
            ;;
        *)
            echo "Invalid choice. VPCs will not be deleted."
            ;;
    esac
else
    echo "No VPCs found to delete."
fi
