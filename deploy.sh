#!/bin/bash
#
# Copyright (c) 2026 Jeffrey Jonathan Jennings
#
# This script deploys or destroys AWS Private VPC using Terraform.
# It requires AWS SSO authentication and uses the specified AWS SSO profile.
#
# Usage Examples:
#   To create infrastructure:
#     ./deploy.sh=create --profile=<SSO_PROFILE_NAME> \
#                        --tfe-token=<TFE_TOKEN> \
#                        --vpc-prefix-name=<VPC_PREFIX_NAME> \
#                        --vpc-cidrs=<VPC_CIDRS> \
#                        [--subnet-prefix=<SUBNET_PREFIX>] \
#                        [--subnet-count=<SUBNET_COUNT>] \
#                        [--environment-name=<ENVIRONMENT_NAME>]
#
#   To destroy infrastructure:
#     ./deploy.sh=destroy --profile=<SSO_PROFILE_NAME> \
#                         --tfe-token=<TFE_TOKEN>
#
#

set -euo pipefail  # Stop on error, undefined variables, and pipeline errors

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Configuration folders
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

print_info "Terraform Directory: $TERRAFORM_DIR"

# Check required command (create or destroy) was supplied
case $1 in
  create)
    create_action="true";;
  destroy)
    create_action="false";;
  *)
    echo
    echo "(Error Message 001)  You did not specify one of the commands: create | destroy."
    echo
    echo "Usage:  Require all four arguments ---> `basename $0`=<create | destroy> --profile=<SSO_PROFILE_NAME> --tfe-token=<TFE_TOKEN> --vpc-prefix-name=<VPC_PREFIX_NAME> --vpc-cidrs=<VPC_CIDRS>"
    echo
    exit 85 # Common GNU/Linux Exit Code for 'Interrupted system call should be restarted'
    ;;
esac

# Default required variables
AWS_PROFILE=""           # AWS SSO Profile Name
tfe_token=""             # Terraform Token
vpc_prefix_name=""       # VPC Prefix Names
vpc_cidrs="10.0.0.0/16"  # VPC CIDR Blocks


# Default optional variables
environment_name="dev"  # Environment Name
subnet_prefix=24        # Subnet Prefix
subnet_count=3          # Subnet Count

# Get the arguments passed by shift to remove the first word
# then iterate over the rest of the arguments
shift
for arg in "$@" # $@ sees arguments as separate words
do
    case $arg in
        *"--profile="*)
            AWS_PROFILE=$arg;;
        *"--tfe-token="*)
            arg_length=12
            tfe_token=${arg:$arg_length:$(expr ${#arg} - $arg_length)};;
        *"--vpc-prefix-name="*)
            arg_length=18
            vpc_prefix_name=${arg:$arg_length:$(expr ${#arg} - $arg_length)};;
        *"--vpc-cidrs="*)
            arg_length=12
            vpc_cidrs=${arg:$arg_length:$(expr ${#arg} - $arg_length)};;
        *"--subnet-prefix="*)
            arg_length=16
            subnet_prefix=${arg:$arg_length:$(expr ${#arg} - $arg_length)};;
        *"--subnet-count="*)
            arg_length=15
            subnet_count=${arg:$arg_length:$(expr ${#arg} - $arg_length)};;
        *"--environment-name="*)
            arg_length=19
            environment_name=${arg:$arg_length:$(expr ${#arg} - $arg_length)};;
    esac
done

# Check required --profile argument was supplied
if [ -z $AWS_PROFILE ]
then
    echo
    echo "(Error Message 002)  You did not include the proper use of the --profile=<SSO_PROFILE_NAME> argument in the call."
    echo
    echo "Usage:  Require all four arguments ---> `basename $0 $1` --profile=<SSO_PROFILE_NAME> --tfe-token=<TFE_TOKEN> --vpc-prefix-name=<VPC_PREFIX_NAME> --vpc-cidrs=<VPC_CIDRS>"
    echo
    exit 85 # Common GNU/Linux Exit Code for 'Interrupted system call should be restarted'
fi

# Check required --tfe-token argument for the create action was supplied
if [ -z "$tfe_token" ]
then
    echo
    echo "(Error Message 003)  You did not include the proper use of the --tfe-token=<TFE_TOKEN> argument in the call."
    echo
    echo "Usage:  Require all four arguments ---> `basename $0 $1` --profile=<SSO_PROFILE_NAME> --tfe-token=<TFE_TOKEN> --vpc-prefix-name=<VPC_PREFIX_NAME> --vpc-cidrs=<VPC_CIDRS>"
    echo
    exit 85 # Common GNU/Linux Exit Code for 'Interrupted system call should be restarted'
fi

# Check required --vpc-prefix-name argument for the create action was supplied
if [ -z "$vpc_prefix_name" ] && [ "$create_action" = "true" ]
then
    echo
    echo "(Error Message 004)  You did not include the proper use of the --vpc-prefix-name=<VPC_PREFIX_NAME> argument in the call."
    echo
    echo "Usage:  Require all four arguments ---> `basename $0 $1` --profile=<SSO_PROFILE_NAME> --tfe-token=<TFE_TOKEN> --vpc-prefix-name=<VPC_PREFIX_NAME> --vpc-cidrs=<VPC_CIDRS>"
    echo
    exit 85 # Common GNU/Linux Exit Code for 'Interrupted system call should be restarted'
fi

# Check required --vpc-cidrs argument for the create action was supplied
if [ -z "$vpc_cidrs" ] && [ "$create_action" = "true" ]
then
    echo
    echo "(Error Message 005)  You did not include the proper use of the --vpc-cidrs=<VPC_CIDRS> argument in the call."
    echo
    echo "Usage:  Require all four arguments ---> `basename $0 $1` --profile=<SSO_PROFILE_NAME> --tfe-token=<TFE_TOKEN> --vpc-prefix-name=<VPC_PREFIX_NAME> --vpc-cidrs=<VPC_CIDRS>"
    echo
    exit 85 # Common GNU/Linux Exit Code for 'Interrupted system call should be restarted'
fi

# Get the AWS SSO credential variables that are used by the AWS CLI commands to authenicate
print_step "Authenticating with AWS SSO using profile: $AWS_PROFILE"
aws sso login $AWS_PROFILE
eval $(aws2-wrap $AWS_PROFILE --export)
export AWS_REGION=$(aws configure get region $AWS_PROFILE)

# Function to deploy infrastructure
deploy_infrastructure() {
    print_step "Deploying infrastructure with Terraform..."
    
    cd "$TERRAFORM_DIR"

    # Export credentials, TFC agent token and optional variables as environment variables
    export TF_VAR_aws_region="${AWS_REGION}"
    export TF_VAR_aws_access_key_id="${AWS_ACCESS_KEY_ID}"
    export TF_VAR_aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}"
    export TF_VAR_aws_session_token="${AWS_SESSION_TOKEN}"
    export TF_VAR_tfe_token="${tfe_token}"
    export TF_VAR_vpc_prefix_name="${vpc_prefix_name}"
    export TF_VAR_vpc_cidrs=${vpc_cidrs}
    export TF_VAR_subnet_prefix="${subnet_prefix}"
    export TF_VAR_subnet_count="${subnet_count}"
    export TF_VAR_environment_name="${environment_name}"
    
    # Initialize Terraform
    print_info "Initializing Terraform..."
    terraform init
    
    # Plan
    print_info "Running Terraform plan..."
    terraform plan -out=tfplan
    
    # Apply
    read -p "Do you want to apply this plan? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Applying Terraform plan..."
        terraform apply tfplan
        rm tfplan
        print_info "Infrastructure deployed successfully!"

        print_info "Creating the Terraform visualization..."
        terraform graph | dot -Tpng > ../docs/images/terraform-visualization.png
        print_info "Terraform visualization created at: ../docs/images/terraform-visualization.png"
        cd ..
        return 0
    else
        print_warn "Deployment cancelled"
        rm tfplan
        return 1
    fi
}

# Function to undeploy infrastructure
undeploy_infrastructure() {
    print_step "Destroying infrastructure with Terraform..."

    cd "$TERRAFORM_DIR"

    # Export credentials as environment variables
    export TF_VAR_aws_region="${AWS_REGION}"
    export TF_VAR_aws_access_key_id="${AWS_ACCESS_KEY_ID}"
    export TF_VAR_aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}"
    export TF_VAR_aws_session_token="${AWS_SESSION_TOKEN}"
    export TF_VAR_tfe_token="${tfe_token}"

    # Initialize Terraform
    print_info "Initializing Terraform..."
    terraform init

    # Destroy
    print_info "Running Terraform destroy..."
    terraform destroy -auto-approve

    print_info "Infrastructure destroyed successfully!"
    cd ..
}   

# Main execution flow
if [ "$create_action" = "true" ]
then
    deploy_infrastructure
else
    undeploy_infrastructure
    exit 0
fi
